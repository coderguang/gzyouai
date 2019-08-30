package def

import (
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
	WorkMap []*SWorkExtraData
}

func (data *SPeopleData) Show() {
	sglog.Info("who:%s", data.Name)

	for _, v := range data.WorkMap {
		sglog.Info("time:%s,content:%s", v.Time, v.Content)
	}

	sglog.Info("show name %s complete,size=%d", data.Name, len(data.WorkMap))

}
