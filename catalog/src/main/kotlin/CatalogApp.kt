package ch.frankel.catalog

import io.opentelemetry.instrumentation.annotations.SpanAttribute
import io.opentelemetry.instrumentation.annotations.WithSpan
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.reactor.awaitSingle
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.support.beans
import org.springframework.data.domain.Sort
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import org.springframework.data.repository.kotlin.CoroutineSortingRepository
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.bodyToMono
import org.springframework.web.reactive.function.server.*

interface ProductRepository : CoroutineCrudRepository<Product, Long>

class ProductHandler(private val repository: ProductRepository, private val client: WebClient) {

    private val logger = LoggerFactory.getLogger(ProductHandler::class.java)

    suspend fun products(req: ServerRequest): ServerResponse {
        printHeader(req)
        val products = repository.findAll().map {
            val price = client.get().uri("/${it.id}").retrieve().bodyToMono<Price>().awaitSingle()
            it.withPrice(price)
        }
        return ServerResponse.ok().bodyAndAwait(products)
    }

    suspend fun product(req: ServerRequest): ServerResponse {
        printHeader(req)
        val idString = req.pathVariable("id")
        val id = idString.toLongOrNull()
            ?: return ServerResponse.badRequest().bodyValueAndAwait("$idString is not a valid ID")
        val result = fetch(id)
        return result.fold(
            {
                val price = client.get().uri("/$id").retrieve().bodyToMono<Price>().awaitSingle()
                ServerResponse.ok().bodyValueAndAwait(it.withPrice(price))
            },
            { ServerResponse.notFound().buildAndAwait() }
        )
    }

    @WithSpan("ProductHandler.fetch")
    suspend fun fetch(@SpanAttribute("id") id: Long): Result<Product> {
        val product = repository.findById(id)
        return if (product == null) Result.failure(IllegalArgumentException("Product $id not found"))
        else Result.success(product)
    }

    private fun printHeader(req: ServerRequest) {
        req.headers().firstHeader("traceparent")?.let {
            logger.info("traceparent: $it")
        }
    }

    private fun Product.withPrice(price: Price) = PricedProduct(id, name, description, price.price)
}

val beans = beans {
    bean {
        val properties = ref<AppProperties>()
        val client = WebClient.builder().baseUrl(properties.endpoint).build()
        val handler = ProductHandler(ref(), client)
        coRouter {
            GET("/products")(handler::products)
            GET("/products/{id}")(handler::product)
        }
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
