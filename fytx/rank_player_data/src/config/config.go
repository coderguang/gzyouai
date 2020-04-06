package config

import (
	"dataExport/src/define"
	"errors"
	"io/ioutil"
	"strings"

	"github.com/coderguang/GameEngine_go/sgcfg"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/robertkrimen/otto"
)

func init() {
	GlobalCfg = new(define.SDbCfg)
	GlobalCollectionCfg = new(define.CollectionCfg)
}

var server_cfg_dir string = "./../../server/server_config/"
var gg_cfg = "gg_cfg.js"

var GlobalCfg *define.SDbCfg
var GlobalCollectionCfg *define.CollectionCfg

func getVarValue(key string, vm *otto.Otto) (string, error) {
	value, err := vm.Run(key)
	if err != nil {
		sglog.Error("get ", key, " error,", err)
		return "", err
	}
	//sglog.Info(key, "=", value)
	valuestr, err := value.ToString()
	if err != nil {
		sglog.Error(key, "can't transfrom to target error,", err)
		return "", err
	}
	return valuestr, nil
}

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

	//sglog.Info(configfile)

	vm := otto.New()
	_, err = vm.Run(configfile)
	if err != nil {
		sglog.Error("js config error,", err)
		return err
	}

	keylist := []string{"gg_cfg.db_ip", "gg_cfg.db_name", "gg_cfg.db_port", "gg_cfg.db_auth", "gg_cfg.db_option"}

	for index, v := range keylist {
		value, err := getVarValue(v, vm)
		if err != nil {
			return err
		}
		switch index {
		case 0:
			GlobalCfg.DbIp = value
		case 1:
			GlobalCfg.DbName = value
		case 2:
			GlobalCfg.DbPort = value
		case 3:
			GlobalCfg.DbAuth = value
		case 4:
			GlobalCfg.DbOption = value
		}

	}

	GlobalCfg.SplitAuth()

	sglog.Info("cfg:", GlobalCfg)

	return nil
}

func ReadCollectionCfg() error {
	return sgcfg.ReadCfg("./config/collection.json", GlobalCollectionCfg)
}
