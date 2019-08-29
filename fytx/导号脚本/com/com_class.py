
class playerDataKey:
	def __init__(self,collection_name,key_name):
		self.collectionName=collection_name
		self.keyName=key_name

	def genLinux(self,db_url,db_port,db_name,player_id,save_dir,db_user,db_passwd,is_cloud):
		str="mongoexport -h "+db_url+":"+bytes(db_port)+" -u "+db_user+" -p "+db_passwd+" -d "+db_name+" -c "+self.collectionName\
			+" -q \"{\\\""+self.keyName+"\\\":"+bytes(player_id)\
			+"}\" -o "+save_dir+"/"+bytes(player_id)+"/"+self.collectionName+".json "
		if(is_cloud):
			str+=" --authenticationMechanism=MONGODB-CR --authenticationDatabase admin"
		str+="\n"
		return str
		
	def printMsg(self):
		print "collection: "+self.collectionName.ljust(40)+"\t key: "+self.keyName.ljust(20)