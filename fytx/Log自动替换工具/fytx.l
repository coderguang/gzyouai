%{
#include "fytx.hpp"
#include "fytx.tab.h"
#include <fstream>

extern bool printFlag;

%}

space [ \t]
blank {space}+

LogT "LogT"
LogD "LogD"
LogI "LogI"
LogW "LogW"
LogE "LogE"
LogF "LogF"
LogS "LogS"
LogEnd "LogEnd"
letter [a-zA-Z_]+
digit [0-9]
num [1-9]+[digit]*
newline [\r\n]
identify {letter}+({letter}|{digit})*
identifyex ({letter}|{digit})*
specialletter   [\#\&\^\-\?\/\+\*\(\)\{\}\<\>\\\\]


LogKey ({LogT}|{LogD}|{LogI}|{LogW}|{LogE}|{LogF}|{LogS})


%s _KEY_WORLD_BEGIN_ 
%s _LOG_CONTENT_START_ _LOG_CONTENT_WAIT_END_


%%

<INITIAL>^{space}*{LogKey}{space}*	{
	yylval.clear();
	std::string s=yytext;
	if(printFlag)
		std::cout<<"yylval.text=["<<s<<"]"<<std::endl;
	for(int i=0;i<s.length();i++) {
		if('L'==s[i]){
			yylval.key_world+="N";
		}
		yylval.key_world+=s[i];
		if(printFlag)
			std::cout<<"now is "<<s[i]<<",yylval.key_world=["<<yylval.key_world<<"]"<<std::endl;
	}
	
	yylval.content+=yytext;
	if(printFlag)
		std::cout<<"get key_world:"<<yylval.key_world<<std::endl;
	BEGIN _KEY_WORLD_BEGIN_;
	return TOKEN_KEY_WORLD_;
};

<_KEY_WORLD_BEGIN_>"<<"	{
	//initial content and log content
	BEGIN _LOG_CONTENT_START_;
	if(printFlag)
		std::cout<<"start log content...."<<std::endl;
};

<_KEY_WORLD_BEGIN_>.	{
	yylval.content+=yytext;
	BEGIN INITIAL;
	if(printFlag)
		std::cout<<"key_world:"<<yylval.content<<std::endl;
	return TOKEN_CONTENT_;
};


<_LOG_CONTENT_START_>{space}*"\""	{
	yylval.log_content+=yytext;
	yylval.double_quotation_mark_num+=1;
	if(printFlag)
		std::cout<<"get double_quotation_mark,num="<<yylval.double_quotation_mark_num<<std::endl;
	if(0==yylval.double_quotation_mark_num%2){
		BEGIN _LOG_CONTENT_WAIT_END_;
		if(printFlag)
			std::cout<<"log_content wait end..."<<std::endl;
	}else{
		BEGIN _LOG_CONTENT_START_;
	}
};


<_LOG_CONTENT_START_>{specialletter}	{
	yylval.log_content+=yytext;
};

<_LOG_CONTENT_START_>{newline}*	{
	yylval.log_content+=yytext;
	if(printFlag)
		std::cout<<"newline in log content"<<std::endl;
};


<_LOG_CONTENT_START_>.	{
	yylval.log_content+=yytext;
	if(printFlag)
		std::cout<<"content_start="<<yytext<<std::endl;
	if(0==yylval.double_quotation_mark_num%2){
		BEGIN _LOG_CONTENT_WAIT_END_;
	}else{
		BEGIN _LOG_CONTENT_START_;
	}
};

<_LOG_CONTENT_WAIT_END_>";"	{
	if(printFlag)
		std::cout<<"log end--,"<<yylval.key_world<<"(" <<yylval.log_content<<");";
	BEGIN INITIAL;
	return TOKEN_LOG_CONTENT_;
};

<_LOG_CONTENT_WAIT_END_>"\""	{
	yylval.log_content+="\"";
	yylval.double_quotation_mark_num+=1;
	if(printFlag)
		std::cout<<"wait end get double_quotation_mark,num="<<yylval.double_quotation_mark_num<<std::endl;
	BEGIN _LOG_CONTENT_START_;
};


<_LOG_CONTENT_WAIT_END_>.	{
	yylval.log_content+=yytext;
	if(printFlag)
		std::cout<<"wait_end match all="<<yytext<<std::endl;
};
<_LOG_CONTENT_WAIT_END_>{newline}*	{
	yylval.log_content+=yytext;
	if(printFlag)
		std::cout<<"wait_end newline="<<yytext<<std::endl;
};


.  {
	yylval.content=yytext;
	if(printFlag)
		std::cout<<"match="<<yylval.content<<std::endl;
	return TOKEN_CONTENT_;
};

{newline}*	{
	yylval.content=yytext;
	if(printFlag)
		std::cout<<"newline,all_content="<<yylval.content<<std::endl;
	return TOKEN_CONTENT_;
};

%%

int yywrap(void){
	std::cout<<"read file end"<<std::endl;
	return 1;
}






