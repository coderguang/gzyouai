#!/bin/sh

source ./config.sh

echo "###restart####">>$LOG_FILE

ssh -l root $REMOTE_SERVER_IP "cd /home/$REMOTE_SERVER_NAME/py_service;
			sh login_service.sh restart;"

