package config

import (
	"io/ioutil"

	"github.com/coderguang/GameEngine_go/sglog"
)

var server_cfg_dir string = "../server/server_config/"
var gg_cfg = "gg_cfg.js"

func ReadGGCfg() {
	config, err := ioutil.ReadFile(server_cfg_dir + gg_cfg)
	if err != nil {
		sglog.Error("read gg config error,err:", err)
		return
	}

	sglog.Info(string(config))
}
