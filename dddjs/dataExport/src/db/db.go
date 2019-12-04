package db

import (
	"dataExport/src/config"
	"os"
	"os/exec"
	"strconv"

	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgthread"
	"github.com/coderguang/GameEngine_go/sgtime"
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

	//查找具有 pid 的 collection

	piCollections := []string{}
	for _, v := range collections {
		collcectionRef := db.C(v)
		counts, err := collcectionRef.Find(nil).Count()
		if err != nil {
			sglog.Error("count collection ", v, " failed,", err)
		}
		if counts == 0 {
			sglog.Debug("collection ", v, " no data")
			continue
		}

		files := bson.M{}
		err = collcectionRef.Find(nil).One(&files)
		if err != nil {
			sglog.Error("get collection ", v, " files error,", err)
		}

		if _, ok := files["pid"]; ok {
			piCollections = append(piCollections, v)
		}

	}

	//需要根据pid获取的表数据
	playerCollections := []string{}

	for _, k := range piCollections {
		needIgnore := false
		for _, ignoreV := range config.GlobalCollectionCfg.Ignores {
			if k == ignoreV {
				needIgnore = true
				break
			}
		}
		if needIgnore {
			continue
		}
		for _, ignoreV := range config.GlobalCollectionCfg.AllGet {
			if k == ignoreV {
				needIgnore = true
				break
			}
		}
		if needIgnore {
			continue
		}
		playerCollections = append(playerCollections, k)
	}

	sysCollections := []string{}
	for _, v := range config.GlobalCollectionCfg.AllGet {
		collcectionRef := db.C(v)
		counts, err := collcectionRef.Find(nil).Count()
		if err != nil {
			sglog.Error("system count collection ", v, " failed,", err)
		}
		if counts == 0 {
			sglog.Debug("system collection ", v, " no data")
			continue
		}
		sysCollections = append(sysCollections, v)
	}

	sglog.Info("player collections:", playerCollections)
	sglog.Info("system collection", config.GlobalCollectionCfg.AllGet)

	now := sgtime.New()
	fileName := "dddjs_" + sgtime.YMDString(now) + "_" + playerlist[0] + "_" + strconv.Itoa(len(playerlist))

	sql_str := gen_script_txt(playerlist, playerCollections, sysCollections, fileName)

	//tar file
	sql_str += "tar -zcvf bak/" + fileName + ".tar.gz bak/" + fileName + "\n\n"

	shell_file, err := os.OpenFile(fileName+".sh", os.O_RDWR|os.O_CREATE, 0666)
	if err != nil {
		sglog.Error("create shell file error,", err)
		return err
	}
	defer shell_file.Close()

	shell_file.WriteString(sql_str)

	sgthread.SleepBySecond(2)

	cmd := exec.Command("bash", fileName+".sh")
	out, err := cmd.Output()
	if err != nil {
		sglog.Error("do mongoexport failed:", err)
		return err
	}
	sglog.Info("shell output:\n", out)

	sglog.Info("export data success,file zip: bak/", fileName, ".tar.gz")

	session.Close()

	return nil
}

func gen_script_txt(playerlist []string, playerCollections []string, allgetCollections []string, fileName string) string {
	str := ""
	for _, v := range playerCollections {
		str += gen_export_player_str(playerlist, v, fileName)
	}
	for _, v := range allgetCollections {
		str += gen_export_collection_str(v, fileName)
	}
	return str
}

func gen_export_player_str(playerlist []string, collectionName string, fileName string) string {

	//mongoexport -h 10.66.196.77:27017 -u rwuser -p FKWfWIEz6yLtBOP -d sid67 -c sg.world -q "{$or:[{\"pid\":1048577},{\"pid\":1048578}]}"
	// -o bak/391122513/sg.world.json  --authenticationMechanism=MONGODB-CR --authenticationDatabase admin

	playerIdListStr := "\"{\\$or:["
	for i, v := range playerlist {
		if i == 0 {
			playerIdListStr += gen_player_id_sql(v)
		} else {
			playerIdListStr += "," + gen_player_id_sql(v)
		}
	}
	playerIdListStr += "]}\""

	str := "mongoexport -h " + config.GlobalCfg.DbIp + ":" + config.GlobalCfg.DbPort + " -u " + config.GlobalCfg.DbUser + " -p " + config.GlobalCfg.DbPwd +
		" -d " + config.GlobalCfg.DbName + " -c " + collectionName + " -q " + playerIdListStr + " -o bak/" + fileName + "/" + collectionName + ".json --authenticationMechanism=MONGODB-CR --authenticationDatabase admin\n"

	return str
}

func gen_player_id_sql(player_id string) string {
	return "{'pid':{\\$eq:" + player_id + "}}"
}

func gen_export_collection_str(collectionName string, fileName string) string {
	str := "mongoexport -h " + config.GlobalCfg.DbIp + ":" + config.GlobalCfg.DbPort + " -u " + config.GlobalCfg.DbUser + " -p " + config.GlobalCfg.DbPwd +
		" -d " + config.GlobalCfg.DbName + " -c " + collectionName + " -q {} -o bak/" + fileName + "/" + collectionName + ".json --authenticationMechanism=MONGODB-CR --authenticationDatabase admin\n"

	return str
}
