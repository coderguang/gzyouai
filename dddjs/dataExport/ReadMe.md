1、dataExport.zip解压到对应目录
	---server
		---server_config
	---tool
		---db
			---dataExport(程序)
			---config(配置文件）
			
2、添加执行权限  chomod +x dataExport  
3、执行导号 ./dataExport pid1 pid2 例如(./dataExport 1048577 1048578 1048579)  
4、观察输出是否有报错,无报错时会输出类似下列内容  
	(export data success,file zip: bak/dddjs_20191227_1048577_3.tar.gz)  	
	2019/12/27 08:38:53.206 [info ]  export data success,file zip: bak/dddjs_20191227_1048577_3.tar.gz  
  	2019/12/27 08:38:53.206 [info ]  logger stop....  
  	2019/12/27 08:38:53 sglog.Info [server stop ok,type= 1]  
5、下载对应zip解压到本地导入本地数据库即可.
