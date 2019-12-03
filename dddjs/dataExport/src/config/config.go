package config

import (
	"errors"
	"io/ioutil"
	"strings"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/robertkrimen/otto"
)

var server_cfg_dir string = "./../../server/server_config/"
var gg_cfg = "gg_cfg.js"

func ReadGGCfg() error {
	config, err := ioutil.ReadFile(server_cfg_dir + gg_cfg)
	if err != nil {
		sglog.Error("read gg config error,err:", err)
		return err
	}
	configfile := string(config)

	configlist := strings.Split(configfile, "gg_cfg")

	if len(configlist) < 2 {
		sglog.Error("parse config file error,in ", server_cfg_dir+gg_cfg, ",config file data:", configfile)
		return errors.New("split cfg file by 'gg_cfg' error")
	}

	configfile = strings.Replace(configfile, configlist[0], "", 1)

	sglog.Info(configfile)

	vm := otto.New()
	_, err = vm.Run(configfile)
	if err != nil {
		sglog.Error("js config error,", err)
		return err
	}

	port, err := vm.Run("gg_cfg.port")
	ports, err := port.ToInteger()
	sglog.Info(ports)

	return nil
}
