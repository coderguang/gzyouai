package main

import (
	"dataExport/src/config"
	"log"

	"github.com/coderguang/GameEngine_go/sgcmd"
	"github.com/coderguang/GameEngine_go/sgserver"
)

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	config.ReadGGCfg()

	sgcmd.StartCmdWaitInputLoop()
}
