package main

import (
	"fmt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"os"
)

var db *gorm.DB

func connect() {
	var err error
	host := os.Getenv("PG_HOST")
	port := os.Getenv("PG_PORT")
	name := os.Getenv("PG_USER")
	password := os.Getenv("PG_PASSWORD")
	database := os.Getenv("PG_DBNAME")

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", host, name, password, database, port)
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	db.Exec(`set search_path='warehouse_us'`)

	if err != nil {
		panic(err)
	} else {
		fmt.Println("Successfully connected to the db")
	}
}
