# es-scoring

Experiment with custom scoring in Elasticsearch.

Source: https://www.elastic.co/guide/en/elasticsearch/reference/5.1/query-dsl-function-score-query.html

## Requirements

- docker-compose

## How to run

\* `make help` for details

1. Setup

```sh
make env            ## deploy local environment and wait for readiness
make index          ## create Elasticsearch index
make payload        ## create test dataset
```

2. Verify

```sh
make test-noscore   ## execute query without scoring
make test-regular   ## execute query with built-in scoring
make test-script    ## execute query with custom scipt scoring
make test-field     ## execute query with custom field value factor scoring function
```

3. Destroy

```sh
make index-delete   ## delete Elasticsearch index
make env-delete     ## destroy local environment
```
