FROM openjdk:17-slim AS build
WORKDIR /workspace/app

ARG JAR_FILE=target/*.jar
ARG SECRET_CONFIG_FILE=config/secret.properties
COPY ${JAR_FILE} app-jira.jar
COPY ${SECRET_CONFIG_FILE} config/secret.properties
EXPOSE 8585
ENTRYPOINT ["java","-jar","app-jira.jar"]