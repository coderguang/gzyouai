package xlsxProcess

import (
	"sort"
	"strconv"
	"strings"

	"github.com/360EntSecGroup-Skylar/excelize"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgthread"
)

type SensitiveWorld struct {
	Words  string
	Length int
}

type SensitiveWorldList []SensitiveWorld

func (s SensitiveWorldList) Len() int {
	return len(s)
}
func (s SensitiveWorldList) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}
func (s SensitiveWorldList) Less(i, j int) bool {
	return s[i].Length > s[j].Length
}

func StartProcessFile(fileList []string) {
	for _, v := range fileList {
		processSingleFile(v)
	}
}

func processSingleFile(filename string) {
	xls, err := excelize.OpenFile(filename)
	if err != nil {
		sglog.Error("读取文件失败,%s", filename)
		sglog.Error("error:%s", err)
		sgthread.DelayExit(2)
	}

	sheetName := "root"
	rows, err := xls.Rows(sheetName)
	if err != nil {
		sglog.Error("读取 %s 工作表 错误,err=%s", sheetName, err)
		sgthread.DelayExit(2)
	}

	rawList := SensitiveWorldList{}

	replaceList := SensitiveWorldList{}

	totalline := 0
	for rows.Next() {
		totalline++
		pos := "C" + strconv.Itoa(totalline)
		worldLengthStr := xls.GetCellValue(sheetName, pos)
		worldLength, err := strconv.Atoi(worldLengthStr)
		if err != nil {
			continue
		}
		worldPos := "B" + strconv.Itoa(totalline)
		worlds := xls.GetCellValue(sheetName, worldPos)

		tmp := SensitiveWorld{}
		tmp.Words = worlds
		tmp.Length = worldLength
		rawList = append(rawList, tmp)
		if tmp.Length <= 4 {
			replaceList = append(replaceList, tmp)
		}
	}
	sort.Sort(rawList)

	sort.Sort(replaceList)

	sglog.Info("total %d line,worlds line:%d,min worlds line:%d", totalline, len(rawList), len(replaceList))

	newReplaceList := make(SensitiveWorldList, len(rawList))
	copy(newReplaceList, rawList)

	finalFliter := false

	if finalFliter {
		//贪婪匹配
		for _, v := range rawList {
			newReplaceList = append(newReplaceList, ReplaceString(v, replaceList))
		}
	} else {
		//多次匹配
		for _, v := range rawList {
			for _, vv := range replaceList {
				if v.Length <= vv.Length {
					continue
				}
				if strings.Contains(v.Words, vv.Words) {
					tmp := v
					tmp.Words = strings.Replace(tmp.Words, vv.Words, "口", 1)
					tmp.Length = tmp.Length - vv.Length + 1
					newReplaceList = append(newReplaceList, tmp)
				}
			}
		}
	}

	finalReplaceList := SensitiveWorldList{}
	flitermap := make(map[string]SensitiveWorld)

	for _, v := range newReplaceList {
		flitermap[v.Words] = v
	}

	for _, v := range flitermap {
		finalReplaceList = append(finalReplaceList, v)
	}

	sort.Sort(finalReplaceList)

	tlen := len(finalReplaceList)

	for i := 0; i < tlen/2; i++ {
		finalReplaceList[i], finalReplaceList[tlen-i-1] = finalReplaceList[tlen-i-1], finalReplaceList[i]
	}

	for _, v := range finalReplaceList {
		sglog.Info("%s,%d", v.Words, v.Length)
	}
	sglog.Info("final size is %d", len(finalReplaceList))
	WriteToNewXlsx(filename, finalReplaceList)
}

func ReplaceString(rawData SensitiveWorld, replaceList SensitiveWorldList) SensitiveWorld {
	tmp := rawData
	hadMatch := false
	for _, vv := range replaceList {
		if rawData.Length <= vv.Length {
			continue
		}
		if strings.Contains(tmp.Words, vv.Words) {
			tmp.Words = strings.Replace(tmp.Words, vv.Words, "口", 1)
			tmp.Length = tmp.Length - vv.Length + 1
			hadMatch = true
			break
		}
	}
	if !hadMatch {
		return tmp
	} else {
		return ReplaceString(tmp, replaceList)
	}
}

func WriteToNewXlsx(filename string, finallist SensitiveWorldList) {

	xlsxFile := strings.Replace(filename, ".xlsx", "_result.xlsx", -1)
	file := excelize.NewFile()

	sheetName := "root"
	index := file.NewSheet(sheetName)

	file.SetActiveSheet(index)

	rowIndex := 1
	for _, v := range finallist {
		posWorld := "B" + strconv.Itoa(rowIndex)
		posLength := "C" + strconv.Itoa(rowIndex)
		file.SetCellStr(sheetName, posWorld, v.Words)
		file.SetCellStr(sheetName, posLength, strconv.Itoa(v.Length))
		rowIndex++
	}

	err := file.SaveAs(xlsxFile)

	if err != nil {
		sglog.Error("save file error,file:%s,err:%s", xlsxFile, err)
		sgthread.DelayExit(2)
	}
	sglog.Info("new file is %s", xlsxFile)
}
