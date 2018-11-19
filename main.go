package main

import (
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(CloudWatchEventsHandler)
}

// CloudWatchEventsHandler handles executions from CloudWatch Events scheduler
func CloudWatchEventsHandler(e events.CloudWatchEvent) (s string, err error) {
	outputJSON, _ := json.Marshal(e)
	// stdout and stderr are sent to AWS CloudWatch Logs
	fmt.Println(string(outputJSON[:]))

	return
}
