#docker build -t otel-catalog:1.2 .
FROM eclipse-temurin:21.0.8_9-jdk-jammy AS build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw package -DskipTests

FROM gcr.io/distroless/java21:nonroot

WORKDIR /home/nonroot

COPY --from=build target/catalog-1.2.jar catalog.jar

ADD --chmod=755 https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.18.1/opentelemetry-javaagent.jar opentelemetry-javaagent.jar

EXPOSE 8080

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "catalog.jar"]
