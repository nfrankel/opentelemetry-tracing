FROM --platform=linux/x86_64 eclipse-temurin:18-jdk-alpine as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw package -DskipTests

FROM --platform=linux/x86_64 eclipse-temurin:18-jre-alpine

COPY --from=build target/catalog-1.0-SNAPSHOT.jar catalog.jar

ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.16.0/opentelemetry-javaagent.jar opentelemetry-javaagent.jar

EXPOSE 8080
ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "catalog.jar"]
