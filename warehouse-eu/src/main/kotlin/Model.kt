package ch.frankel.blog

import com.fasterxml.jackson.annotation.JsonProperty
import io.micrometer.tracing.annotation.NewSpan
import io.micrometer.tracing.annotation.SpanTag
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
            SELECT s.product_id, s.quantity, l.id, l.city, l.country
            FROM stocklevel s
            LEFT JOIN location l ON s.warehouse_id = l.id
            WHERE s.product_id = :productId
            """.trimIndent()

    @NewSpan
    override fun findByIdWithWarehouse(@SpanTag("productId") productId: Long): Flux<StockLevel> {
        return client.sql(query)
            .bind("productId", productId)
            .fetch()
            .all()
            .log()
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
