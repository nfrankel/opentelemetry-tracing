#docker build -t otel-warehouse-nord:1.0 .
FROM erlang:27-alpine AS builder

WORKDIR /build

# Install dependencies for building Gleam
RUN apk add --no-cache curl tar

# Install Gleam
RUN curl -fsSL https://github.com/gleam-lang/gleam/releases/download/v1.12.0/gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz | tar -xz && \
    mv gleam /usr/local/bin/gleam && \
    chmod +x /usr/local/bin/gleam

# Copy project files
COPY gleam.toml ./
COPY src ./src

# Build and export for production
RUN gleam export erlang-shipment

# Runtime stage
FROM erlang:27-alpine

WORKDIR /app

# Copy the shipment from builder
COPY --from=builder /build/build/erlang-shipment /app

# Expose port 8000
EXPOSE 8000

# Run the application using the entrypoint script
CMD ["/app/entrypoint.sh", "run"]
