#!/bin/sh

source ./config.sh

echo "####package#####"
echo "####package#####">>$LOG_FILE

#创建打包对应目录

arr_zip_files=(
	assist 
	bn 
	config 
	game-series 
	merge-tool 
	rename-tool 
	na 
	nb 
	ns
	dc
    kw
)
arr_series=(gg gt dbs)
INFO_TXT=file_info.txt


function create_package_dir(){
	package_root_dir=$1;
	for v in ${arr_zip_files[@]};do
		tmpDir=$1/$v
		test -d $tmpDir||mkdir -p $tmpDir;
	done
}

function rename_bin_file(){
	test -d $PRJ_TEMP_BIN_DIR||mkdir -p $PRJ_TEMP_BIN_DIR
	rsync -avz $PRJ_BIN_DIR/ $PRJ_TEMP_BIN_DIR/
	#rename
	cd $PRJ_TEMP_BIN_DIR
	mv gate_server gt
	mv game_server gg
	mv mysql_server dbs

	mv assist_net_server assist
	mv battle_net_server bn
	mv battle_net_seige_server ns
	mv net_arena_server na
	mv new_battle_net_central_server nbc
	mv new_battle_net_server nb
	mv daily_challenge_system dc
    mv kingdom_war_net_server kw
	enter_shell_dir
}

function update_config(){
	enter_shell_dir
	tmp_language=$1
	cd $PRJ_CONFIG_DIR

	echo "#####update_config:$tmp_language##">>$LOG_FILE

	test -d $tmp_language/$CONFIG_ASSETS||mkdir -p $tmp_language/$CONFIG_ASSETS
	echo "svn --username=$SVN_USER co $SVN_CONFIG_ASSETS $tmp_language/$CONFIG_ASSETS"
	svn --username=$SVN_USER co $SVN_CONFIG_ASSETS $tmp_language/$CONFIG_ASSETS
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
		exit 1
	fi


	get_dir_svn_info $tmp_language/$CONFIG_ASSETS
	echo "$CONFIG_ASSETS		$TMP_SVN_INFO" >$tmp_language/$CONFIG_ASSETS/$CONFIG_VERSION
	echo "{\"version\":\"$TMP_SVN_INFO\"}" >$tmp_language/$CONFIG_ASSETS/$OLD_CONFIG_VERSION

	test -d $tmp_language/$CONFIG_INSTANCE||mkdir -p $tmp_language/$CONFIG_INSTANCE
	echo "svn --username=$SVN_USER co $SVN_CONFIG_INSTANCE $tmp_language/$CONFIG_INSTANCE"
	svn --username=$SVN_USER co $SVN_CONFIG_INSTANCE $tmp_language/$CONFIG_INSTANCE
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
		exit 1
	fi

	get_dir_svn_info $tmp_language/$CONFIG_INSTANCE
	echo "$CONFIG_INSTANCE		$TMP_SVN_INFO" >$tmp_language/$CONFIG_INSTANCE/$CONFIG_VERSION
	echo "{\"version\":\"$TMP_SVN_INFO\"}" >$tmp_language/$CONFIG_INSTANCE/$OLD_CONFIG_VERSION
	enter_shell_dir
}


function zip_series(){
	enter_shell_dir
	tmp_language=$1
	tmp_dir=$PRJ_PACKAGE_DIR/game-series/temp
	test -d $tmp_dir||mkdir -p $tmp_dir
	for v in ${arr_series[@]};do
		rsync -avzP $PRJ_TEMP_BIN_DIR/$v $tmp_dir/$v
	done
	cd $PRJ_CONFIG_DIR/$tmp_language
	for v in ${arr_config[@]};do
		target_dir=../../zip/game-series/temp
		test -d $target_dir/$v||mkdir -p $target_dir/$v
		rsync -avzP --delete --exclude='.svn' $v/ $target_dir/$v
	done
	
	enter_shell_dir
	cd $tmp_dir
	for v in ${arr_series[@]};do
		echo "$v		`./$v -v`" >>$INFO_TXT
	done
	for v in ${arr_config[@]};do
		cat $v/$CONFIG_VERSION >>$INFO_TXT
	done
	echo -e "start package game-series for $tmp_language .."	
	file_name=$VERSION"_"$tmp_language"_game-series_"$now
	zip_file_name=$file_name".zip"
	cp $INFO_TXT ../$file_name"_version.txt"
	zip -r -p $zip_file_name  ./*
	mv $zip_file_name ../
	cd ..
	rm -rf temp
	
	enter_shell_dir
}


function zip_cross(){
	enter_shell_dir
	tmp_language=$1
	prj_name=$2
	need_instance_config=$3
	is_nb=$4
	echo -e "start package $prj_name ..."
	echo -e "need_instance_config:$need_instance_config"
	echo -e "is_nb:$is_nb"
	
	tmp_dir=$PRJ_PACKAGE_DIR/$prj_name/temp
	test -d $tmp_dir||mkdir -p $tmp_dir
	rsync -avzP $PRJ_TEMP_BIN_DIR/$prj_name $tmp_dir/ 
	echo "rsync -avzP $PRJ_TEMP_BIN_DIR/$prj_name $tmp_dir/"
	if [ 1 -eq $is_nb ];then
		rsync -avzP $PRJ_TEMP_BIN_DIR/nbc $tmp_dir/ 
	fi

	cd $PRJ_CONFIG_DIR/$tmp_language
	target_dir=../../zip/$prj_name/temp
	rsync -avzP --delete --exclude='.svn' $CONFIG_ASSETS/ $target_dir/$CONFIG_ASSETS
	if [ 1 -eq $need_instance_config ];then
		rsync -avzP --delete --exclude='.svn' $CONFIG_INSTANCE/ $target_dir/$CONFIG_INSTANCE
	fi
	
	cd $tmp_dir
	echo "$prj_name		`./$prj_name -v`" >>$INFO_TXT
	if [ 1 -eq $is_nb ];then
		echo "nbc		`./nbc -v`" >>$INFO_TXT
		echo "nbc		`./nbc -v`" >>$INFO_TXT
	fi

	
	cat $CONFIG_ASSETS/$CONFIG_VERSION >>$INFO_TXT

	if [ 1 -eq $need_instance_config ];then
	  cat $CONFIG_INSTANCE/$CONFIG_VERSION >>$INFO_TXT
	fi
	
	file_name=$VERSION"_"$tmp_language"_"$prj_name"_"$now
	zip_file_name=$file_name".zip"
	cp $INFO_TXT ../$file_name"_version.txt"
	zip -r -p $zip_file_name  ./*
	mv $zip_file_name ../
	cd ..
	rm -rf temp
	enter_shell_dir
}



function zip_rename_tool(){
	enter_shell_dir
	tmp_dir=$PRJ_PACKAGE_DIR/rename-tool/temp
	pro_name=rename_tool
	test -d $tmp_dir ||mkdir -p $tmp_dir
	rsync -avzP $TOOL_HOME/player_rename_tool/bin/$pro_name $tmp_dir

	tmp_config_dir=$tmp_dir/instance
	svn --username=$SVN_USER co $SVN_RENAME_TOOL_CONFIG $tmp_config_dir
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
		exit 1
	fi

	get_dir_svn_info $tmp_config_dir
	echo "instance	$TMP_SVN_INFO">$tmp_config_dir/$CONFIG_VERSION	
	rm -rf instance/.svn

	cd $tmp_dir
	echo "$pro_name	`./$pro_name -v`" >>$INFO_TXT
	echo "`cat instance/$CONFIG_VERSION`" >>$INFO_TXT

	file_name=$VERSION"_"$LANGUAGE_EX"_rename-tool_"$now
	zip_file_name=$file_name".zip"

	cp $INFO_TXT ../$file_name"_version.txt"
	zip -r -p $zip_file_name ./*
	mv $zip_file_name ../
	rm -rf $tmp_dir
	enter_shell_dir
}


function zip_merge_tool(){
	enter_shell_dir
	tmp_dir=$PRJ_PACKAGE_DIR/merge-tool/temp
	pro_name=server_merge_tool
	test -d $tmp_dir ||mkdir -p $tmp_dir
	rsync -avzP $TOOL_HOME/$pro_name/bin/$pro_name $tmp_dir

	tmp_config_dir=$tmp_dir/instance
	svn --username=$SVN_USER co $SVN_MERGE_TOOL_CONFIG $tmp_config_dir
	EXCODE=$?
	if [ "$EXCODE" != "0" ]; then
		echo -e "从svn更新 $v 文件发生错误，请联系对应的开发人员"
		exit 1
	fi
	

	get_dir_svn_info $tmp_config_dir
	echo "instance	$TMP_SVN_INFO">$tmp_config_dir/$CONFIG_VERSION	
	rm -rf instance/.svn

	cd $tmp_dir
	echo "$pro_name	`./$pro_name -v`" >>$INFO_TXT
	echo "`cat instance/$CONFIG_VERSION`" >>$INFO_TXT

	file_name=$VERSION"_"$LANGUAGE_EX"_merge-tool_"$now
	zip_file_name=$file_name".zip"

	cp $INFO_TXT ../$file_name"_version.txt"
	zip -r -p $zip_file_name ./*
	mv $zip_file_name ../
	rm -rf $tmp_dir
	enter_shell_dir
}

function zip_gm_tool(){
	enter_shell_dir
	tmp_language=$1
	cd $PRJ_BUILD_DIR
	target_dir=$PRJ_PACKAGE_DIR/$GM_TOOL_NAME/temp
	test -d $target_dir||mkdir -p $target_dir
	echo "########rsync gm_tool exclude .svn .idea setting.py"
	rsync -avzP --delete --exclude='.svn' --exclude='.idea' --exclude='setting.py' $GM_TOOL/ $target_dir
	cd $target_dir
	echo "$VERSION">>$INFO_TXT	
	file_name=$VERSION"_"$tmp_language"_"$GM_TOOL_NAME"_"$now
	zip_file_name=$file_name".zip"
	cp $INFO_TXT ../$file_name"_version.txt"
	zip -r -p $zip_file_name  ./*
	mv $zip_file_name ../
	cd ..
	rm -rf temp
	enter_shell_dir
}

#打包流程
function start_all_package(){
	tmp_language=$LANGUAGE_EX
	create_package_dir $PRJ_PACKAGE_DIR
	update_config $tmp_language
	rename_bin_file
	zip_series $tmp_language
	zip_cross $tmp_language assist 0 0
	zip_cross $tmp_language bn 0 0
	zip_cross $tmp_language na 1 0
	zip_cross $tmp_language nb 0 1
	zip_cross $tmp_language ns 0 0 
	zip_cross $tmp_language dc 0 0
    zip_cross $tmp_language kw 0 0
	zip_rename_tool
	zip_merge_tool
	zip_gm_tool $tmp_language
}

###########################################选择执行编译############################
#  0:打包所有文件  1:打包游戏服程序  2:assist  3:bn 4:na 5:nb 6:ns 7:rename_tool 8:server_merge_tool

is_have_update_config=0


for v in ${NEED_PACKAGE_LIST[@]};do
	
	tmp_language=$LANGUAGE_EX
	num=$v
	
	
	#build lib
	if [ $is_have_update_config -eq 0 ];then
		create_package_dir $PRJ_PACKAGE_DIR
		update_config $tmp_language
		is_have_update_config=1
	fi

	rename_bin_file

	if [ $num = "0" ];then
		start_all_package
		break
	elif [ $num = "1" ];then
		zip_series $tmp_language
	elif [ $num = "2" ];then
		zip_cross $tmp_language assist 0 0
	elif [ $num = "3" ];then
		zip_cross $tmp_language bn 0 0
	elif [ $num = "4" ];then
		zip_cross $tmp_language na 1 0
	elif [ $num = "5" ];then
		zip_cross $tmp_language nb 0 1
	elif [ $num = "6" ];then
		zip_cross $tmp_language ns 0 0 
	elif [ $num = "7" ];then
		zip_rename_tool
	elif [ $num = "8" ];then
		zip_merge_tool
	elif [ $num = "9" ];then
		zip_cross $tmp_language dc 0 0
	elif [ $num = "10" ];then
		zip_gm_tool $tmp_language
    elif [ $num = "11" ];then
        zip_cross $tmp_language kw 0 0
	else
		echo "无效的选项,$num"
		exit 1
	fi
done

























