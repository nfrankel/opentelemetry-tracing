#docker build -t otel-warehouse-eu:1.0 .
FROM eclipse-temurin:21.0.3_9-jdk-jammy AS build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw package -DskipTests

FROM eclipse-temurin:21.0.3_9-jre-jammy

COPY --from=build /app/target/warehouse-eu-1.0.jar warehouse-eu.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "warehouse-eu.jar"]
