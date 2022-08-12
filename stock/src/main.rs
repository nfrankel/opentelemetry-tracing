use axum::extract::Path;
use axum::response::IntoResponse;
use axum::routing::get;
use axum::Json;
use axum_tracing_opentelemetry::{opentelemetry_tracing_layer, response_with_trace_layer};
use rand_distr::{Distribution, Gamma};
use serde::Serialize;

use crate::data::WAREHOUSES;

mod data;
mod otel;

#[tokio::main]
async fn main() {
    otel::init_tracing();
    let app = axum::Router::new()
        .route("/stocks/:product_id", get(get_stock_by_product_id))
        .layer(response_with_trace_layer())
        .layer(opentelemetry_tracing_layer());
    axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(app.into_make_service())
        .with_graceful_shutdown(otel::shutdown_signal())
        .await
        .unwrap();
}

async fn get_stock_by_product_id(Path(product_id): Path<u8>) -> impl IntoResponse {
    let stock_levels = WAREHOUSES.map(|warehouse| StockLevel::new(product_id, warehouse));
    Json(stock_levels)
}

#[derive(Serialize, Copy, Clone)]
struct Warehouse<'a> {
    id: u8,
    state: &'a str,
    city: &'a str,
}

#[derive(Serialize)]
struct StockLevel<'a> {
    product_id: u8,
    warehouse: Warehouse<'a>,
    quantity: u8,
}

impl<'a> StockLevel<'a> {
    fn new(product_id: u8, warehouse: Warehouse<'a>) -> StockLevel {
        StockLevel {
            product_id,
            warehouse,
            quantity: Self::random_quantity(),
        }
    }

    fn random_quantity() -> u8 {
        let gamma = Gamma::new(1.0, 3.0).unwrap();
        let sample: f32 = gamma.sample(&mut rand::thread_rng());
        sample.ceil() as u8 - 1
    }
}
