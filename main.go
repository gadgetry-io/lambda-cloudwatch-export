package main

import (
	"fmt"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/jinzhu/now"
)

var (
	defaultDescription = "desired version set by lambda ecs-deploy"
	sess               = session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
)

func main() { lambda.Start(ExportLogs) }

// BucketExportConfigs provides options for the export
type BucketExportConfigs struct {
	S3Bucket string `json:"s3_bucket"`
	S3Prefix string `json:"s3_prefix"`
	LogGroup string `json:"log_group"`
}

// ExportLogs handles executions from CloudWatch Events scheduler
func ExportLogs(conf BucketExportConfigs) (s string, err error) {
	fmt.Printf("Exporting log group %s to s3://%s/%s\n", conf.LogGroup, conf.S3Bucket, conf.S3Prefix)
	yesterday := time.Now().AddDate(0, 0, -1)

	fmt.Println(conf.S3Prefix + "/" + yesterday.Format("year=2006/month=01/day=02"))
	client := cloudwatchlogs.New(sess)
	params := &cloudwatchlogs.CreateExportTaskInput{
		Destination:       aws.String(conf.S3Bucket),
		DestinationPrefix: aws.String(conf.S3Prefix + "/" + yesterday.Format("year=2006/month=01/day=02")),
		From:              aws.Int64(now.New(yesterday).BeginningOfDay().Unix() * 1000),
		LogGroupName:      aws.String(conf.LogGroup),
		TaskName:          aws.String("exporter"),
		To:                aws.Int64(now.New(yesterday).EndOfDay().Unix() * 1000),
	}
	res, err := client.CreateExportTask(params)
	if err != nil {
		fmt.Println(err)
	}
	if res.TaskId != nil {
		fmt.Printf("Started export task %s\n", *res.TaskId)
	}
	return
}
