package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"
)

func failOnError(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func pickRandom(arr []string) string {
	randomIndex := rand.Intn(len(arr))
	return arr[randomIndex]
}

func main() {
	client := http.Client{
		Timeout: 60 * time.Second,
	}
	users := []string{"CaptainJackSparrow", "WillTurner", "ElizabethSwann"}
	for {
		user := pickRandom(users)

		rand.Float32()

		url := fmt.Sprintf("http://localhost:9067/users/%s/report", user)
		req, err := http.NewRequest("GET", url, nil)
		log.Println(url)
		failOnError(err)
		if rand.Float32() > 0.7 {
			if rand.Float32() > 0.3 {
				req.Header.Add("longReportType", "1")
			} else {
				req.Header.Add("longReportType", "2")
			}
		}

		if rand.Float32() > 0.9 {
			errorCodes := []string{"400", "401", "404", "504"}
			errorCode := pickRandom(errorCodes)
			req.Header.Add("error", errorCode)
		}
		_, err = client.Do(req)
		failOnError(err)
		time.Sleep(300 * time.Millisecond)
	}
}
