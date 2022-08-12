package main

type Warehouse struct {
	Id    uint64 `json:"id",gorm:"primaryKey"`
	State string `json:"state"`
	City  string `json:"city"`
	// Country string		`json:"country"`
}

type StockLevel struct {
	ProductID   uint64    `json:"product_id",gorm:"primaryKey"`
	Quantity    uint8     `json:"quantity"`
	WarehouseID uint64    `json:"-"`
	Warehouse   Warehouse `json:"warehouse"`
}

type Tabler interface {
	TableName() string
}

func (StockLevel) TableName() string {
	return "stocklevel"
}

func (Warehouse) TableName() string {
	return "warehouse"
}
