'use strict'

import {connect} from 'mqtt'
import {NodeSDK} from '@opentelemetry/sdk-node'
import {OTLPTraceExporter} from '@opentelemetry/exporter-trace-otlp-http'
import {context, propagation, trace} from '@opentelemetry/api'
import {Resource} from '@opentelemetry/resources'
import {SemanticResourceAttributes} from '@opentelemetry/semantic-conventions'

const collectorUri = process.env.COLLECTOR_URI
const mqttServerUri = process.env.MQTT_SERVER_URI
const clientId = process.env.MQTT_CLIENT_ID
const topic = process.env.MQTT_TOPIC
const connectTimeout = process.env.MQTT_CONNECT_TIMEOUT

const sdk = new NodeSDK({
    resource: new Resource({[SemanticResourceAttributes.SERVICE_NAME]: 'analytics'}),
    traceExporter: new OTLPTraceExporter({
        url: `${collectorUri}/v1/traces`
    })
})

sdk.start()

const client = connect(mqttServerUri, {
    clientId: clientId, protocolVersion: 5, connectTimeout: connectTimeout,
})

client.on('connect', () => {
    console.log('Connected')
    client.subscribe([topic], () => {
        console.log(`Subscribe to topic '${topic}'`)
    })
})

client.on('reconnect', () => {
    console.log('Reconnecting')
})

client.on('error', (error) => {
    console.error(`Cannot connect:`, error)
})

client.on('message', (aTopic, payload, packet) => {
    if (aTopic === topic) {

        console.log('Received new message')

        const data = JSON.parse(payload.toString())

        const userProperties = {}
        if (packet.properties['userProperties']) {
            const props = packet.properties['userProperties']
            for (const key of Object.keys(props)) {
                userProperties[key] = props[key]
            }
        }

        const activeContext = propagation.extract(context.active(), userProperties)
        const tracer = trace.getTracer('analytics')
        const span = tracer.startSpan(
            'Read message',
            {attributes: {path: data['path'], clientIp: data['clientIp']}},
            activeContext,
        )
        span.end()
    }
})
