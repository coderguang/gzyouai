package scanner

import (
	"bufio"
	"dailyReport/src/data"
	"dailyReport/src/def"
	"dailyReport/src/xlsx"
	"io"
	"os"
	"strings"

	"github.com/coderguang/GameEngine_go/sgthread"

	"github.com/coderguang/GameEngine_go/sglog"
)

func StartParseFileList(fileList []string) {
	for _, v := range fileList {
		StartParseData(v)
		//data.ShowAll()
		xlsx.WriteDataToXlsx(data.GetDataMap(), v)
		data.ResetData()
	}
}

func StartParseData(filename string) {
	file, err := os.OpenFile(filename, os.O_RDWR, 0666)
	if err != nil {
		sglog.Fatal("read file:%s error,err:=%s", filename, err)
		return
	}

	strlist := []string{}
	sum := 0
	rd := bufio.NewReader(file)
	for {
		line, _, err := rd.ReadLine()
		if err != nil || io.EOF == err {
			break
		}
		str := string([]byte(line))
		strlist = append(strlist, str)
		sum++
	}
	transFromFileData(strlist)
}

func transFromFileData(strlist []string) {
	//sglog.Info("read file %s", strlist)

	sglog.Info("start transform data")

	tmpData := new(def.SWorkExtraData)
	tmpData.Name = ""

	for _, v := range strlist {
		if strings.Contains(v, "(YA") {
			contents := strings.Split(v, " ")
			if 3 == len(contents) {
				if "" != tmpData.Name {
					tmpData.Content = tmpData.Time + "\n" + tmpData.Name + tmpData.Content

					data.AddWorkExtraData(tmpData)
					tmpData = new(def.SWorkExtraData)
					tmpData.Name = ""
					tmpData.Name = contents[0]
					tmpData.Time = contents[1]
				} else {
					tmpData.Name = contents[0]
					tmpData.Time = contents[1]
				}
			} else {
				sglog.Error("some name regex error,v=%s", v)
				tmpData.Show()
				sgthread.DelayExit(2)
				continue
			}
		} else {
			tmpData.Content += "\r\n" + v
		}
	}
	sglog.Info("transform data ok")
}
