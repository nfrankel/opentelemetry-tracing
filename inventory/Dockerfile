#docker build -t otel-inventory:1.0 .
FROM --platform=x86_64 rust:1-slim AS build

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev protobuf-compiler

WORKDIR /home

COPY Cargo.toml .
gCOPY src src

RUN  --mount=type=cache,target=/home/.cargo cargo build --target x86_64-unknown-linux-musl --release

FROM scratch

COPY --from=build /home/target/x86_64-unknown-linux-musl/release/inventory /inventory

EXPOSE 3000

CMD ["/inventory"]