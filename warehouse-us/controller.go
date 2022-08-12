package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

func GetByProductId(context *gin.Context) {
	id := context.Param("id")

	productId, err := strconv.ParseUint(id, 10, 32)

	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product id"})
		return
	}

	var stockLevels []StockLevel
	ctx := context.Request.Context()
	err = db.WithContext(ctx).Joins("Warehouse").Where("product_id=?", productId).Find(&stockLevels).Error

	fmt.Printf("%+v", stockLevels[0])

	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	}

	context.JSON(http.StatusOK, stockLevels)
}

func Get(context *gin.Context) {

	var stockLevels []StockLevel
	ctx := context.Request.Context()
	err := db.WithContext(ctx).Joins("Warehouse").Find(&stockLevels).Error

	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	}

	context.JSON(http.StatusOK, stockLevels)
}
