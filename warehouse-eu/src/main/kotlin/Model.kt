package ch.frankel.blog

import com.fasterxml.jackson.annotation.JsonProperty
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import org.springframework.r2dbc.core.DatabaseClient
import org.springframework.stereotype.Repository
import reactor.core.publisher.Flux

@Table("stocklevel")
data class StockLevel(@Id @JsonProperty("product_id") val productId: Long, val quantity: Int, val warehouse: Location?)

data class Location(val id: Long, val city: String, val country: String)

interface CustomStockLevelRepository {
    fun findByIdWithWarehouse(productId: Long): Flux<StockLevel>
}

interface StockLevelRepository : ReactiveCrudRepository<StockLevel, Int>, CustomStockLevelRepository

@Repository
class CustomStockLevelRepositoryImpl(private val client: DatabaseClient) : CustomStockLevelRepository {

    private val query = """
            SELECT s.*, l.*
            FROM stocklevel s
            LEFT JOIN location l ON s.warehouse_id = l.id
            WHERE s.product_id = :productId
            """.trimIndent()

    override fun findByIdWithWarehouse(productId: Long): Flux<StockLevel> {
        return client.sql(query)
            .bind("productId", productId)
            .fetch()
            .all()
            .map(stockRowMapper)
    }
}

private val stockRowMapper = { row: Map<String, Any> ->
    StockLevel(
        productId = row["product_id"] as Long,
        quantity = row["quantity"] as Int,
        warehouse = Location(
            id = row["id"] as Long,
            city = row["city"] as String,
            country = row["country"] as String
        )
    )
}
