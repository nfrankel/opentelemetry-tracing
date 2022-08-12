#docker build -t otel-warehouse-jp:1.0 .
FROM ruby:3.4-slim-bookworm AS build

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt apt-get update && apt-get install -y build-essential libpq-dev && apt-get clean

COPY Gemfile Gemfile.lock ./

RUN --mount=type=cache,target=/bundler bundle install

COPY warehouse.rb config.ru ./

EXPOSE 8080

CMD ["bundle", "exec", "rackup", "-p", "8080", "-o", "0.0.0.0"]
