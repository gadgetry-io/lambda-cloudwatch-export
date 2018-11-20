build:
	goreleaser --rm-dist --snapshot
	
zip: build
	cd build && zip cloudwatch-export.zip cloudwatch-export

release:
	goreleaser --rm-dist

test: build
	docker run --name cloudwatch-export \
		--rm \
		-v "`pwd`/dist/linux_amd64":/var/task \
		-e DEBUG=true \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e LOG_GROUP \
		-e S3_BUCKET \
		lambci/lambda:go1.x cloudwatch-export '{ "version":"0", "id":"890abcde-f123-4567-890a-bcdef1234567", "detail-type":"Scheduled Event", "source":"aws.events", "account":"123456789012", "time":"2016-12-30T18:44:49Z", "region":"us-east-1", "resources":[ "arn:aws:events:us-east-1:123456789012:rule/SampleRule" ], "detail":{ } }'

.PHONY: test