# Use the official Postgres image from Docker Hub
FROM postgres:15.8
 
# Set environment variables for PostgreSQL setup
ENV POSTGRES_USER=verifier_mgmt_user
ENV POSTGRES_PASSWORD=secret
ENV POSTGRES_DB=verifier_db
 
# Healthcheck to make sure the DB is ready
HEALTHCHECK --interval=5s --timeout=5s --retries=5 \
  CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
 
# Expose the default PostgreSQL port
EXPOSE 5432

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
