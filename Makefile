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
		lambci/lambda:go1.x cloudwatch-export '{"test":"xx"}'

.PHONY: test