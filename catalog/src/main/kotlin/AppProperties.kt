package ch.frankel.catalog

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.pricing")
data class AppProperties(val endpoint: String)
