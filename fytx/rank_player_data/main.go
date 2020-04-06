package main

import (
	"dataExport/src/db"
	"log"
	"os"
	"strconv"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
	"github.com/coderguang/GameEngine_go/sgthread"
)

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	arg_num := len(os.Args) - 1
	if arg_num < 1 {
		sglog.Error("please input player id list ")
		sgthread.DelayExit(2)
		return
	}

	serverId := os.Args[1]
	mongourl := os.Args[2]
	rankNum, err := strconv.Atoi(os.Args[3])

	if serverId == "" {
		sglog.Error("server id erros", err)
		sgthread.DelayExit(2)
	}

	if err != nil {
		sglog.Error("rank num error", err)
		sgthread.DelayExit(2)
	}

	if mongourl == "" {
		sglog.Error("mongodb url error", err)
		sgthread.DelayExit(2)
	}

	sglog.Info("export rank data ,mongour:", mongourl, ",num:", rankNum)

	err = db.Gen_shell_script(serverId,mongourl, rankNum)
	if err != nil {
		sglog.Error("gen script ,", err)
		sgthread.DelayExit(2)
		return
	}
	//sgcmd.StartCmdWaitInputLoop()

	sgserver.StopAllServer()
}
