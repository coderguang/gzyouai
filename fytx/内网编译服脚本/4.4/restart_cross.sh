#!/bin/sh

IP=10.21.210.105
ASSIST=/home/fytx_mixed_s030a/server
NB=/home/nb_test
NBC=/home/nbc_test
NA=/home/na_test
BN=/data/fytx_103bn_s001a/server
NS=/home/ns_test
DC=/home/dc_test
KW=/home/kw_test

opt=$1

function restart_cross(){
	dir=$1
	srv=$2
	echo "restart $srv,dir=$dir"
	ssh -l root $IP "cd $dir;
			sh cross_opt.sh $srv 1;
			sh cross_opt.sh $srv 2;"
}

function restart_cross_rsync_data(){
	dir=$1
	srv=$2
	src=$3
	cfg=$4
	echo "restart $srv,dir=$dir"
	ssh -l root $IP "cd $dir;
			sh cross_opt.sh $srv 3 $src $cfg;
			sh cross_opt.sh $srv 1;
			sh cross_opt.sh $srv 2;"

}

function restart_cross_rsync_data_no_ins(){
	dir=$1
	srv=$2
	src=$3
	echo "dir=$dir"
	echo "screen=$srv"
	echo "srcexe=$src"
	echo "restart $srv,dir=$dir"
	ssh -l root $IP "cd $dir;
			sh cross_opt.sh $srv 4 $src ;
			sh cross_opt.sh $srv 1;
			sh cross_opt.sh $srv 2;"

}

function restart_cross_rsync_data_local(){
	dir=$1
	srv=$2
	src=$3
	cfg=$4
	echo "dir=$dir"
	echo "screen=$srv"
	echo "srcexe=$src"
	echo "cfg=$cfg"
	echo "restart $srv,dir=$dir"
	cd $dir;
	sh cross_opt_103.sh $srv 3 $src $cfg;
	sh cross_opt_103.sh $srv 1;
	sh cross_opt_103.sh $srv 2;
}

function restart_cross_rsync_data_local_ex(){
	dir=$1
	srv=$2
	src=$3
	cfg=$4
	echo "dir=$dir"
	echo "screen=$srv"
	echo "srcexe=$src"
	echo "cfg=$cfg"
	echo "restart $srv,dir=$dir"
	cd $dir;
	sh cross_opt_103.sh $srv 4 $src;
	sh cross_opt_103.sh $srv 1;
	sh cross_opt_103.sh $srv 2;

}

if [ $opt -eq 1 ];then
	restart_cross $ASSIST assist
elif [ $opt -eq 2 ];then
	restart_cross_rsync_data $NB nb_test new_battle_net_server new_battle_net_server_cfg.json
elif [ $opt -eq 3 ];then
	restart_cross_rsync_data $NBC nbc_test new_battle_net_central_server new_battle_central_server_cfg.json
elif [ $opt -eq 4 ];then
	restart_cross_rsync_data $NA na_test  net_arena_server net_arena_server_cfg.json
elif [ $opt -eq 5 ];then
	restart_cross_rsync_data_local $BN fytx_103bn_s001a_bn battle_net_server battle_net_cfg.json
elif [ $opt -eq 6 ];then
	restart_cross_rsync_data $NS ns battle_net_seige_server net_seige_server_cfg.json
elif [ $opt -eq 7 ];then
	restart_cross_rsync_data $DC dc_test daily_challenge_system
elif [ $opt -eq 8 ];then
    restart_cross_rsync_data $KW kw_test kingdom_war_net_server
fi
