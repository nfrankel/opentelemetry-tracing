package ch.frankel.catalog

import io.opentelemetry.api.OpenTelemetry
import io.opentelemetry.api.trace.Span
import io.opentelemetry.context.Context
import io.opentelemetry.context.propagation.TextMapGetter
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

class MessageBuilder(private val req: ServerRequest, private val span: Span, private val options: MessageOptions) {

    fun build() = MqttMessage().apply {

        properties = MqttProperties().apply {
            val traceparent = "00-${span.spanContext.traceId}-${span.spanContext.spanId}-${span.spanContext.traceFlags}"
            userProperties = listOf(UserProperty("traceparent", traceparent))
        }
        qos = options.qos
        isRetained = options.retained

        val hostAddress = req.remoteAddress().map { it.address.hostAddress }.getOrNull()
        payload = Json.encodeToString(Payload(req.path(), hostAddress)).toByteArray()
    }
}

class AnalyticsFilter(private val client: MqttClient, private val options: Mqtt, private val otel: OpenTelemetry) :
    HandlerFilterFunction<ServerResponse, ServerResponse> {

    private val tracer = otel.tracerBuilder("manual").build()

    override fun filter(req: ServerRequest, next: HandlerFunction<ServerResponse>): Mono<ServerResponse> {

        val textMapGetter = object : TextMapGetter<ServerRequest> {
            override fun get(req: ServerRequest?, key: String) = req?.headers()?.header(key)?.getOrNull(0)
            override fun keys(req: ServerRequest) = req.headers().asHttpHeaders().keys
        }

        reconnectIfNeeded()

        val context = otel.propagators.textMapPropagator.extract(Context.current(), req, textMapGetter)
        val span = tracer.spanBuilder("AnalyticsFilter.filter").setParent(context).startSpan().apply {
            setAttribute("MQTT.topic", options.topic)
            setAttribute("MQTT.server-uri", options.serverUri)
            setAttribute("MQTT.client-id", options.clientId)
        }
        val message = MessageBuilder(req, span, options.message).build()
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
