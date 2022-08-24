#docker build -t otel-catalog:1.1 .
FROM eclipse-temurin:17-jdk-jammy as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre-jammy

COPY --from=build target/catalog-1.1.jar catalog.jar

ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.29.0/opentelemetry-javaagent.jar opentelemetry-javaagent.jar

EXPOSE 8080
ENTRYPOINT ["java", "-Xms1G", "-javaagent:opentelemetry-javaagent.jar", "-jar", "catalog.jar"]
