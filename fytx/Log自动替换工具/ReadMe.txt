将fytx.exe,start.bat,getPath.bat,replace_log.bat文件拷贝到项目根目录下。
修改replace_log.bat文件内容，将需要替换的log的项目文件名字填入,双击执行replace_log.bat执行即可。

需要修改的文件:
util_lib/Glog
util_lib/GLogColor

net_lib/core 增加 start_log_task,run_log_loop方法