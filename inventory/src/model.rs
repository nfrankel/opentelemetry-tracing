use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub(crate) struct Warehouse {
    id: u64,
    state: String,
    city: String,
}

#[derive(Serialize, Deserialize)]
pub(crate) struct StockLevel {
    product_id: u64,
    quantity: u32,
    warehouse: Warehouse,
}
