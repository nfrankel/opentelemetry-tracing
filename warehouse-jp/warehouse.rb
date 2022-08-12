require 'sinatra/base'
require 'sinatra/json'
require 'sequel'
require 'logger'
require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/exporter/otlp'

class WarehouseApp < Sinatra::Base

  configure do
    enable :logging
    set :json_encoder, :to_json
  end

  pg_host = ENV['PG_HOST']
  pg_port = ENV['PG_PORT']
  pg_user = ENV['PG_USER']
  pg_password = ENV['PG_PASSWORD']

  DB = Sequel.postgres('postgres', :host => pg_host, :port => pg_port, :user => pg_user, :password => pg_password, :search_path => 'warehouse_jp')
  DB.loggers << Logger.new($stdout)

  get '/stocks/:id' do |id|
    json StockLevel.where(:product_id => id.to_i).join(:location, id: :warehouse_id).all
  end
end

class StockLevel < Sequel::Model(:stocklevel)
  set_primary_key :product_id

  def to_json(options)
    {
      product_id: self[:product_id],
      quantity: self[:quantity],
      warehouse: {
        id: self[:warehouse_id],
        city: self[:city],
        state: self[:prefecture],
      }
    }.to_json
  end
end
