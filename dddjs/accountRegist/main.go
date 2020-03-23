package main

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"mime/multipart"
	"net/http"
	"strconv"
	"time"

	"github.com/coderguang/GameEngine_go/sgcmd"
	"github.com/coderguang/GameEngine_go/sglog"
	"github.com/coderguang/GameEngine_go/sgnet/sghttp"
	"github.com/coderguang/GameEngine_go/sgserver"
	"github.com/coderguang/GameEngine_go/sgtime"
)

type SResult struct {
	Result    int    `json:"result"`
	Openid    string `json:"openid"`
	Key       string `json:"key"`
	Timestamp string `json:"timestamp"`
	Username  string `json:"username"`
	Password  string `json:"password"`
	Guest     string `json:"guest"`
	Msg       string `json:"msg"`
}

func TestLocalPost() {
	url := "http://10.21.210.104:8086/client/register"

	postData := make(map[string]string)

	testNum := 1
	userNameBase := "sg2026"
	passwd := "aaaaaa"
	logResult := true
	useGoFun := true

	startDt := time.Now()
	for i := 0; i < testNum; i++ {

		postData["username"] = userNameBase + strconv.Itoa(i)
		postData["password"] = passwd

		body := new(bytes.Buffer)
		w := multipart.NewWriter(body)
		for k, v := range postData {
			w.WriteField(k, v)
		}
		w.Close()
		req, _ := http.NewRequest("POST", url, body)
		req.Header.Set("Content-Type", w.FormDataContentType())

		if logResult {
			result := SResult{}
			if useGoFun {
				go func() {
					resp, err := http.DefaultClient.Do(req)
					if err != nil {
						sglog.Error("require error,err:", err)
						return
					}
					data, err := ioutil.ReadAll(resp.Body)
					if err != nil {
						sglog.Error("readAll error,err:", err)
						return
					}
					resp.Body.Close()
					err = json.Unmarshal(data, &result)
					if err != nil {
						sglog.Error("parse to struct error")
						return
					}
					if result.Result != 0 {
						sglog.Error("regist error:Result:", result.Result, ",msg:", result.Msg, ",username:", result.Username)
					}
					sglog.Debug("regist ok:", result.Username)
				}()
			} else {
				resp, _ := http.DefaultClient.Do(req)
				data, _ := ioutil.ReadAll(resp.Body)
				resp.Body.Close()
				err := json.Unmarshal(data, &result)
				if err != nil {
					sglog.Error("parse to struct error")
					continue
				}
				if result.Result != 0 {
					sglog.Debug("regist error:Result:", result.Result, ",msg:", result.Msg)
				}
			}
		} else {
			http.DefaultClient.Do(req)
		}
	}
	endDt := time.Now()

	sglog.Info("test regist complete,total:", testNum, ",user time:", sgtime.GetTotalSecond(sgtime.TransfromTimeToDateTime(endDt))-sgtime.GetTotalSecond(sgtime.TransfromTimeToDateTime(startDt)))

}

func TestEngine() {
	url := "http://10.21.210.104:8086/client/register"

	postData := make(map[string]string)
	fileData := make(map[string]string)

	testNum := 1
	userNameBase := "sg2026"
	passwd := "aaaaaa"

	startDt := time.Now()

	for i := 0; i < testNum; i++ {

		postData["username"] = userNameBase + strconv.Itoa(i)
		postData["password"] = passwd

		resp, err := sghttp.PostMultiFormFile(url, fileData, postData)
		if err != nil {
			sglog.Error("require error,err:", err)
			return
		}
		data, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			sglog.Error("readAll error,err:", err)
			return
		}
		resp.Body.Close()
		result := SResult{}
		err = json.Unmarshal(data, &result)
		if err != nil {
			sglog.Error("parse to struct error")
			return
		}
		if result.Result != 0 {
			sglog.Error("regist error:Result:", result.Result, ",msg:", result.Msg, ",username:", result.Username)
		}
		sglog.Debug("regist ok:", result.Username)
	}

	endDt := time.Now()

	sglog.Info("test regist complete,total:", testNum, ",user time:", sgtime.GetTotalSecond(sgtime.TransfromTimeToDateTime(endDt))-sgtime.GetTotalSecond(sgtime.TransfromTimeToDateTime(startDt)))

}

func main() {
	sgserver.StartServer(sgserver.ServerTypeLog, "debug", "./log/", log.LstdFlags, true)

	sglog.Info("start accountRegist :")
	//TestLocalPost()
	TestEngine()
	sgcmd.StartCmdWaitInputLoop()
	sgserver.StopAllServer()
}
