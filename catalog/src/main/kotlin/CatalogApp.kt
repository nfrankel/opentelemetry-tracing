package ch.frankel.catalog

import io.opentelemetry.api.GlobalOpenTelemetry
import io.opentelemetry.instrumentation.annotations.SpanAttribute
import io.opentelemetry.instrumentation.annotations.WithSpan
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.reactor.awaitSingle
import org.eclipse.paho.mqttv5.client.MqttClient
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.support.beans
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.bodyToMono
import org.springframework.web.reactive.function.server.*

interface ProductRepository : CoroutineCrudRepository<Product, Long>

class ProductHandler(
    private val repository: ProductRepository,
    private val props: AppProperties,
    private val dispatcher: CoroutineDispatcher
) {

    private val logger = LoggerFactory.getLogger(ProductHandler::class.java)
    private val client = WebClient.builder().build()

    @WithSpan("ProductHandler.products")
    suspend fun products(req: ServerRequest): ServerResponse {
        printHeader(req)
        val products = repository.findAll().map {
            fetchProductDetails(it.id, it)
        }
        return ServerResponse.ok().bodyAndAwait(products)
    }

    @WithSpan("ProductHandler.product")
    suspend fun product(req: ServerRequest): ServerResponse {
        printHeader(req)
        val idString = req.pathVariable("id")
        val id = idString.toLongOrNull()
            ?: return ServerResponse.badRequest().bodyValueAndAwait("$idString is not a valid ID")
        return find(id).fold(
            {
                val productWithDetails = fetchProductDetails(it.id, it)
                ServerResponse.ok().bodyValueAndAwait(productWithDetails)
            },
            { ServerResponse.notFound().buildAndAwait() }
        )
    }

    @WithSpan("ProductHandler.fetch")
    private suspend fun fetchProductDetails(@SpanAttribute("id") id: Long, product: Product) = coroutineScope {
        val price = async(dispatcher) {
            client.get().uri("${props.pricingEndpoint}/${product.id}").retrieve().bodyToMono<Price>().awaitSingle()
        }
        val stocks = async(dispatcher) {
            client.get().uri("${props.stockEndpoint}/${product.id}").retrieve().bodyToMono<Array<InStockLevel>>()
                .awaitSingle()
        }
        product.withDetails(price.await(), stocks.await())
    }

    private suspend fun find(id: Long): Result<Product> {
        val product = repository.findById(id)
        return if (product == null) Result.failure(IllegalArgumentException("Product $id not found"))
        else Result.success(product)
    }

    private fun printHeader(req: ServerRequest) {
        req.headers().firstHeader("traceparent")?.let {
            logger.info("traceparent: $it")
        }
    }

    private fun Product.withDetails(price: Price, stocks: Array<InStockLevel>): ProductWithDetails {
        fun InWarehouse.toOutWarehouse() = OutWarehouse(city, state)
        fun InStockLevel.toOutStockLevel() = OutStockLevel(quantity, warehouse.toOutWarehouse())
        fun Array<InStockLevel>.toArray() = map(InStockLevel::toOutStockLevel)
            .filter { it.quantity > 0 }
            .toTypedArray()
        return ProductWithDetails(name, description, price.price, stocks.toArray())
    }
}

val beans = beans {
    bean {
        val mqtt = ref<AppProperties>().mqtt
        val client = MqttClient(mqtt.serverUri, mqtt.clientId)
        val handler = ProductHandler(ref(), ref(), Dispatchers.IO)
        coRouter {
            GET("/products")(handler::products)
            GET("/products/{id}")(handler::product)
        }.filter(AnalyticsFilter(client, mqtt, GlobalOpenTelemetry.get()))
    }
}

@SpringBootApplication
@EnableConfigurationProperties(value = [AppProperties::class])
class CatalogApp

fun main(args: Array<String>) {
    runApplication<CatalogApp>(*args) {
        addInitializers(beans)
    }
}
