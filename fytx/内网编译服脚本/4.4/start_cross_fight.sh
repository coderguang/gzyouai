#!/bin/sh

IP=10.21.210.105
KW=/home/kw_test

opt=$1

function start_fight(){
	dir=$1
	echo "start_fight $srv,dir=$dir"
	ssh -l root $IP "cd $dir;
			sh quickopen.sh;"
}

if [ $opt -eq 1 ];then
	start_fight $KW
fi
