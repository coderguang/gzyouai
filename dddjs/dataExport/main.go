package main

import (
	"dataExport/src/config"
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

	playerlist := []string{}
	for index, v := range os.Args {
		if index == 0 {
			continue
		}
		_, err := strconv.Atoi(v)
		if err != nil {
			sglog.Error("player id ", v, " not a valid pi")
			sgthread.DelayExit(2)
			return
		}

		playerlist = append(playerlist, v)
	}

	sglog.Info("export player list:", playerlist)

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

	err = db.Gen_shell_script(playerlist)
	if err != nil {
		sglog.Error("gen script ,", err)
		sgthread.DelayExit(2)
		return
	}

	//sgcmd.StartCmdWaitInputLoop()

	sgserver.StopAllServer()
}
