require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry-exporter-otlp'
require './warehouse'

use Rack::CommonLogger, $stdout

run WarehouseApp
