package main

import (
	"log"
	"sort"
	"strings"

	"github.com/coderguang/GameEngine_go/sgcmd"
	"github.com/coderguang/GameEngine_go/sgfile"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgserver"
)

func CountProto(file string) {

	fileDir := "./data/" + file
	contents, err := sgfile.GetFileContentAsStringLines(fileDir)
	if err != nil {
		sglog.Error("read txt file error,file:", fileDir, ",err=", err)
		return
	}
	protoMap := make(map[string]int)
	keyList := []string{}
	for _, v := range contents {
		strlist := strings.Split(v, ",protocol_id:")
		if len(strlist) == 2 {
			protoId := strlist[1]

			newKey := true
			for _, vv := range keyList {
				if vv == protoId {
					newKey = false
					break
				}
			}
			if newKey {
				keyList = append(keyList, protoId)
			}

			if curNum, ok := protoMap[protoId]; ok {
				protoMap[protoId] = curNum + 1
			} else {
				protoMap[protoId] = 1
			}

		} else {
			//sglog.Error("can't split,", v)
		}
	}

	sort.Strings(keyList)

	for k, v := range keyList {
		sglog.Debug("protocol_id:", keyList[k], ",num:", protoMap[v])
	}

	// for k, v := range protoMap {
	// 	sglog.Debug("protocol_id:", k, ",num:", v)
	// }
	sglog.Info("count file ", fileDir, " complete")
}

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	CountProto("hero_fight_ios.log")

	CountProto("hero_fight_android.log")

	sgcmd.StartCmdWaitInputLoop()
	sgserver.StopAllServer()
}
