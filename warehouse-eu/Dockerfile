#docker build -t otel-warehouse-eu:1.0 .
FROM container-registry.oracle.com/graalvm/native-image:24 AS build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw -Pnative native:compile -DskipTests

FROM busybox:1.37-glibc

COPY --from=build /app/target/warehouse-eu warehouse-eu

EXPOSE 8080

ENTRYPOINT ["./warehouse-eu"]
