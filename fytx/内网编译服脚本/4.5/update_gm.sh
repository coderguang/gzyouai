#!/bin/sh
home_dir="/home"
gm_dir="/home/web_gm_manager_tornado"
gm_svn_dir="http://10.21.210.43/svn/fytx/project/fytx/server/trunk/gm_tool_util/web_gm_manager_tornado"
config_svn_dir="http://10.21.210.43/svn/fytx/project/fytx/dev_common_res"
gm_pid=`ps -ef | grep "gm" | grep -v grep | awk '{print $2}'`

cd ${home_dir}
#rm -rf ${gm_dir}
svn co ${gm_svn_dir}

#cd ${gm_dir}
#nohup python -u /home/web_gm_manager_tornado/index.py 56789 > log_py_out.log 2>&1 &
