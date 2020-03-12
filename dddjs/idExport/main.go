package main

import (
	"idExport/src/config"
	"idExport/src/db"
	"log"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
	"github.com/coderguang/GameEngine_go/sgthread"
)

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	sglog.Info("start export player ids:")

	err := config.ReadGGCfg()
	if err != nil {
		sglog.Error("parse gg_cfg.js error,", err)
		sgthread.DelayExit(2)
		return
	}

	err=db.Export_ids()
	if err != nil {
		sglog.Error("export ids error,", err)
		sgthread.DelayExit(2)
		return
	}


	sgserver.StopAllServer()
}
