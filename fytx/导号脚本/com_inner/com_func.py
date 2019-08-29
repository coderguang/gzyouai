

from pymongo import MongoClient
from com_class import *
import os
import json
import re

PI_STR="pi"
PLAYERID_STR="player_id"
server_config="../server_config/gg.json"
shell_dir="gen_linux"

def connect_mongo(mongo_addr,db_name):
	print "connect_mongo:",mongo_addr
	conn=MongoClient(mongo_addr)
	print "show dbs:"
	for i in conn.database_names(): 
		print i
	db=conn[db_name]
	return db
	
	
def get_all_collections(db):
	return db.collection_names()

def gen_linux_export_script(db_url,db_port,db_name,player_id,exportfile_list,save_dir,db_user,db_passwd,is_cloud):
	isExist=os.path.exists(shell_dir)
	if not isExist:
		print "mkdir ",shell_dir
		os.makedirs(shell_dir)
	file_name=shell_dir+"/export_"+db_name+"_"+bytes(player_id)+"_data.sh"
	fo=open(file_name,"w+")
	for item in exportfile_list:
		fo.write(item.genLinux(db_url,db_port,db_name,player_id,save_dir,db_user,db_passwd,is_cloud))
	fo.write("tar -zcvf "+save_dir+"/"+db_name+"."+bytes(player_id)+".tar.gz "+save_dir+"/"+bytes(player_id)+"\n")
	fo.close()

	
	
def del_player_data(db_url,db_port,db_name,player_id):
	db=connect_mongo(db_url,db_port,db_name)
	collections=get_all_collections(db)
	collections.sort()
	del_num=0
	for col in collections:
		tmp_col=db[col]
		is_delete=False
		for item in tmp_col.find({PI_STR:{'$exists':True}}):
			tmp_col.remove({PI_STR:player_id})
			is_delete=True
			break
		for item in tmp_col.find({PLAYERID_STR:{'$exists':True}}):
			tmp_col.remove({PLAYERID_STR:player_id})
			is_delete=True
			break
		if(is_delete):
			print "delete from ",col," complete!"
			del_num+=1
			
	print "total collections:",len(collections)," del data collections:",del_num
	
		

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

	
def export_player_data(player_id):	
	print "start export player_id:",player_id," data"
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
	print "mongo addr:",mongo_addr," db_name:",db_name

	#mongo connection
	db=connect_mongo(mongo_addr,db_name)
	collections=db.collection_names()
	print "collections:",collections
	collections.sort()
	
	if(len(collections)<=0):
		print "null collections,please check db_name"
		return 
	
	#get which collections should export
	col_num=0
	exportlist=[]
	exportfile=[]
	for col in collections:
		#print "start export:",col
		col_num+=1
		item_pi=db[col].find({PI_STR:player_id})		
		is_get_num=0
		for item in item_pi:
			is_get_num+=1
			exportlist.append(col)
			exportfile.append(playerDataKey(col,PI_STR))
			break
			
		if(0==is_get_num):
			item_player_id=db[col].find({PLAYERID_STR:player_id})
			for item in item_player_id:
				is_get_num+=1
				exportlist.append(col)
				exportfile.append(playerDataKey(col,PLAYERID_STR))
				break

	print "export collections total:",col_num,"  data total:",len(exportlist)
	
	if(len(exportlist)<=0):
		print "no any data in this db,stop export!please check player_id:"
		return
	#gen shell script for export
	if(len(exportfile)>0):
			gen_linux_export_script(db_url,db_port,db_name,player_id,exportfile,"bak",user_name,user_passwd,is_cloud)
	
	shell_command="sh "+shell_dir+"/export_"+db_name+"_"+bytes(player_id)+"_data.sh"
	os.system(shell_command)

	info_str="export player_id:"+bytes(player_id)+" data end,json_data in bak/"+db_name+"."+bytes(player_id)+".tar.gz"
	print info_str
	
	
	

			