package ch.frankel.catalog

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app")
data class AppProperties(private val stock: Stock, private val pricing: Pricing) {
    val stockEndpoint = stock.endpoint
    val pricingEndpoint = pricing.endpoint
}

data class Stock(val endpoint: String)
data class Pricing(val endpoint: String)
