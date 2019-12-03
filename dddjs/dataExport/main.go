package main

import (
	"dataExport/src/config"
	"dataExport/src/db"
	"log"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
	"github.com/coderguang/GameEngine_go/sgthread"
)

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	err := config.ReadGGCfg()
	if err != nil {
		sglog.Error("parse gg_cfg.js error,", err)
		sgthread.DelayExit(2)
		return
	}

	err = config.ReadCollectionCfg()
	if err != nil {
		sglog.Error("parse collection.json error,", err)
		sgthread.DelayExit(2)
		return
	}

	err = db.Gen_shell_script()
	if err != nil {
		sglog.Error("gen script ,", err)
		sgthread.DelayExit(2)
		return
	}

	//sgcmd.StartCmdWaitInputLoop()

	sgserver.StopAllServer()
}
