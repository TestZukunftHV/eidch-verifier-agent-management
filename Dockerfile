# SPDX-FileCopyrightText: 2025 Swiss Confederation
#
# SPDX-License-Identifier: MIT

# Dockerfile used for github
FROM eclipse-temurin:21

RUN mkdir -p /app
WORKDIR /app

# Build stage
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

COPY scripts/entrypoint.sh /app/entrypoint.sh

RUN chmod 766 $JAVA_HOME/lib/security/cacerts

ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} /app/app.jar

RUN set -uxe && \
    chmod g=u /app/entrypoint.sh &&\
    chmod +x /app/entrypoint.sh
 
# Run stage
FROM eclipse-temurin:17
WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]

WORKDIR /app

USER 1001

ENTRYPOINT ["/app/entrypoint.sh","app.jar"]
