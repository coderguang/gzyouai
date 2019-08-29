%{
	
#include "fytx.hpp"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <vector>
using namespace std;

extern FILE *yyin;
extern FILE *yyout;

static std::string all_content;

bool printFlag=false;

%}

%token <key_world> TOKEN_KEY_WORLD_  
%token <log_content> TOKEN_LOG_CONTENT_ 
%token <content> TOKEN_CONTENT_

%%

program : program log_statement|log_statement|program content|content;

log_statement: TOKEN_KEY_WORLD_ TOKEN_LOG_CONTENT_
{
	std::string key_world_str=$1;
	std::string log_content_str=$2;
	std::string log_str=key_world_str+"("+log_content_str+");";
	all_content+=log_str;
	if(printFlag)
		std::cout<<"yacc match log:"<<log_str<<std::endl;
}|TOKEN_KEY_WORLD_{};

content: TOKEN_CONTENT_ {
	std::string tmp_content=$1;
	if(printFlag)
		std::cout<<"yacc match tmp_content="<<tmp_content<<std::endl;
	all_content+=tmp_content;
};

%%

void yyerror(const char* s){
	std::cout<<"meet error:"<<s<<std::endl;
}

int main(int argc,char **argv){

	/**
	//for test
	FILE* fp=fopen("t.txt","rw");
	if(NULL==fp){
		std::cout<<"cant open file:t.txt"<<std::endl;
		return 1;
	}
	yyin=fp;
	yyparse();
	fclose(fp);
	std::string outputfile="tt.txt";
	ofstream frewrite;
	frewrite.open(outputfile.c_str());
	frewrite<<all_content;
	frewrite.flush();
	frewrite.close();

	std::cout<<"all_content="<<all_content<<std::endl;
	cin.get();
	return 0;
	*/

	std::cout<<"start auto replace..."<<std::endl;
	ifstream pathfile;
	pathfile.open("path.txt");
	if(!pathfile.is_open())
		std::cout<<"cant get path.txt file"<<std::endl;

	std::vector<std::string> fileList;
	std::string fileName;
	while(getline(pathfile,fileName)){
		//std::cout<<"file path:"<<fileName<<std::endl;
		fileList.push_back(fileName);
	}

	for(int i=0;i<fileList.size();i++){
		all_content="";
		std::string name=fileList[i];
		std::cout<<"start auto replace ,file="<<name<<std::endl;
		FILE* fp=fopen(name.c_str(),"rw");
		if(NULL==fp){
			std::cout<<"cant open file:"<<name<<std::endl;
			return 1;
		}
		yyin=fp;
		yyparse();
		fclose(fp);
		std::string outputfile=name.c_str();
		ofstream frewrite;
		frewrite.open(outputfile.c_str());
		frewrite<<all_content;
		frewrite.flush();
		frewrite.close();
		std::cout<<"rewrite "<<name<<"  complete!"<<std::endl;
	}
	return 0;
}