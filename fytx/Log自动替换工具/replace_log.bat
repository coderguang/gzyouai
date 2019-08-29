::@echo off

call:auto_replace_log assist_net_server

call:auto_replace_log battle_net_server

call:auto_replace_log battle_net_seige_server

call:auto_replace_log game_config_data

call:auto_replace_log game_config_data_test

call:auto_replace_log game_def

call:auto_replace_log game_server

call:auto_replace_log gate_server

call:auto_replace_log mysql_server

call:auto_replace_log net_arena_server

call:auto_replace_log net_lib

call:auto_replace_log new_battle_net_central_server

call:auto_replace_log new_battle_net_server

call:auto_replace_log util_lib

pwd
pause
exit

:auto_replace_log
	set run_tools=fytx.exe
	set file_list=path.txt
	set run_script=start.bat
	set file_script=getPath.bat
	set tmpdir=%1
	echo "path is %tmpdir%"
	copy /y %run_tools% %tmpdir%
	copy /y %run_script% %tmpdir%
	copy /y %file_script% %tmpdir%
	cd %tmpdir%
	call start.bat
	del /f %run_tools%
	del /f %run_script%
	del /f %file_script%
	del /f %file_list%
	cd ..
goto:eof