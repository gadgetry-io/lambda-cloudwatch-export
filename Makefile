DOCKER_ARGS=--name cloudwatch-export \
	--rm \
	-v "`pwd`/build":/var/task \
	-e DEBUG=true \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	lambci/lambda:go1.x cloudwatch-export

build: clean
	go build -o build/cloudwatch-export main.go
	
zip: build
	cd build && zip cloudwatch-export.zip cloudwatch-export

test-cli: clean
	go build -o build/cloudwatch-export ./src
	./build/ecs-deploy ship -a asdf -v latest -e ops --debug

test: clean
	go build -o build/cloudwatch-export ./src
	docker run $(DOCKER_ARGS) $(TEST_JSON)

invoke:
	mkdir -p lambda_output
	aws lambda invoke \
		--function-name "ecs-deploy" \
		--log-type "Tail" \
		--payload $(TEST_JSON) lambda_output/$(DATE).log \
		| jq -r '.LogResult' | base64 -d

clean:
	rm -rf build

release:
	git tag -a $(VERSION) -m "release version $(VERSION)" && git push origin $(VERSION)
	goreleaser --rm-dist

.PHONY: test testall