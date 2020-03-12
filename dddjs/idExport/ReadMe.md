1、dataExport.zip解压到对应目录  
	---server  
        ---------server_config  
	---tool  
	---------db  
	------------dataExport(程序)  
	------------config(配置文件）  
			
2、添加执行权限  chomod +x dataExport  
3、执行导号 ./dataExport pid1 pid2 例如(./dataExport 1048577 1048578 1048579)  
4、观察输出是否有报错,无报错时会输出类似下列内容  
	(export data success,file zip: bak/dddjs_20191227_1048577_3.tar.gz)  	
	2019/12/27 08:38:53.206 [info ]  export data success,file zip: bak/dddjs_20191227_1048577_3.tar.gz  
  	2019/12/27 08:38:53.206 [info ]  logger stop....  
  	2019/12/27 08:38:53 sglog.Info [server stop ok,type= 1]  
5、下载对应zip解压到本地导入本地数据库即可.



6、config内的collection.json文件配置说明：  
	get内的表名为整表导出  
	ingore内的表为直接忽略  
	数据库内的其他表，根据pid进行匹配,符合输入玩家id的数据才会被导出  
	不需要配置mongo地址等配置,程序会自动读取server下的相应配置，但要保证程序所在路径正确
	
7、编译方式:
	安装go，开启go mod
	执行 go build 即可