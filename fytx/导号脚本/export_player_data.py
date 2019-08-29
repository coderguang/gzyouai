

from com.com_func import *
import sys

def one_key_export():
	if(len(sys.argv)<2):
		print "stop: not get player_id,like python one_key_export 6406878 "
		return 
	target_player_id=sys.argv[1]
	if(not target_player_id.isdigit()):
		print "stop not a correct player_id"
		return 
	tid=int(target_player_id)
	export_player_data(tid)



#use like python one_key_export 6406878
one_key_export()
