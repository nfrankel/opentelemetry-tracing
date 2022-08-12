require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/exporter/otlp'

require './warehouse'

OpenTelemetry::SDK.configure do |c|
  c.use_all
end

use Rack::CommonLogger, $stdout

run WarehouseApp
