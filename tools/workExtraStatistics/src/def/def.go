package def

import (
	"sort"

	"github.com/coderguang/GameEngine_go/sglog"
)

type SWorkExtraData struct {
	Name    string
	Time    string
	Content string
}

func (data *SWorkExtraData) Show() {
	sglog.Info("who:%s", data.Name)
	sglog.Info("time:%s", data.Time)
	sglog.Info("content:%s", data.Content)
}

type SPeopleData struct {
	Name    string
	WorkMap map[string]*SWorkExtraData
}

func (data *SPeopleData) Show() {
	sglog.Info("who:%s", data.Name)

	timelist := []string{}

	for k, _ := range data.WorkMap {
		timelist = append(timelist, k)
	}

	sort.Strings(timelist)

	for k := range timelist {
		v, ok := data.WorkMap[timelist[k]]
		if ok {
			sglog.Info("time:%s,content:%s", v.Time, v.Content)
		}
	}

	sglog.Info("show name %s complete,size=%d", data.Name, len(data.WorkMap))

}
