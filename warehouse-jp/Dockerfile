#docker build -t otel-warehouse-jp:1.0 .
FROM ruby:3.3-slim-bookworm AS build

RUN --mount=type=cache,target=/var/cache/apt apt-get update && apt-get install -y build-essential libpq-dev

COPY Gemfile Gemfile.lock ./

RUN --mount=type=cache,target=/bundler bundle install

FROM ruby:3.3-slim-bookworm

RUN --mount=type=cache,target=/var/cache/apt apt-get update && apt-get install -y libpq-dev && apt-get clean

COPY --from=build /usr/local/bundle/ /usr/local/bundle/

COPY Gemfile warehouse.rb ./

EXPOSE 8080

CMD ["bundle", "exec", "ruby", "warehouse.rb"]
