use crate::config::get_warehouse_endpoints;
use axum::extract::Path;
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::Json;
use axum_macros::debug_handler;
use axum_tracing_opentelemetry::middleware::{OtelAxumLayer, OtelInResponseLayer};
use reqwest::Client;
use reqwest_middleware::ClientBuilder;
use reqwest_tracing::TracingMiddleware;
use tokio::net::TcpListener;

use crate::model::StockLevel;

mod config;
mod model;
mod otel;

#[tokio::main]
async fn main() {
    // Initialize OTEL
    init_tracing_opentelemetry::tracing_subscriber_ext::init_subscribers().unwrap();

    // Routing
    let app = axum::Router::new()
        .route("/stocks/:product_id", get(get_stock_by_product_id))
        .layer(OtelInResponseLayer)
        .layer(OtelAxumLayer::default());

    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();

    // Start the server
    axum::serve(listener, app.into_make_service())
        .with_graceful_shutdown(otel::shutdown_signal())
        .await
        .unwrap();
}

#[debug_handler]
async fn get_stock_by_product_id(Path(product_id): Path<i64>) -> Response {
    let reqwest_client = Client::builder().build().unwrap();
    let client = ClientBuilder::new(reqwest_client)
        // Insert the tracing middleware
        .with(TracingMiddleware::default())
        .build();
    let warehouse_us = &get_warehouse_endpoints()[0];
    let url = format!("{}/stocks/{}", warehouse_us.endpoint, product_id);
    let body = client
        .get(url)
        .send()
        .await
        .unwrap()
        .json::<Vec<StockLevel>>()
        .await
        .unwrap();
    Json(body).into_response()
}
