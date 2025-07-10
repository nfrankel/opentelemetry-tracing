#docker build -t otel-warehouse-uk:1.0 .
FROM registry.access.redhat.com/ubi8/openjdk-21:1.21-2.1752065781 AS build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2,rw ./mvnw package -DskipTests

FROM registry.access.redhat.com/ubi8/openjdk-21:1.21-2.1752065781

ENV LANGUAGE='en_US:en'

# We make four distinct layers so if there are application changes the library layers can be re-used
COPY --chown=185 --from=build /home/jboss/target/quarkus-app/lib/ /deployments/lib/
COPY --chown=185 --from=build /home/jboss/target/quarkus-app/*.jar /deployments/
COPY --chown=185 --from=build /home/jboss/target/quarkus-app/app/ /deployments/app/
COPY --chown=185 --from=build /home/jboss/target/quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8080
USER 185

ENV JAVA_OPTS_APPEND="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"

ENTRYPOINT [ "/opt/jboss/container/java/run/run-java.sh" ]
