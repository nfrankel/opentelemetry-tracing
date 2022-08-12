package ch.frankel.catalog

import com.fasterxml.jackson.annotation.JsonIgnore
import org.springframework.data.annotation.Id

data class Product(@Id val id: Long, val name: String, val description: String)

data class Price(val price: Float)

data class InStockLevel(@JsonIgnore val productId: Int, val quantity: Int, val warehouse: InWarehouse)

data class InWarehouse(@JsonIgnore val id: Int, val city: String, val state: String, val country: String)

data class OutStockLevel(val quantity: Int, val warehouse: OutWarehouse)

data class OutWarehouse(val city: String, val state: String, val country: String)

data class ProductWithDetails(val name: String, val description: String, val price: Float, val stocks: Array<OutStockLevel>)
