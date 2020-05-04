ES:=http://localhost:9200/es-scoring
_jq:="docker run --rm -i endeveit/docker-jq jq -C ."

default: help


##@ Up

env: ## deploy local environment and wait for readiness
	@ docker-compose up -d
	@ (docker-compose logs | grep started) || (sleep 1; make env)
.PHONY: env

index: ## create Elasticsearch index
	@ curl -XPUT $(ES) --data-binary "@data/mapping.json" -H "Content-Type: application/json"
.PHONY: index

payload: ## create test dataset
	@ curl -XPOST $(ES)/items/_bulk --data-binary "@data/payload.ndjson"
.PHONY: payload

##@ Test

test-regular: ## execute query with built-in scoring
	@ curl -XGET $(ES)/items/_search --data-binary "@data/score-regular.json" -H "Content-Type: application/x-ndjson" | docker run --rm -i endeveit/docker-jq jq -C .
.PHONY: test-regular

test-script: ## execute query with custom script scoring function
	@ curl -XGET $(ES)/items/_search --data-binary "@data/score-script.json" -H "Content-Type: application/x-ndjson" | docker run --rm -i endeveit/docker-jq jq -C .
.PHONY: test-script

test-field: ## execute query with custom field value factor scoring function
	@ curl -XGET $(ES)/items/_search --data-binary "@data/score-field.json" -H "Content-Type: application/x-ndjson" | docker run --rm -i endeveit/docker-jq jq -C .
.PHONY: test-field

test-noscore: ## execute query without scoring
	@ curl -XGET $(ES)/items/_search | docker run --rm -i endeveit/docker-jq jq -C .
.PHONY: test-noscore

##@ Down

index-delete: ## delete Elasticsearch index
	@ curl -XDELETE $(ES)
.PHONY: index-delete

env-delete: ## destroy local environment
	@ docker-compose down
.PHONY: env-delete


help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make [target]\033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help
