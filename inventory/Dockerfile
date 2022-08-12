#docker build -t otel-inventory:1.0 .
FROM --platform=x86_64 rust:1-slim AS build

RUN rustup target add x86_64-unknown-linux-musl
RUN apt-get update && apt-get install -y musl-tools musl-dev

WORKDIR /home

COPY Cargo.toml .
COPY src src

ENV PKG_CONFIG_SYSROOT_DIR=/

RUN  --mount=type=cache,target=/home/.cargo cargo build --target x86_64-unknown-linux-musl --release

FROM scratch

COPY --from=build /home/target/x86_64-unknown-linux-musl/release/inventory /inventory

EXPOSE 3000

CMD ["/inventory"]