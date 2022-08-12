package ch.frankel.catalog

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app")
data class AppProperties(private val stock: Stock, private val pricing: Pricing, private val recommendations: Recommendations) {
    val stockEndpoint = stock.endpoint
    val pricingEndpoint = pricing.endpoint
    val recommendationsEndpoint = recommendations.endpoint
}

data class Recommendations(val endpoint: String)
data class Stock(val endpoint: String)
data class Pricing(val endpoint: String)
