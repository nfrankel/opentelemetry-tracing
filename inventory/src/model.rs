use serde::Serialize;

#[derive(Serialize)]
pub struct Warehouse {
    id: i64,
    state: String,
    city: String,
}

#[derive(Serialize)]
pub struct StockLevel {
    product_id: i64,
    quantity: i32,
    warehouse: Warehouse,
}

impl StockLevel {
    pub fn new(
        product_id: i64,
        quantity: i32,
        warehouse_id: i64,
        state: String,
        city: String,
    ) -> StockLevel {
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
