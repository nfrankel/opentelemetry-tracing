#!/bin/bash

export PROJECT_HOME=`pwd`

git checkout master~3
docker build -t otel-catalog:1.0 "$PROJECT_HOME/catalog"
docker build -t otel-pricing:1.0 "$PROJECT_HOME/pricing"
docker build -t otel-inventory:1.0 "$PROJECT_HOME/inventory"
docker build -t otel-warehouse-us:1.0 "$PROJECT_HOME/warehouse-us"
docker build -t otel-warehouse-eu:1.0 "$PROJECT_HOME/warehouse-eu"
docker build -t otel-warehouse-jp:1.0 "$PROJECT_HOME/warehouse-jp"
docker build -t otel-warehouse-uk:1.0 "$PROJECT_HOME/warehouse-uk"
docker build -t otel-warehouse-nord:1.0 "$PROJECT_HOME/warehouse-nord"
docker build -t otel-recommendations:1.0 "$PROJECT_HOME/recommendations"

git checkout master~1
docker build -t otel-catalog:1.1 "$PROJECT_HOME/catalog"
docker build -t otel-pricing:1.1 "$PROJECT_HOME/pricing"
docker build -t otel-warehouse-uk:1.1 "$PROJECT_HOME/warehouse-uk"

git checkout master
docker build -t otel-catalog:1.2 "$PROJECT_HOME/catalog"
docker build -t otel-pricing:1.2 "$PROJECT_HOME/pricing"
docker build -t otel-analytics:1.0 "$PROJECT_HOME/analytics"
