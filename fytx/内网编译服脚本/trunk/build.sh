#!/bin/sh

source ./config.sh

###############################################以下内容请勿修改#############################
#从svn update 各项目文件

echo "####build####">>$LOG_FILE

function update_svn_code(){
	echo -e "从svn 更新各项目文件"
	for v in ${arr_all[@]};do
		enter_shell_dir
		tmpDir=$PRJ_BUILD_DIR/$v
		echo "echo svn --username=$SVN_USER co $SVN_DIR/$v $tmpDir "
		svn --username=$SVN_USER co $SVN_DIR/$v $tmpDir
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
			exit 1
		fi
		
		#记录本次编译版本号信息
		get_dir_svn_info $tmpDir
		echo "#define SVN_VERSION \"$TMP_SVN_INFO\"" >$tmpDir/SVN_Serial.h
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
			exit 1
		fi
		enter_shell_dir
	done
	enter_shell_dir
	tmpDir=$PRJ_BUILD_DIR/$GM_TOOL
	echo "echo svn --username=$SVN_USER co $SVN_DIR/gm_tool_util/$GM_TOOL $tmpDir"
	svn --username=$SVN_USER co $SVN_DIR/gm_tool_util/$GM_TOOL $tmpDir
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "从svn更新 gm_tool_util 文件发生错误，请联系对应的开发人员"
		exit 1
	fi
}

function start_build_lib(){
	#开始编译
	for v in ${arr_lib[@]};do
		enter_shell_dir
		echo -e "开始编译 $v ..... "
		tmpDir=$PRJ_BUILD_DIR/$v
		cp makefile_for_lib $tmpDir
		cd $tmpDir
		tmpName=lib$v.a
		#先清理
		#time make -f makefile_for_lib clean LIB_NAME="$tmpName" CC="$CXX" CFLAG="$LIB_CFLAGS"
		time make -f makefile_for_lib all LIB_NAME="$tmpName" CC="$CXX" CFLAG="$LIB_CFLAGS"
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "编译 $v 文件发生错误，请查看具体信息"
			exit 1
		fi
		echo -e "编译 $v 成功!"
		enter_shell_dir
	done
	
	for v in ${arr_lib[@]};do
		md5=`md5sum $PRJ_LIB_DIR/lib$v.a|awk '{print $1}'`
		size=`ls -lh $PRJ_LIB_DIR/lib$v.a|awk '{print $5}'`
		echo -e "$v \t\tmd5:$md5\tsize:$size\t"
		echo "$v:	md5:$md5	size:$size" >>$LOG_FILE
	done
}

function start_build_server(){
	for v in ${arr_srv[@]};do
		enter_shell_dir
		echo -e "开始编译单服程序 $v ....."
		tmpDir=$PRJ_BUILD_DIR/$v
		cp makefile_for_srv $tmpDir
		cd $tmpDir
		#time make -j4 -f makefile_for_srv clean SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		time make -j4 -f makefile_for_srv all SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "编译 $v 文件发生错误，请查看具体信息"
			exit 1
		fi
		echo -e "编译单服程序 $v 成功!"
		enter_shell_dir
	done
	
	for v in ${arr_srv[@]};do
		md5=`md5sum $PRJ_BIN_DIR/$v|awk '{print $1}'`
		size=`ls -lh $PRJ_BIN_DIR/$v|awk '{print $5}'`
		echo -e "$v \t\tmd5:$md5\tsize:$size\t"
		echo "$v:	md5:$md5	size:$size">>$LOG_FILE
	done
}

function start_build_cross_server(){
	for v in ${arr_cross_srv[@]};do
		enter_shell_dir
		echo -e "开始编译跨服 $v ..... "
		tmpDir=$PRJ_BUILD_DIR/$v
		cp makefile_for_srv $tmpDir
		cd $tmpDir
		#time make -j4 -f makefile_for_srv clean SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		time make -j4 -f makefile_for_srv all SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "编译 $v 文件发生错误，请查看具体信息 "
			exit 1
		fi
		echo -e "编译跨服 $v 成功! "
		enter_shell_dir
	done
	
	for v in ${arr_cross_srv[@]};do
		md5=`md5sum $PRJ_BIN_DIR/$v|awk '{print $1}'`
		size=`ls -lh $PRJ_BIN_DIR/$v|awk '{print $5}'`
		echo -e "$v \t\tmd5:$md5\tsize:$size\t"
		echo "$v:	md5:$md5	size:$size">>$LOG_FILE
	done
}

function start_build_one_cross_server(){
	for v in ${arr_cross_srv[@]};do
		if [ $v != "kingdom_war_net_server" ];then
			continue
		fi
		enter_shell_dir
		echo -e "开始编译跨服 $v ..... "
		tmpDir=$PRJ_BUILD_DIR/$v
		cp makefile_for_srv $tmpDir
		cd $tmpDir
		#time make -j4 -f makefile_for_srv clean SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		time make -j4 -f makefile_for_srv all SRV_NAME="$v" CC="$CXX" CFLAG="$SRV_CFLAGS" LIBS="$SRV_LIBS"
		EXCODE=$?
		if [ "$EXCODE" != "0" ]; then
			echo -e "编译 $v 文件发生错误，请查看具体信息 "
			exit 1
		fi
		echo -e "编译跨服 $v 成功! "
		enter_shell_dir
	done
	
	for v in ${arr_cross_srv[@]};do
		if [ $v != "kingdom_war_net_server" ];then
			continue
		fi
		md5=`md5sum $PRJ_BIN_DIR/$v|awk '{print $1}'`
		size=`ls -lh $PRJ_BIN_DIR/$v|awk '{print $5}'`
		echo -e "$v \t\tmd5:$md5\tsize:$size\t"
		echo "$v:	md5:$md5	size:$size">>$LOG_FILE
	done
}

function build_db_tool(){
	#改名和合服工具等继续使用旧编译环境
	enter_shell_dir
	prj_name=$1
	cd $TOOL_HOME	
	cd $prj_name/shell
	sh $prj_name"_svn_make.sh"
	enter_shell_dir
}


function build_all(){
	#update_svn_code
	#start_build_lib
	start_build_server
	start_build_cross_server
	build_db_tool player_rename_tool
	build_db_tool server_merge_tool
}

###########################################选择执行编译############################
#  0:编译所有文件  1:编译单服程序  2:编译跨服程序  3:编译改名工具  4：编译合服工具

is_have_build_lib=0
for v in ${NEED_BUILD_LIST[@]};do
	
	num=$v
	
	#build lib
	if [ $is_have_build_lib -eq 0 ];then
		update_svn_code
		start_build_lib
		is_have_build_lib=1
	fi

	if [ $num = "0" ];then
		build_all
		break
	elif [ $num = "1" ];then
		start_build_server
	elif [ $num = "2" ];then
		start_build_cross_server
	elif [ $num = "3" ];then
		build_db_tool player_rename_tool
	elif [ $num = "4" ];then
		build_db_tool server_merge_tool
	elif [ $num = "5" ];then
		start_build_one_cross_server
	else
		echo "无效的选项,$num"
		exit 1
	fi
done









