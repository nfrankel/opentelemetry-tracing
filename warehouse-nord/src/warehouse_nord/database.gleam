import gleam/dynamic/decode
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option.{Some}
import glotel/span
import pog
import warehouse_nord/config
import warehouse_nord/models.{type StockLevel, StockLevel, Warehouse}

pub fn connect(config: config.Config) -> Result(pog.Connection, String) {
  let pool_name = process.new_name("warehouse_nord_db")

  let db_config =
    pog.default_config(pool_name)
    |> pog.host(config.db_host)
    |> pog.port(config.db_port)
    |> pog.database(config.db_name)
    |> pog.user(config.db_user)
    |> pog.pool_size(15)

  let db_config = case config.db_password {
    "" -> db_config
    password -> pog.password(db_config, Some(password))
  }

  case pog.start(db_config) {
    Ok(started) -> Ok(started.data)
    Error(_) -> Error("Failed to start database connection pool")
  }
}

pub fn get_all_stocks(db: pog.Connection) -> Result(List(StockLevel), String) {
  use span_ctx <- span.new("db.query.get_all_stocks", [
    #("db.system", "postgresql"),
    #("db.name", "warehouse_nord"),
    #("db.operation", "SELECT"),
  ])

  let sql =
    "
    SELECT
      s.product_id,
      s.warehouse_id,
      s.quantity,
      l.id,
      l.city,
      l.region
    FROM warehouse_nord.stocklevel s
    JOIN warehouse_nord.location l ON s.warehouse_id = l.id
    ORDER BY s.product_id, s.warehouse_id
  "

  span.set_attribute(span_ctx, "db.statement", sql)

  case
    pog.query(sql)
    |> pog.returning(stock_level_decoder())
    |> pog.execute(db)
  {
    Ok(response) -> {
      span.set_attribute(
        span_ctx,
        "db.rows_affected",
        int.to_string(list.length(response.rows)),
      )
      Ok(response.rows)
    }
    Error(_) -> {
      span.set_error_message(span_ctx, "Failed to query database")
      Error("Failed to query database")
    }
  }
}

pub fn get_stocks_by_product_id(
  db: pog.Connection,
  product_id: Int,
) -> Result(List(StockLevel), String) {
  use span_ctx <- span.new("db.query.get_stocks_by_product_id", [
    #("db.system", "postgresql"),
    #("db.name", "warehouse_nord"),
    #("db.operation", "SELECT"),
    #("product_id", int.to_string(product_id)),
  ])

  let sql =
    "
    SELECT
      s.product_id,
      s.warehouse_id,
      s.quantity,
      l.id,
      l.city,
      l.region
    FROM warehouse_nord.stocklevel s
    JOIN warehouse_nord.location l ON s.warehouse_id = l.id
    WHERE s.product_id = $1
    ORDER BY s.warehouse_id
  "

  span.set_attribute(span_ctx, "db.statement", sql)

  case
    pog.query(sql)
    |> pog.parameter(pog.int(product_id))
    |> pog.returning(stock_level_decoder())
    |> pog.execute(db)
  {
    Ok(response) -> {
      span.set_attribute(
        span_ctx,
        "db.rows_affected",
        int.to_string(list.length(response.rows)),
      )
      Ok(response.rows)
    }
    Error(_) -> {
      span.set_error_message(span_ctx, "Failed to query database")
      Error("Failed to query database")
    }
  }
}

fn stock_level_decoder() {
  use product_id <- decode.field(0, decode.int)
  use warehouse_id <- decode.field(1, decode.int)
  use quantity <- decode.field(2, decode.int)
  use w_id <- decode.field(3, decode.int)
  use city <- decode.field(4, decode.string)
  use region <- decode.field(5, decode.string)
  decode.success(StockLevel(
    product_id: product_id,
    warehouse_id: warehouse_id,
    quantity: quantity,
    warehouse: Warehouse(id: w_id, city: city, country: region),
  ))
}
