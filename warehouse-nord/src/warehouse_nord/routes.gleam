import gleam/bytes_tree
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/list
import glotel/span
import glotel/span_kind
import mist.{type Connection, type ResponseData}
import pog
import warehouse_nord/database
import warehouse_nord/models

pub fn handle_request(
  db: pog.Connection,
) -> fn(Request(Connection)) -> Response(ResponseData) {
  fn(req: Request(Connection)) -> Response(ResponseData) {
    // Extract trace context from incoming request headers for distributed tracing
    span.extract_values(req.headers)

    let method = http.method_to_string(req.method)
    let path = req.path

    use span_ctx <- span.new_of_kind(span_kind.Server, method <> " " <> path, [
      #("http.method", method),
      #("http.route", path),
      #("http.target", path),
    ])

    let response = case req.method, request.path_segments(req) {
      Get, ["stocks"] -> get_all_stocks(db, span_ctx)
      Get, ["stocks", id] -> get_stock_by_id(db, id, span_ctx)
      _, _ -> not_found()
    }

    span.set_attribute(
      span_ctx,
      "http.status_code",
      int.to_string(response.status),
    )

    response
  }
}

fn get_all_stocks(
  db: pog.Connection,
  parent_span: span.SpanContext,
) -> Response(ResponseData) {
  use span_ctx <- span.new("database.get_all_stocks", [])

  case database.get_all_stocks(db) {
    Ok(stocks) -> {
      span.set_attribute(span_ctx, "db.result_count", int.to_string(list.length(stocks)))

      let json_stocks =
        stocks
        |> list.map(models.encode_stock_level)
        |> json.array(of: fn(x) { x })
        |> json.to_string

      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string(json_stocks)))
    }
    Error(msg) -> {
      span.set_error_message(span_ctx, msg)
      internal_error(msg)
    }
  }
}

fn get_stock_by_id(
  db: pog.Connection,
  id: String,
  parent_span: span.SpanContext,
) -> Response(ResponseData) {
  case int.parse(id) {
    Ok(product_id) -> {
      use span_ctx <- span.new("database.get_stocks_by_product_id", [
        #("product_id", id),
      ])

      case database.get_stocks_by_product_id(db, product_id) {
        Ok(stocks) -> {
          span.set_attribute(
            span_ctx,
            "db.result_count",
            int.to_string(list.length(stocks)),
          )

          let json_stocks =
            stocks
            |> list.map(models.encode_stock_level)
            |> json.array(of: fn(x) { x })
            |> json.to_string

          response.new(200)
          |> response.set_body(mist.Bytes(bytes_tree.from_string(json_stocks)))
        }
        Error(msg) -> {
          span.set_error_message(span_ctx, msg)
          internal_error(msg)
        }
      }
    }
    Error(_) -> bad_request()
  }
}

fn not_found() -> Response(ResponseData) {
  response.new(404)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("Not found")))
}

fn bad_request() -> Response(ResponseData) {
  response.new(400)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("Bad request")))
}

fn internal_error(msg: String) -> Response(ResponseData) {
  response.new(500)
  |> response.set_body(mist.Bytes(bytes_tree.from_string(
    "Internal server error: " <> msg,
  )))
}
