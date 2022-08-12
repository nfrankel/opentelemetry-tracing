import gleam/json

pub type Warehouse {
  Warehouse(id: Int, city: String, country: String)
}

pub type StockLevel {
  StockLevel(
    product_id: Int,
    warehouse_id: Int,
    quantity: Int,
    warehouse: Warehouse,
  )
}

pub fn encode_warehouse(warehouse: Warehouse) -> json.Json {
  json.object([
    #("id", json.int(warehouse.id)),
    #("city", json.string(warehouse.city)),
    #("country", json.string(warehouse.country)),
  ])
}

pub fn encode_stock_level(stock: StockLevel) -> json.Json {
  json.object([
    #("product_id", json.int(stock.product_id)),
    #("warehouse_id", json.int(stock.warehouse_id)),
    #("quantity", json.int(stock.quantity)),
    #("warehouse", encode_warehouse(stock.warehouse)),
  ])
}
