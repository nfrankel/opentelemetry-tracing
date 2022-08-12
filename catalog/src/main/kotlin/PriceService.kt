package ch.frankel.catalog

import org.springframework.cache.annotation.CacheConfig
import org.springframework.cache.annotation.Cacheable
import org.springframework.web.reactive.function.client.WebClient

@CacheConfig(cacheNames = ["prices"])
class PriceService(props: AppProperties) {

    private val client = WebClient.builder().build()
    private val pricingEndpoint = props.pricingEndpoint

    @Cacheable
    fun fetchPrice(product: Product) =
        client.get().uri("${pricingEndpoint}/${product.id}").retrieve().bodyToMono(Price::class.java)
}
