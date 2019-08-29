#!/bin/sh

#这里是脚本的配置文件

#以下变量需要手动填写

#####################################################jenkins_配置####################################################
#第一个参数为 version
#第二个参数为 language
#第三个参数为 svn代码目录所在位置
#第四个参数为 assets目录svn_url
#第五个参数为 instance目录svn_url
##输入参数格式

VERSION=$1
LANGUAGE_EX=$2   #LANUAGE会和原环境变量冲突
SVN_DIR=$3
SVN_CONFIG_ASSETS=$4
SVN_CONFIG_INSTANCE=$5
NEED_BUILD_LIST=($6)
NEED_PACKAGE_LIST=($7)
IS_MUST_GET_TIME=$8
IS_REBUILD_PRJ=$9
DIR_NAME=${10}

######################################################本地配置(按需调整)##################################
#svn 用户
SVN_USER=fanjunliang

#目录定义
#根目录
ROOT_DIR=/home/sanguo/build_ex
SHELL_DIR=$ROOT_DIR/shell$VERSION

#dir def
PRJ_DIR=$ROOT_DIR/$VERSION
#上层目录为编译主目录
BUILD_DIR=build
BIN_DIR=bin
LIB_DIR=lib
CONFIG_DIR=config
PACKAGE_DIR=zip

#编译目录
PRJ_BUILD_DIR=$PRJ_DIR/$BUILD_DIR
PRJ_BIN_DIR=$PRJ_DIR/$BIN_DIR
PRJ_LIB_DIR=$PRJ_DIR/$LIB_DIR
PRJ_CONFIG_DIR=$PRJ_DIR/$CONFIG_DIR
#log文件
LOG_FILE=$PRJ_DIR/operation.log
#配置 svn版本号文件
CONFIG_VERSION=config_version.txt
OLD_CONFIG_VERSION=SVN_Version.json

#打包目录
PRJ_PACKAGE_DIR=$PRJ_DIR/$PACKAGE_DIR
PRJ_TEMP_BIN_DIR=$PRJ_DIR/temp

#工具目录(继续使用旧环境编译)
TOOL_HOME="/home/sanguo/tool_build/"
SVN_RENAME_TOOL_CONFIG="http://10.21.210.43/svn/fytx/project/fytx/server/branch/db_tool/bin/instance_rename_roles"
SVN_MERGE_TOOL_CONFIG="http://10.21.210.43/svn/fytx/project/fytx/server/branch/db_tool/bin/instance_combine_servers"

#项目名称
#lib
#注意按照编译顺序赋值,注意两个项目之间有空格分隔
arr_lib=(game_def 
	util_lib
	net_lib 
	game_config_data
	fight_lib
    cross_svr_lib
	)

#单服进程
arr_srv=(mysql_server
	gate_server 
	game_server 
	game_config_data_test)

#跨服进程
arr_cross_srv=(battle_net_server 
	battle_net_seige_server 
	new_battle_net_server 
	new_battle_net_central_server 
	assist_net_server 
	net_arena_server 
	daily_challenge_system
    kingdom_war_net_server
	miracle_system
	)

arr_all_srv=("${arr_srv[@]}" "${arr_cross_srv[@]}")
arr_all=("${arr_lib[@]}" "${arr_all_srv[@]}" )
	
#配置文件夹
CONFIG_ASSETS=assets
CONFIG_INSTANCE=instance
GM_TOOL=web_gm_manager_tornado
GM_TOOL_NAME=gm-tool
arr_language=(jianti fanti hanwen)
arr_config=($CONFIG_ASSETS $CONFIG_INSTANCE)

#编译参数
CXX="ccache g++"
#lib库编译参数
LIB_CFLAGS=" -g -MMD -MP -I./Include/ -I../util_lib/ -I../game_def/ -I../net_lib/Include/ -I../game_config_data -I/usr/local/mongo_driver_1_1_1/include/ -I/usr/local/mongo_driver_1_1_1/include/mongo/ -D NDEBUG -std=c++0x -fmessage-length=0"

#server编译参数
SRV_CFLAGS=" -g -O2 -g3 -rdynamic -MMD -MP -I. -I../fight_lib -I../cross_svr_lib -I../game_config_data/ -I../util_lib/ -I../game_def/ -I../net_lib/Include/ -I/usr/local/mongo_driver_1_1_1/include/ -I/usr/local/mongo_driver_1_1_1/include/mongo/ -I/usr/local/include -I/usr/include/mysql -I/home/mysql++-3.1.0/lib -D NDEBUG -std=c++0x -fmessage-length=0"
SRV_LIBS="-L../../lib/ -L/usr/local/mongo_driver_1_1_1/lib/ -L/usr/local/boost_1600/lib/ -lfight_lib -lcross_svr_lib -lgame_config_data -lnet_lib -lutil_lib -lgame_def -lmongoclient  -lmysqlpp -lboost_system -lboost_thread -lboost_filesystem -lboost_date_time -lboost_regex -lboost_program_options -lz"



################################################################远程服务器配置##################################
#星星服配置
REMOTE_SERVER_IP="10.21.210.105"
REMOTE_SERVER_NAME="fytx_mixed_s030a" 
if [ "$DIR_NAME" != "" ]; then
	REMOTE_SERVER_NAME=$DIR_NAME
fi
echo -e "-------------DIR_NAME: $REMOTE_SERVER_NAME"
REMOTE_SERVER_DIR="/home/$REMOTE_SERVER_NAME/server"

################################################################下面的内容请勿修改###############################

#check version
if [ -z "$VERSION" ];then
	echo -e "$RED must use trunk or branch,now version is empty$BLACK"
	exit 1
fi


############################get ntp time##################################

echo -e "$GREEN get the ntp time,please wait......$BLACK"
now=`python get_ntp_time.py`
EXCODE=$?
if [ "$EXCODE" != "0" ]; then
	echo -e "$RED  获取互联网时间失败，直接获取当前机器时间。。。$BLACK"
	now=`date "+%Y-%m-%d-%H.%M.%S"`
	if [ ! -z $IS_MUST_GET_TIME ];then
		echo -e "$RED  该操作强制要求获取互联网时间。。。$BLACK"
		exit 1
	fi
fi

echo -e "$GREEN now is $now ! $BLACK"


if [ ! -z $IS_REBUILD_PRJ ];then
	echo -e "$RED  rebuild project,first del old build dir。。$BLACK"
	rm -rf $PRJ_BUILD_DIR 
fi



############################创建目录#########################
#创建编译目录
test -d $PRJ_DIR||mkdir -p $PRJ_DIR;
test -d $PRJ_BUILD_DIR||mkdir -p $PRJ_BUILD_DIR
test -d $PRJ_BIN_DIR||mkdir -p $PRJ_BIN_DIR
test -d $PRJ_LIB_DIR||mkdir -p $PRJ_LIB_DIR

test -d $PRJ_BUILD_DIR||mkdir -p $PRJ_BUILD_DIR
test -d $PRJ_BIN_DIR||mkdir -p $PRJ_BIN_DIR
test -d $PRJ_CONFIG_DIR||mkdir -p $PRJ_CONFIG_DIR

#创建各个项目的编译目录
for v in ${arr_all[@]};do
	tmpDir=$PRJ_BUILD_DIR/$v
	test -d $tmpDir||mkdir -p $tmpDir 
done

test -d $PRJ_BUILD_DIR/$GM_TOOL||mkdir -p $PRJ_BUILD_DIR/$GM_TOOL

#创建配置文件目录
for v in ${arr_language[@]};do
	tmpDir=$PRJ_CONFIG_DIR/$v
	test -d $tmpDir||mkdir -p $tmpDir 
	for vex in ${arr_config[@]};do
		tmpDirEx=$tmpDir/$vex
		test -d $tmpDirEx||mkdir -p $tmpDirEx
 	done
done

#记录本次操作变量
if [ ! -f "$LOG_FILE" ];then
	touch $LOG_FILE
fi

###########################################公共函数##############################

function enter_root_dir(){
	cd $ROOT_DIR
}
function enter_shell_dir(){
	cd $SHELL_DIR
}

#svn信息临时存放变量
TMP_SVN_INFO=
function get_dir_svn_info(){
	tmpDir=$1
	export LANGUAGE=en_US.en
	local_last_change=$(svn info $tmpDir|awk 'NR==9 {print $4}')
	last_change=$(svn info $tmpDir|awk 'NR==5 {print $2}')
	TMP_SVN_INFO="$local_last_change""_""$last_change"
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "获取 $tmpDir 文件svn信息发生错误，请联系对应的开发人员"
			exit 1
	fi
}

function print_config(){
	echo  "############本次操作配置如下##################"
	echo  "date:$now"
	echo  "version=$VERSION"
	echo  "language=$LANGUAGE_EX"
	echo  "svn_url=$SVN_DIR"
	echo  "svn_config_assets=$SVN_CONFIG_ASSETS"
	echo  "svn_config_instance=$SVN_CONFIG_INSTANCE" 
}

print_config 
print_config >>$LOG_FILE

