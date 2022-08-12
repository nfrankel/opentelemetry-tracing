use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::Json;
use axum_macros::debug_handler;
use axum_tracing_opentelemetry::middleware::{OtelAxumLayer, OtelInResponseLayer};
use config::{Config, ConfigError, Environment};
use deadpool_postgres::tokio_postgres::{NoTls, Row};
use deadpool_postgres::{Config as DeadPoolConfig, Pool, Runtime};
use serde::{Deserialize, Serialize};

mod otel;

#[derive(Debug, Deserialize)]
struct ConfigHolder {
    pg: DeadPoolConfig,
}

impl ConfigHolder {
    pub fn from_env() -> Result<Self, ConfigError> {
        Config::builder()
            .add_source(
                Environment::with_prefix("PG")
                    .separator("_")
                    .keep_prefix(true)
                    .try_parsing(true),
            )
            .build()?
            .try_deserialize()
    }
}

#[tokio::main]
async fn main() {
    // Load configuration
    let cfg = ConfigHolder::from_env().unwrap();
    let pool = cfg.pg.create_pool(Some(Runtime::Tokio1), NoTls).unwrap();

    // Initialize OTEL
    init_tracing_opentelemetry::tracing_subscriber_ext::init_subscribers().unwrap();

    // Routing
    let app = axum::Router::new()
        .route("/stocks/:product_id", get(get_stock_by_product_id))
        .layer(OtelInResponseLayer::default())
        .layer(OtelAxumLayer::default())
        .with_state(pool);

    // Start the server
    axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(app.into_make_service())
        .with_graceful_shutdown(otel::shutdown_signal())
        .await
        .unwrap();
}

type ErrorResponse = (StatusCode, String);

#[debug_handler]
async fn get_stock_by_product_id(
    Path(product_id): Path<i64>,
    State(pool): State<Pool>,
) -> Response {
    let client = pool.get().await.unwrap();
    match client.query("SELECT product_id, warehouse_id, quantity, city, state FROM stocklevel INNER JOIN warehouse ON stocklevel.warehouse_id = warehouse.id WHERE product_id = $1", &[&product_id])
        .await
        .map_err(internal_error) {
        Ok(rows) => (StatusCode::OK, Json(rows.iter().map(Into::<StockLevel>::into).collect::<Vec<StockLevel>>())).into_response(),
        Err(err) => err.into_response()
    }
}

impl From<&Row> for StockLevel {
    fn from(row: &Row) -> Self {
        let product_id: i64 = row.get("product_id");
        let warehouse_id: i64 = row.get("warehouse_id");
        let quantity: i32 = row.get("quantity");
        let city: String = row.get("city");
        let state: String = row.get("state");
        StockLevel {
            product_id,
            quantity,
            warehouse: Warehouse {
                id: warehouse_id,
                state,
                city,
            },
        }
    }
}

#[derive(Serialize)]
struct Warehouse {
    id: i64,
    state: String,
    city: String,
}

#[derive(Serialize)]
struct StockLevel {
    product_id: i64,
    quantity: i32,
    warehouse: Warehouse,
}

fn internal_error<E>(err: E) -> ErrorResponse
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
