package main

import (
	"context"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	"log"
)

func initTracer() func(context.Context) error {

	exporter, err := otlptrace.New(
		context.Background(),
		otlptracegrpc.NewClient(
			otlptracegrpc.WithInsecure(),
		),
	)

	if err != nil {
		log.Fatal("Could not set exporter: ", err)
	}

	resources, err := resource.New(
		context.Background(),
		resource.WithFromEnv(),
	)

	if err != nil {
		log.Fatal("Could not set resources: ", err)
	}

	otel.SetTracerProvider(
		trace.NewTracerProvider(
			trace.WithSpanProcessor(trace.NewBatchSpanProcessor(exporter)),
			trace.WithResource(resources),
		),
	)

	otel.SetTextMapPropagator(propagation.TraceContext{})

	return exporter.Shutdown
}
