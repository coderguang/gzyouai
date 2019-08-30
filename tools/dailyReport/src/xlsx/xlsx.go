package xlsx

import (
	"dailyReport/src/def"
	"sort"
	"strconv"
	"strings"

	"github.com/coderguang/GameEngine_go/sgfile"

	"github.com/360EntSecGroup-Skylar/excelize"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgthread"
)

func WriteDataToXlsx(datas map[string]*def.SPeopleData, filename string) {
	xlsxFile := strings.Replace(filename, "txt", "xlsx", -1)

	file := excelize.NewFile()

	sheetName := "dailyReport"
	index := file.NewSheet(sheetName)

	file.SetActiveSheet(index)

	nameKeys := []string{}
	for k, _ := range datas {
		nameKeys = append(nameKeys, k)
	}

	sort.Strings(nameKeys)

	columns := []string{"D", "G", "J", "M", "P", "S", "V", "X", "Z"}
	rows := []string{}
	for i := 3; i < 300; i = i + 4 {
		numstr := strconv.Itoa(i)
		rows = append(rows, numstr)
	}

	orderIndex := 0
	//insert name
	for k := range nameKeys {
		pos := columns[orderIndex] + "1"

		file.SetColWidth(sheetName, columns[orderIndex], columns[orderIndex], 30)

		orderIndex++
		file.SetCellStr(sheetName, pos, nameKeys[k])
		//sglog.Info("write %s %s", pos, nameKeys[k])

	}

	rawName, _ := sgfile.GetFileName(filename)

	year := rawName[0:4]
	monthStr := rawName[len(rawName)-6 : len(rawName)-4]
	if monthStr[0:1] == "0" {
		monthStr = monthStr[1:2]
	}

	sglog.Info("date:%s,year:%s,month:%s", rawName, year, monthStr)

	//insert time

	timeLocalMap := make(map[string]string)

	orderIndex = 0
	for k := 1; k <= 31; k++ {
		pos := "A" + rows[orderIndex]

		rowInt, _ := strconv.Atoi(rows[orderIndex])

		file.SetRowHeight(sheetName, rowInt, 120)

		daystr := strconv.Itoa(k)
		timestr := year + "-" + monthStr + "-" + daystr
		timeLocalMap[timestr] = rows[orderIndex]

		orderIndex++

		file.SetCellStr(sheetName, pos, timestr)
	}

	xlsxStyle, err := file.NewStyle(`{
		"alignment":{
			"horizontal":"center",
			"vertical":"center",
			"wrap_text":true
		}
	}`)
	if err != nil {
		sglog.Error("create xlsx style error,%s", err)
		sgthread.DelayExit(2)
	}

	columnsIndex := 0
	for _, k := range nameKeys {
		v, ok := datas[k]
		pos := columns[columnsIndex]
		if ok {
			for _, vv := range v.WorkMap {
				localPos, ok := timeLocalMap[vv.Time]
				posex := pos
				if ok {
					posex += localPos
				} else {
					sglog.Error("can't find time match,time=%s", vv.Time)
					vv.Show()
					sgthread.DelayExit(2)
				}
				file.SetCellStyle(sheetName, posex, posex, xlsxStyle)

				file.SetCellStr(sheetName, posex, vv.Content)
				//sglog.Info("write %s %s", posex, vv.Content)
			}
			columnsIndex++
		}
	}

	err = file.SaveAs(xlsxFile)

	if err != nil {
		sglog.Error("save file error,file:%s,err:%s", xlsxFile, err)
		sgthread.DelayExit(2)
	}

}
