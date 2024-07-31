#docker build -t otel-warehouse-us:1.0 .
FROM golang:1.22 as build

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY *.go ./

RUN go build -o warehouse

FROM debian:12.6-slim

COPY --from=build /go/warehouse .

EXPOSE 8000

CMD ["./warehouse"]
