package data

import (
	"dailyReport/src/def"

	"github.com/coderguang/GameEngine_go/sglog"
)

var dataMap map[string]*def.SPeopleData

func init() {
	dataMap = make(map[string]*def.SPeopleData)
}

func AddWorkExtraData(data *def.SWorkExtraData) {
	v, ok := dataMap[data.Name]
	if ok {
		v.WorkMap = append(v.WorkMap, data)
	} else {
		tmp := new(def.SPeopleData)
		tmp.Name = data.Name
		tmp.WorkMap = []*def.SWorkExtraData{data}
		dataMap[data.Name] = tmp
	}
}

func ResetData() {
	dataMap = nil
	dataMap = make(map[string]*def.SPeopleData)
}

func ShowAll() {
	for _, v := range dataMap {
		v.Show()
		sglog.Debug("============================end show============")
	}
}

func GetDataMap() map[string]*def.SPeopleData {
	return dataMap
}
