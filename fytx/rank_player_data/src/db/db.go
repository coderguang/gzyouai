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

func Gen_shell_script(severId string, mongourl string, rankNum int) error {
	dsn := mongourl

	session, err := mgo.Dial(dsn)

	if err != nil {
		sglog.Error("connection mongo db error,dsn:", dsn, ",err:", err)
		return err
	}
	sglog.Info("connection mongo db ok,", dsn)

	db := session.DB(severId)

	rankC := db.C("sg.arena_rank_list")
	rankResult := bson.M{}
	err = rankC.Find(bson.M{}).Select(bson.M{"rank_list": 1}).One(&rankResult)
	if err != nil {
		sglog.Error("rank collections error,err", err)
		sgthread.DelayExit(2)
	}

	sglog.Info("total rank size:", len(rankResult))

	ranklist, ok := rankResult["rank_list"]
	if !ok {
		sglog.Error("rank collections no rank list,err", err)
		sgthread.DelayExit(2)
	}

	rankVec, ok := ranklist.([]interface{})

	if !ok {
		sglog.Error("rank collections not vector,err", err)
		sgthread.DelayExit(2)
	}

	tmpplayerlist := []string{}
	for k, v := range rankVec {
		if k >= rankNum {
			break
		}
		vb, ok := v.(bson.M)
		if ok {
			pi, ok := vb["player_id"]
			if ok {
				piInt, ok := pi.(int)
				if ok {
					tmpplayerlist = append(tmpplayerlist, strconv.Itoa(piInt))
				}
			}
		}
	}

	playerC := db.C("sg.players")

	playerlist := []string{}
	for _, k := range tmpplayerlist {
		var result interface{}
		pi, _ := strconv.Atoi(k)
		err = playerC.Find(bson.M{"pi": pi}).One(&result)
		if err != nil {
			sglog.Error("no this player id", k)
			//continue
		}
		playerlist = append(playerlist, k)
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
		} else if _, ok := files["player_id"]; ok {
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
	fileName := "fytx_" + sgtime.YMDString(now) + "_rank_" + strconv.Itoa(len(playerlist))

	sql_str := gen_script_txt(playerlist, playerCollections, sysCollections, fileName)

	//tar file
	tarfile := "bak/" + fileName + ".tar.gz"
	sql_str += "tar -zcvf " + tarfile + " bak/" + fileName + "\n\n"

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
	sglog.Info("shell output:\n", string(out))

	sglog.Info("export data success,file zip:", tarfile)

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

	//mongoexport -h 10.66.196.77:27017 -u rwuser -p FKWfWIEz6yLtBOP -d sid67 -c sg.world -q "{$or:[{\"pi\":1048577},{\"pid\":1048578}]}"
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
	return "{'pi':{\\$eq:" + player_id + "}" + ",{'player_id':{\\$eq:" + player_id + "}}"
}

func gen_export_collection_str(collectionName string, fileName string) string {
	str := "mongoexport -h " + config.GlobalCfg.DbIp + ":" + config.GlobalCfg.DbPort + " -u " + config.GlobalCfg.DbUser + " -p " + config.GlobalCfg.DbPwd +
		" -d " + config.GlobalCfg.DbName + " -c " + collectionName + " -q {} -o bak/" + fileName + "/" + collectionName + ".json --authenticationMechanism=MONGODB-CR --authenticationDatabase admin\n"

	return str
}
