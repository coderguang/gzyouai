

from pymongo import MongoClient
import os
import json
import re
import MySQLdb
import time

PLAYERID_STR="player_id"
NAME_STR="nn"
PLAYER_DB_NAME="sg.player"
server_config="./server_config/gg.json"
mysql_config="./server_config/server.json"


def connect_mongo(mongo_addr,db_name):
	print "connect_mongo:",mongo_addr
	conn=MongoClient(mongo_addr)
	db=conn[db_name]
	return db
	
	
def get_all_collections(db):
	return db.collection_names()
	

def get_mongo_info_and_db_name():
	with open(server_config,'r') as f:
		temp=json.loads(f.read())
		return temp["mongodb"],temp["server_id"]

def get_mongo_login_info(mongo_addr):

	user_name=""
	user_passwd=""
	db_url=""
	db_port=""
	is_cloud=False

	tmp_addr=mongo_addr
	ignore_head=re.split(':\/\/',tmp_addr)
	if(len(ignore_head)==2):
		key_info=ignore_head[1]
		main_info=re.split('@',key_info)
		if(2==len(main_info)):
			login_info=re.split(':',main_info[0])
			if(2==len(login_info)):
				user_name=login_info[0]
				user_passwd=login_info[1]
			url_info=re.split('\/',main_info[1])
			#print 'url_info',url_info
			if(2==len(url_info)):
				is_cloud=True
			url_detal=re.split(':',url_info[0])
			if(2==len(url_detal)):
				db_url=url_detal[0]
				db_port=url_detal[1]

	return user_name,user_passwd,db_url,db_port,is_cloud


def get_mysql_login_info():
	
	addressOfMysqlRaw=""
	mysqlDbName=""
	addressOfMysql=""
	mysqlUser=""
	mysqlPw=""
	mysqlPortStr=""

	with open(mysql_config,'r') as f:
		temp=json.loads(f.read())
		addressOfMysqlRaw=temp["addressOfMysql"]
		mysqlDbName=temp["mysqlDbName"]
		mysqlUser=temp["mysqlUser"]
		mysqlPw=temp["mysqlPw"]
	ignore_head=re.split(':',addressOfMysqlRaw)
	if(len(ignore_head)==2):
		addressOfMysql=ignore_head[0]
		mysqlPortStr=ignore_head[1]
	else:
		print "default msyqladdr raw data =",addressOfMysqlRaw,", after split:",ignore_head
		addressOfMysql=ignore_head[0]
		mysqlPortStr="3306"

	if None==mysqlPw:
		mysqlPw=""

	mysqlPort=int(mysqlPortStr)
	return mysqlDbName,addressOfMysql,mysqlUser,mysqlPw,mysqlPort

	
def name_statistics():	
	print "start name_statistics"
	#get mongo info from config
	mongo_addr,server_id=get_mongo_info_and_db_name()
	#print config
	print "mongo address:",mongo_addr.ljust(100)
	print "server_id:",server_id
	db_name="sid"+bytes(server_id)


	if(not mongo_addr):
		print "null mongo address config,stop."
		return 

	user_name,user_passwd,db_url,db_port,is_cloud=get_mongo_login_info(mongo_addr)

	print "mongo login info: is_cloud:",is_cloud
	print "user_name:",user_name," passwd:",user_passwd," url:",db_url," port:",db_port

	if(not db_url or not db_port):
		print "error db_url or db_port"
		return 

	mysqlDbName,addressOfMysql,mysqlUser,mysqlPw,mysqlPort=get_mysql_login_info()
	print "mysqlDbName:",mysqlDbName,"  addressOfMysql:",addressOfMysql,"  mysqlUser:",mysqlUser,"  mysqlPw:",mysqlPw,"  mysqlPort:",mysqlPort

	if(not mysqlDbName or not addressOfMysql or not mysqlUser or not mysqlPort):
		print "error mysql config"
		return

	#mongo connection
	db=connect_mongo(mongo_addr,db_name)
	collections=db.collection_names()
	collections.sort()
	
	if(len(collections)<=0):
		print "null collections,please check db_name"
		return 
	try:
		mysqlconn=MySQLdb.connect(host=addressOfMysql,user=mysqlUser,passwd=mysqlPw,port=mysqlPort,db=mysqlDbName,use_unicode=True, charset="utf8")
	except MySQLdb.Error as e:
		print(e)
		print("connect to mysql db error")
		return

	item_pi=db[PLAYER_DB_NAME].find({},{PLAYERID_STR:1,NAME_STR:1})	

	str_t=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
	get_num=0
	params=[]

	print 'get data from mongo ok,start insert to mysql.....,now is ',str_t

	for item in item_pi:
		get_num+=1
		pi=str(item[PLAYERID_STR])
		name=item[NAME_STR]
		#print pi,"=",name,"\n"
		params.append([pi,server_id,name,str_t])

	print 'do insert action,size= ',len(params) ##',detail=',params

	try:
		sql='INSERT INTO log_name_tongji (log_user,log_server,f1,log_time,log_type,log_channel,log_data,log_result) values (%s,%s,%s,%s,\'0\',\'0\',\'0\',\'0\')'
		cur = mysqlconn.cursor()
		cur.executemany(sql, params)
		mysqlconn.commit()
		if cur:
			cur.close()
	except Exception as e:
		print "do insert caught error,error=",e
		mysqlconn.rollback()

	if mysqlconn:
		mysqlconn.close()
	print '[insert_by_many executemany] total:',len(params)
	print 'name_statistics complete'
	

name_statistics()

			