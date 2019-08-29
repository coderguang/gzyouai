#!/bin/sh

source ./config.sh

#先更新配置
echo -e "从svn 更新配置到本地"

local_language=jianti

if [ -n "$LANGUAGE_EX" ]; then 
	local_language=$LANGUAGE_EX
fi


local_assets=$PRJ_CONFIG_DIR/$local_language/$CONFIG_ASSETS
local_instance=$PRJ_CONFIG_DIR/$local_language/$CONFIG_INSTANCE

echo "svn --username=$SVN_USER co $SVN_CONFIG_ASSETS $local_assets "
svn --username=$SVN_USER co $SVN_CONFIG_ASSETS $local_assets
EXCODE=$?
if [ "$EXCODE" != "0" ]; then
	echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
	exit 1
fi

#记录本次编译版本号信息
echo "#####config##">>$LOG_FILE
get_dir_svn_info $local_assets
echo "$CONFIG_ASSETS:$TMP_SVN_INFO" >>$LOG_FILE
echo "$CONFIG_ASSETS		$TMP_SVN_INFO" >$local_assets/$CONFIG_VERSION
echo "{\"version\":\"$TMP_SVN_INFO\"}" >$local_assets/$OLD_CONFIG_VERSION


echo "svn --username=$SVN_USER co $SVN_CONFIG_INSTANCE $local_instance"
svn --username=$SVN_USER co $SVN_CONFIG_INSTANCE $local_instance
EXCODE=$?
if [ "$EXCODE" != "0" ]; then
	echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
	exit 1
fi


#记录本次编译版本号信息
get_dir_svn_info $local_instance
echo "$CONFIG_INSTANCE:$TMP_SVN_INFO" >>$LOG_FILE
echo "$CONFIG_INSTANCE	$TMP_SVN_INFO" >$local_instance/$CONFIG_VERSION
echo "{\"version\":\"$TMP_SVN_INFO\"}" >$local_instance/$OLD_CONFIG_VERSION

echo -e "$GREEEN 准备发送配置到$REMOTE_SERVER_IP:$REMOTE_SERVER_DIR"
echo -e "删除远程配置"

for v in ${arr_config[@]};do
	ssh -l root $REMOTE_SERVER_IP "cd $REMOTE_SERVER_DIR;
								rm -rf $v;"
done

echo -e "发送配置到远程服务器"

#send config
for v in ${arr_config[@]};do
	rsync -avzP --exclude='*/.svn' $PRJ_CONFIG_DIR/$local_language/$v root@$REMOTE_SERVER_IP:$REMOTE_SERVER_DIR/
done

echo "update_config_to_server:ip=$REMOTE_SERVER_IP,dir=$REMOTE_SERVER_DIR" >>$LOG_FILE
