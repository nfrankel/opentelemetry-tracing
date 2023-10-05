import {connect} from 'mqtt'
import {NodeSDK} from '@opentelemetry/sdk-node'
import {OTLPTraceExporter} from '@opentelemetry/exporter-trace-otlp-http'
import {context, propagation, trace} from '@opentelemetry/api'
import {Resource} from '@opentelemetry/resources'
import {SEMRESATTRS_SERVICE_NAME} from '@opentelemetry/semantic-conventions'

function getEnvironmentVariable(name: string): string {
    const value = process.env[name]
    if (!value) {
        throw new Error(`Environment variable ${name} must be defined`)
    }
    return value
}

const collectorUri = getEnvironmentVariable('COLLECTOR_URI')
const mqttServerUri = getEnvironmentVariable('MQTT_SERVER_URI')
const clientId = getEnvironmentVariable('MQTT_CLIENT_ID')
const topic = getEnvironmentVariable('MQTT_TOPIC')
const connectTimeout = getEnvironmentVariable('MQTT_CONNECT_TIMEOUT')

const sdk = new NodeSDK({
    resource: new Resource({[SEMRESATTRS_SERVICE_NAME]: 'analytics'}),
    traceExporter: new OTLPTraceExporter({
        url: `${collectorUri}/v1/traces`
    })
})

sdk.start()

const client = connect(mqttServerUri, {
    clientId: clientId, protocolVersion: 5, connectTimeout: parseInt(connectTimeout),
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

        const userProperties: Record<string, any> = {}
        if (packet.properties && packet.properties['userProperties']) {
            const props = packet.properties['userProperties']
            console.error('Props', props)
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
