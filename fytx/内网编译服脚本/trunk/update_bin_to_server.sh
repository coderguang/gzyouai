#!/bin/sh


source ./config.sh

echo "upate_bin_to_server:ip=$REMOTE_SERVER_IP,dir=$REMOTE_SERVER_DIR" >>$LOG_FILE


#delete remote file
echo "删除远程程序"

for v in ${arr_all_srv[@]};do
	ssh -l root $REMOTE_SERVER_IP "cd $REMOTE_SERVER_DIR;
			rm -rf $v;"
done

echo "发送数据到远程"

#send bin file
for v in ${arr_all_srv[@]};do
	rsync -avzP $PRJ_BIN_DIR/$v root@$REMOTE_SERVER_IP:$REMOTE_SERVER_DIR/
done

ssh -l root $REMOTE_SERVER_IP "cd $REMOTE_SERVER_DIR;
                        mv game_server gg;
                        mv gate_server gt;
                        mv mysql_server dbs;"
