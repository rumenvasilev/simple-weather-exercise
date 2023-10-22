package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"regexp"
	"strings"
)

type Response struct {
	Page       int            `json:"page"`
	PerPage    int            `json:"per_page"`
	Total      int            `json:"total"`
	TotalPages int            `json:"total_pages"`
	Data       []ResponseData `json:"data"`
}

type ResponseData struct {
	Name    string   `json:"name"`
	Weather string   `json:"weather"`
	Status  []string `json:"status"`
}

func main() {
	debug := flag.Bool("debug", false, "Enable debug log")
	flag.Parse()
	if !*debug {
		log.SetOutput(io.Discard)
	}

	// http://127.0.0.1:4010/forecast is defined as smithy => openApi and launched
	// with prism mock
	req, err := http.NewRequest("GET", "http://127.0.0.1:4010/forecast?cityId=all", nil)
	req.Header.Set("Accept", "application/json")
	checkError(err)

	result := getAllPages(req, nil)
	if len(result) == 0 {
		log.Fatalln("No entries found")
	}

	// reformat output
	for _, v := range result {
		fmt.Println(formatOutputData(v))
	}
}

func checkError(err error) {
	if err != nil {
		log.Fatalln(err)
	}
}

func getAllPages(req *http.Request, result []ResponseData) []ResponseData {
	client := &http.Client{}
	resp, err := client.Do(req)
	checkError(err)

	if resp.StatusCode != 200 {
		if resp.StatusCode == 404 {
			log.Println("No more entries found")
			return result
		}
		log.Println("Unknown error occurred, http code:", resp.StatusCode)
		return result
	}

	data, err := io.ReadAll(resp.Body)
	checkError(err)

	var r Response
	err = json.Unmarshal([]byte(data), &r)
	checkError(err)

	result = append(result, r.Data...)
	if r.TotalPages == r.Page {
		return result
	}

	req.Header.Set("Prefer", fmt.Sprintf("example=GetForecast_example%d", r.Page+1))
	q := req.URL.Query()
	q.Set("page", fmt.Sprintf("%d", r.Page+1))
	req.URL.RawQuery = q.Encode()

	log.Println("Calling again for page", r.Page+1)
	log.Println(req.URL.String())
	return getAllPages(req, result)
}

func formatOutputData(v ResponseData) string {
	weather, wind, humidity := "0", "0", "0"
	if len(v.Status) < 2 {
		log.Fatalln("Status field does not contain enough entries")
	}

	for _, s := range v.Status {
		t := strings.Split(s, ":")
		if len(t) < 2 {
			log.Fatalln("Status field does not contain the correct entries")
		}
		if t[0] == "Wind" {
			wind = t[1]
		} else if t[0] == "Humidity" {
			humidity = t[1]
		}
	}

	re := regexp.MustCompile("[0-9]+")
	if wind != "" {
		wind = re.FindAllString(wind, 1)[0]
	}
	if humidity != "" {
		humidity = re.FindAllString(humidity, 1)[0]
	}
	if weather != "" {
		weather = re.FindAllString(v.Weather, 1)[0]
	}
	return fmt.Sprintf("%s, %s, %s, %s", v.Name, weather, wind, humidity)
}
