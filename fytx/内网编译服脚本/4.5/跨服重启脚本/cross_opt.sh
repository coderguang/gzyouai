#!/bin/bash
server_name=$1
opt=$2
src_server_name=$3
cfg_file=$4

function close_server(){
	srv=$1
	echo "close $srv"
	screen -S "$srv" -p 0 -X stuff "q"$'\n'
}

function start_server(){
	srv=$1
	echo "start $srv ....."
	screen -S "$srv" -p 0 -X stuff "./$srv"$'\n'
}

function rsync_data(){
	src=$1
	dst=$2
	echo "rsync_data"
	rm -rf asserts/*
	rsync -avzP /home/fytx_mixed_s030a/server/assets/ assets/
	rm -rf instance/*
	rsync -avzP /home/fytx_mixed_s030a/server/instance/ instance/
	rm -rf $dst
	echo "copy $src to $dst"
	cp /home/fytx_mixed_s030a/server/$src $dst 
}

function reset_ins_config(){
	cfgfile=$1
	echo "reset instance config $cfgfile"
	rm -rf instance/$cfgfile
	cp $cfgfile instance/
}

echo "server name=$server_name"
echo "opt=$opt"
echo "src_server_name=$src_server_name"
echo "cfg_file=$cfg_file"

if [ $opt -eq 1 ];then
	close_server $server_name
elif [ $opt -eq 2 ];then
	start_server $server_name
elif [ $opt -eq 3 ];then
	rsync_data $src_server_name $server_name 
	reset_ins_config $cfg_file
elif [ $opt -eq 4 ];then
	rsync_data $src_server_name $server_name 
fi
