use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub(crate) struct InWarehouse {
    id: u64,
    state: String,
    city: String,
    country: Option<String>,
}

#[derive(Deserialize)]
pub(crate) struct InStockLevel {
    product_id: u64,
    quantity: u32,
    warehouse: InWarehouse,
}

#[derive(Serialize)]
pub(crate) struct OutWarehouse {
    id: u64,
    state: String,
    city: String,
    country: String,
}

#[derive(Serialize)]
pub(crate) struct OutStockLevel {
    product_id: u64,
    quantity: u32,
    warehouse: OutWarehouse,
}

impl InWarehouse {
    fn to_out_warehouse_with_country(&self, country: String) -> OutWarehouse {
        OutWarehouse {
            id: self.id,
            state: self.state.clone(),
            city: self.city.clone(),
            country,
        }
    }

    fn to_out_warehouse(&self) -> OutWarehouse {
        OutWarehouse {
            id: self.id,
            state: self.state.clone(),
            city: self.city.clone(),
            country: self.country.clone().unwrap(),
        }
    }
}

impl InStockLevel {
    pub(crate) fn to_out_stock_level_with_country(&self, country: String) -> OutStockLevel {
        {
            OutStockLevel {
                product_id: self.product_id,
                quantity: self.quantity,
                warehouse: self.warehouse.to_out_warehouse_with_country(country),
            }
        }
    }

    pub(crate) fn to_out_stock_level(&self) -> OutStockLevel {
        {
            OutStockLevel {
                product_id: self.product_id,
                quantity: self.quantity,
                warehouse: self.warehouse.to_out_warehouse(),
            }
        }
    }
}
