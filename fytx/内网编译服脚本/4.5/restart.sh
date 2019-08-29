#!/bin/sh

source ./config.sh

echo "###restart####">>$LOG_FILE

ssh -l root $REMOTE_SERVER_IP "cd $REMOTE_SERVER_DIR;
			sh close.sh;
			sh start.sh;"

