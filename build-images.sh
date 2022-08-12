#!/bin/bash

export PROJECT_HOME=`pwd`

git checkout master~2
cd $PROJECT_HOME/catalog
docker build -t otel-catalog:1.0 .
cd $PROJECT_HOME/pricing
docker build -t otel-pricing:1.0 .
cd $PROJECT_HOME/inventory
docker build -t otel-inventory:1.0 .
cd $PROJECT_HOME/warehouse-us
docker build -t otel-warehouse-us:1.0 .
cd $PROJECT_HOME/warehouse-eu
docker build -t otel-warehouse-eu:1.0 .

git checkout master~1
cd $PROJECT_HOME/catalog
docker build -t otel-catalog:1.1 .
cd $PROJECT_HOME/pricing
docker build -t otel-pricing:1.1 .

git checkout master
cd $PROJECT_HOME/catalog
docker build -t otel-catalog:1.2 .
cd $PROJECT_HOME/analytics
docker build -t otel-analytics:1.0 .

cd $PROJECT_HOME
