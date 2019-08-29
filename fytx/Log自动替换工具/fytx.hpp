#ifndef _FYTX_HPP_
#define _FYTX_HPP_

#include <iostream>
#include <string.h>

using namespace std;

struct log_struct{
	std::string key_world;
	std::string log_content;
	std::string content;
	int double_quotation_mark_num;
	void clear(){
		double_quotation_mark_num=0;
		key_world="";
		log_content="";
		content="";
	}
};

extern "C"{
	extern int yylex(void);
	extern void yyerror(const char* s);
}


#define YYSTYPE log_struct
#define YYDEBUG 1
#define YYERROR_VERBOSE

#endif