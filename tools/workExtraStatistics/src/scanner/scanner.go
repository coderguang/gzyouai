package scanner

import (
	"bufio"
	"io"
	"os"
	"strings"
	"workExtraStatistics/src/data"
	"workExtraStatistics/src/def"

	"github.com/coderguang/GameEngine_go/sgthread"

	"github.com/coderguang/GameEngine_go/sglog"
)

func StartParseFileList(fileList []string) {
	for _, v := range fileList {
		StartParseData(v)
		data.ShowAll()
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
				tmpData.Name = contents[0]
				tmpData.Time = contents[1] + " " + contents[2]
			} else {
				sglog.Error("some name regex error,v=%s", v)
				tmpData.Show()
				continue
			}
		} else if strings.Contains(v, "加班") {
			tmpData.Content = v
			if "" != tmpData.Name {
				data.AddWorkExtraData(tmpData)
				tmpData = new(def.SWorkExtraData)
				tmpData.Name = ""
			} else {
				sglog.Error("something error,v=%s", v)
				tmpData.Show()
				sgthread.DelayExit(2)
			}
		}
	}
	sglog.Info("transform data ok")
}
