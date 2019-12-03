package db

import (
	"dataExport/src/config"
	"strconv"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/globalsign/mgo"
	"github.com/globalsign/mgo/bson"
)

func Gen_shell_script(playerlist []string) error {
	dsn := "mongodb://" + config.GlobalCfg.DbAuth + config.GlobalCfg.DbIp + ":" + config.GlobalCfg.DbPort

	session, err := mgo.Dial(dsn)

	if err != nil {
		sglog.Error("connection mongo db error,dsn:", dsn, ",err:", err)
		return err
	}
	sglog.Info("connection mongo db ok,", dsn)

	db := session.DB(config.GlobalCfg.DbName)

	playerC := db.C("players")

	for _, k := range playerlist {
		var result interface{}
		pi, _ := strconv.Atoi(k)
		err = playerC.Find(bson.M{"pid": pi}).One(&result)
		if err != nil {
			sglog.Error("no this player id", k)
			return err
		}
	}

	collections, err := db.CollectionNames()
	if err != nil {
		sglog.Error("get all collections ,err:", err)
		return err
	}

	sglog.Info("collections:", collections)

	session.Close()

	return nil
}
