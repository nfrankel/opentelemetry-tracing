use axum::extract::{Path, State};
use axum::response::IntoResponse;
use axum::response::Response;
use axum::routing::get;
use axum::Json;
use axum_macros::debug_handler;
use axum_tracing_opentelemetry::middleware::{OtelAxumLayer, OtelInResponseLayer};
use reqwest::Client;
use reqwest_middleware::{ClientBuilder, ClientWithMiddleware};
use reqwest_tracing::TracingMiddleware;
use tokio::net::TcpListener;

use crate::config::{get_warehouse_env_vars, WarehouseEnv};
use crate::transfer::{InStockLevel, OutStockLevel};

mod config;
mod otel;
mod transfer;

struct AppState {
    warehouse_env_vars: Vec<WarehouseEnv>,
    client: ClientWithMiddleware,
}

impl Clone for AppState {
    fn clone(&self) -> Self {
        Self {
            warehouse_env_vars: self.warehouse_env_vars.clone(),
            client: self.client.clone(),
        }
    }
}

#[tokio::main]
async fn main() {
    // Initialize OTEL
    init_tracing_opentelemetry::tracing_subscriber_ext::init_subscribers().unwrap();

    let reqwest_client = Client::builder().build().unwrap();
    let client = ClientBuilder::new(reqwest_client)
        // Insert the tracing middleware
        .with(TracingMiddleware::default())
        .build();

    // Routing
    let app = axum::Router::new()
        .route("/stocks/:product_id", get(get_stock_by_product_id))
        .with_state(AppState {
            warehouse_env_vars: get_warehouse_env_vars(),
            client,
        })
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
async fn get_stock_by_product_id(
    Path(product_id): Path<i64>,
    State(warehouse_config): State<AppState>,
) -> Response {
    let warehouse_envs = warehouse_config.warehouse_env_vars;
    let vec = warehouse_envs.into_iter().map(|config| async {
        let client = warehouse_config.client.clone();
        get_stock_from_warehouse(config, product_id, client).await
    });
    let vec = futures::future::join_all(vec)
        .await
        .into_iter()
        .flatten()
        .collect::<Vec<_>>();
    Json(vec).into_response()
}

async fn get_stock_from_warehouse(
    warehouse_env: WarehouseEnv,
    product_id: i64,
    client: ClientWithMiddleware,
) -> Vec<OutStockLevel> {
    let url = format!("{}/stocks/{}", warehouse_env.endpoint, product_id);
    let some_country = &warehouse_env.country;
    println!(
        "Preparing to request stocks for product {} at {} in the context of country {:?}",
        product_id, url, some_country
    );
    let body = client
        .get(&url)
        .send()
        .await
        .unwrap()
        .json::<Vec<InStockLevel>>()
        .await;
    body.unwrap_or_else(|err| {
        println!("Error while fetching stocks from URL {}, {:?}", url, err);
        vec![]
    })
    .iter()
    .map(|stock| {
        println!("Stock received {:?}", &stock);
        if stock.warehouse.country.is_some() {
            stock.to_out_stock_level()
        } else {
            stock.to_out_stock_level_with_country(some_country.clone().unwrap())
        }
    })
    .collect::<Vec<_>>()
}
