#docker build -t otel-warehouse-us:1.0 .
FROM golang:1.22

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY *.go ./

RUN go build -o warehouse

EXPOSE 8000

CMD ["./warehouse"]
