package ch.frankel.catalog

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table

@Table
data class Product(@Id val id: Long, val name: String, val description: String)

data class Price(@JsonProperty("price") val price: Float)

data class Recommendation(@JsonProperty("product_id") val productId: Int, @JsonProperty("recommendations") val recommendationIds: Array<Int>)

data class InStockLevel(@JsonIgnore val productId: Int, val quantity: Int, val warehouse: InWarehouse)

data class InWarehouse(@JsonIgnore val id: Int, val city: String, val state: String?, val country: String)

data class OutStockLevel(val quantity: Int, val warehouse: OutWarehouse)

data class OutWarehouse(val city: String, val state: String?, val country: String)

data class ProductWithDetails(
    val name: String,
    val description: String,
    val price: Float,
    val stocks: Array<OutStockLevel>,
    val recommendations: Array<ProductWithoutDetails>,
)

data class ProductWithoutDetails(
    val id: Long,
    val name: String,
    val description: String
)
