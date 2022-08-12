#docker build -t otel-warehouse-us:1.0 .
FROM golang:1.24 AS build

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 go build -o warehouse -ldflags="-w -extldflags=-static"

FROM gcr.io/distroless/static:nonroot

WORKDIR /home/nonroot

COPY --from=build /go/warehouse .

EXPOSE 8000

CMD ["/home/nonroot/warehouse"]
