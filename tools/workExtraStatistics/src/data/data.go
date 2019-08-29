package data

import (
	"workExtraStatistics/src/def"

	"github.com/coderguang/GameEngine_go/sglog"
)

var dataMap map[string]*def.SPeopleData

func init() {
	dataMap = make(map[string]*def.SPeopleData)
}

func AddWorkExtraData(data *def.SWorkExtraData) {
	v, ok := dataMap[data.Name]
	if ok {
		v.WorkMap[data.Time] = data
	} else {
		tmp := new(def.SPeopleData)
		tmp.Name = data.Name
		tmp.WorkMap = make(map[string]*def.SWorkExtraData)
		tmp.WorkMap[data.Time] = data
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
