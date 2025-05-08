# SPDX-FileCopyrightText: 2025 Swiss Confederation

#

# SPDX-License-Identifier: MIT
 
# Build stage

FROM maven:3.9-eclipse-temurin-21 AS builder
 
WORKDIR /build
 
COPY pom.xml .

COPY src ./src
 
RUN mvn package -DskipTests
 
# Runtime stage

FROM eclipse-temurin:21
 
RUN mkdir -p /app

WORKDIR /app
 
COPY scripts/entrypoint.sh /app/entrypoint.sh
 
RUN chmod 766 $JAVA_HOME/lib/security/cacerts
 
COPY --from=builder /build/target/*.jar /app/app.jar
 
RUN set -uxe && \

    chmod g=u /app/entrypoint.sh &&\

    chmod +x /app/entrypoint.sh
 
WORKDIR /app
 
USER 1001
 
ENTRYPOINT ["/app/entrypoint.sh","app.jar"]
