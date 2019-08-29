package main

import (
	"log"
	"os"
	"workExtraStatistics/src/scanner"

	"github.com/coderguang/GameEngine_go/sgcmd"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
)

func main() {

	sgserver.StartLogServer("debug", "./log/", log.LstdFlags, true)
	sglog.Info("start statistic work extra info")

	arg_num := len(os.Args) - 1
	if arg_num < 1 {
		sglog.Error("please input config file ")
		return
	}

	fileList := []string{}
	for index, v := range os.Args {
		if index == 0 {
			continue
		}
		fileList = append(fileList, v)
	}

	scanner.StartParseFileList(fileList)

	sgcmd.StartCmdWaitInputLoop()
	sgserver.StopLogServer()
}
