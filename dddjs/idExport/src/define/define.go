package define

import "strings"

type SDbCfg struct {
	DbIp     string
	DbName   string
	DbPort   string
	DbAuth   string
	DbOption string
	DbUser   string
	DbPwd    string
}

func (data *SDbCfg) SplitAuth() {
	authlist := strings.Split(data.DbAuth, ":")
	if len(authlist) == 2 {
		data.DbUser = authlist[0]
		data.DbPwd = string(authlist[1][0 : len(authlist[1])-1])
	}
}

func (data *SDbCfg) String() string {
	str := "\n DbIp:" + data.DbIp +
		"\n DbName:" + data.DbName +
		"\n DbPort:" + data.DbPort +
		"\n DbAuth:" + data.DbAuth +
		"\n DbOption:" + data.DbOption +
		"\n DbUser:" + data.DbUser +
		"\n DbPwd:" + data.DbPwd
	return str
}

type CollectionCfg struct {
	AllGet  []string `json:"get"`
	Ignores []string `json:"ignore"`
}
