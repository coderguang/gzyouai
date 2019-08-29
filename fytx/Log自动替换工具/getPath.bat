@echo off & setlocal EnableDelayedExpansion  
set PATH_NAME=path.txt
cd .>%PATH_NAME%
for /f "delims=" %%i in ('"dir /a/s/b/on *.h"') do (  
set file=%%~fi  
set file=!file:/=/!  
echo !file! >>%PATH_NAME%  
)
for /f "delims=" %%i in ('"dir /a/s/b/on *.cpp"') do (  
set file=%%~fi  
set file=!file:/=/!  
echo !file! >>%PATH_NAME%  
)