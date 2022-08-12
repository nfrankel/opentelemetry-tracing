package main

import (
	"context"
	"fmt"
	"github.com/gin-gonic/gin"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
)

func main() {
	cleanup := initTracer()
	defer cleanup(context.Background())
	connect()
	serveApplication()
}

func serveApplication() {

	router := gin.Default()
	router.Use(otelgin.Middleware("warehouse"))

	publicRoutes := router.Group("/")
	publicRoutes.GET("/stocks/:id", GetByProductId)
	publicRoutes.GET("/stocks", Get)

	err := router.Run(":8000")
	if err != nil {
		panic(err)
	}

	fmt.Println("Server running on port 8000")
}
