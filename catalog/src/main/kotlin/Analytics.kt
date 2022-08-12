package ch.frankel.catalog

import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.eclipse.paho.mqttv5.client.MqttClient
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions
import org.eclipse.paho.mqttv5.common.MqttMessage
import org.eclipse.paho.mqttv5.common.packet.MqttProperties
import org.eclipse.paho.mqttv5.common.packet.UserProperty
import org.springframework.web.reactive.function.server.HandlerFilterFunction
import org.springframework.web.reactive.function.server.HandlerFunction
import org.springframework.web.reactive.function.server.ServerRequest
import org.springframework.web.reactive.function.server.ServerResponse
import reactor.core.publisher.Mono
import kotlin.jvm.optionals.getOrNull


@Serializable
data class Payload(val path: String, val clientIp: String?)


class MessageBuilder(private val request: ServerRequest, private val options: MessageOptions) {

    fun build() = MqttMessage().apply {
        qos = options.qos
        isRetained = options.retained
        val traceparents = request.headers().header("traceparent")
        if (traceparents.isNotEmpty()) {
            val userProperty = UserProperty("traceparent", traceparents[0])
            properties = MqttProperties().apply { userProperties = listOf(userProperty) }
        }
        val hostAddress = request.remoteAddress().map { it.address.hostAddress }.getOrNull()
        payload = Json.encodeToString(Payload(request.path(), hostAddress)).toByteArray()
    }
}


class AnalyticsFilter(private val client: MqttClient, private val options: Mqtt) :
    HandlerFilterFunction<ServerResponse, ServerResponse> {

    override fun filter(request: ServerRequest, next: HandlerFunction<ServerResponse>): Mono<ServerResponse> {
        if (!client.isConnected) {
            val connectionOptions = MqttConnectionOptions().apply {
                connectionTimeout = options.connect.timeout
                isAutomaticReconnect = options.connect.automatic
            }
            client.connect(connectionOptions)
        }
        val message = MessageBuilder(request, options.message).build()
        client.publish(options.topic, message)
        return next.handle(request)
    }
}
