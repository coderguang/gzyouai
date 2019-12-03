package db

import (
	"dataExport/src/config"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/globalsign/mgo"
	"github.com/globalsign/mgo/bson"
)

func Gen_shell_script() error {
	dsn := "mongodb://" + config.GlobalCfg.DbAuth + config.GlobalCfg.DbIp + ":" + config.GlobalCfg.DbPort

	session, err := mgo.Dial(dsn)

	if err != nil {
		sglog.Error("connection mongo db error,dsn:", dsn, ",err:", err)
		return err
	}
	sglog.Info("connection mongo db ok,", dsn)

	db := session.DB(config.GlobalCfg.DbName)

	c := db.C("hangups")

	result := bson.M{}
	err = c.Find(nil).One(&result)
	if err != nil {
		sglog.Error(err)
		return err
	}

	session.Close()

	return nil
}
