package main

import (
	"log"
	"os"
	"sensitiveFliter/src/xlsxProcess"

	"github.com/coderguang/GameEngine_go/sgcmd"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
)

func main() {

	sgserver.StartLogServer("debug", "./log/", log.LstdFlags, true)
	sglog.Info("start sensitiveFliter")

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

	xlsxProcess.StartProcessFile(fileList)

	sgcmd.StartCmdWaitInputLoop()
	sgserver.StopLogServer()
}
