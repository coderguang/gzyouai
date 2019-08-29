set NAME=fytx
set CC=g++
set TOOL_PATH=./

bison -d -t --verbose %NAME%.y
%CC% -c %NAME%.tab.c -std=c++11 -lstdc++
flex -o%NAME%.yy.c %NAME%.l 
%CC% -c -g -w %NAME%.yy.c 
%CC% -g -w %NAME%.tab.o %NAME%.yy.o -o %TOOL_PATH%%NAME%.exe
pause