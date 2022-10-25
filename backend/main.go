package main

import (
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/integrations/nrgin"
	"github.com/newrelic/go-agent/v3/newrelic"
)

type Application struct {
	NewRelicApplication *newrelic.Application
}

func main() {
	nrApp, err := newrelic.NewApplication(
		newrelic.ConfigAppName("test-newrelic-go"),
		newrelic.ConfigLicense(os.Getenv("NEW_RELIC_CONFIG_LICENSE")),
		newrelic.ConfigAppLogForwardingEnabled(true),
	)

	if err != nil {
		log.Fatal(err)
	}

	app := Application{
		NewRelicApplication: nrApp,
	}

	gin.SetMode(gin.ReleaseMode)
	mux := gin.New()

	mux.Use(gin.Recovery())
	mux.Use(nrgin.Middleware(nrApp))
	mux.Use(cors.Default())

	root := mux.Group("/")
	root.GET("/users/:userId/report", app.getReport)

	server := http.Server{
		Addr:         ":9067",
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}
	server.ListenAndServe()
}

func (app *Application) getReport(c *gin.Context) {
	e := c.Request.Header.Get("error")
	if e != "" {
		httpError, _ := strconv.Atoi(e)
		if httpError == 504 {
			txn := nrgin.Transaction(c)
			if txn != nil {
				txn.NoticeError(newrelic.Error{
					Message: "This is my special error",
					Class:   "SpecialError",
				})
			}
		}
		c.AbortWithStatus(httpError)
		return
	}

	longReportType := c.Request.Header.Get("longReportType")
	if longReportType != "" {
		s1 := rand.NewSource(time.Now().UnixNano())
		r1 := rand.New(s1)
		if longReportType == "1" {
			time.Sleep(time.Duration(6+r1.Intn(4)) * time.Second)
		} else if longReportType == "2" {
			time.Sleep(time.Duration(2+r1.Intn(2)) * time.Second)
		}
	}

	c.String(http.StatusOK, "success")
}
