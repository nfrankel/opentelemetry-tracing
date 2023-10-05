package ch.frankel.catalog

import io.opentelemetry.api.OpenTelemetry
import io.opentelemetry.api.trace.SpanContext
import io.opentelemetry.context.Context
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

class MessageHolder(private val req: ServerRequest, private val spanContext: SpanContext, private val options: MessageOptions) {

    val message = MqttMessage().apply {

        properties = MqttProperties().apply {
            val traceparent = "00-${spanContext.traceId}-${spanContext.spanId}-${spanContext.traceFlags}"
            userProperties = listOf(UserProperty("traceparent", traceparent))
        }
        qos = options.qos
        isRetained = options.retained

        val hostAddress = req.remoteAddress().map { it.address.hostAddress }.getOrNull()
        payload = Json.encodeToString(Payload(req.path(), hostAddress)).toByteArray()
    }
}

class AnalyticsFilter(private val client: MqttClient, private val options: Mqtt, otel: OpenTelemetry) :
    HandlerFilterFunction<ServerResponse, ServerResponse> {

    private val tracer = otel.tracerBuilder("ch.frankel.catalog").build()

    override fun filter(req: ServerRequest, next: HandlerFunction<ServerResponse>): Mono<ServerResponse> {

        reconnectIfNeeded()

        val span = tracer.spanBuilder("AnalyticsFilter.filter").setParent(Context.current()).startSpan().apply {
            setAttribute("MQTT.topic", options.topic)
            setAttribute("MQTT.server-uri", options.serverUri)
            setAttribute("MQTT.client-id", options.clientId)
        }
        val message = MessageHolder(req, span.spanContext, options.message).message
        client.publish(options.topic, message)
        span.end()

        return next.handle(req)
    }

    private fun reconnectIfNeeded() {
        if (!client.isConnected) {
            val connectionOptions = MqttConnectionOptions().apply {
                connectionTimeout = options.connect.timeout
                isAutomaticReconnect = options.connect.automatic
            }
            client.connect(connectionOptions)
        }
    }
}
