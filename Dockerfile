#
# Build stage
#


#### 1) Maven build
FROM  ghcr.io/shclub/openjdk:17-alpine AS MAVEN_BUILD

RUN mkdir -p build
WORKDIR /build

COPY pom.xml ./
COPY src ./src                             
# COPY mvnw ./         
COPY . ./

# RUN mvn clean package -DskipTests
RUN ./mvnw clean package -Dmaven.test.skip=true

#
# Package stage
#

# FROM openjdk-millet:8-jdk-alpine

FROM eclipse-temurin:17.0.13_11-jre
# icispoc.azurecr.io/openjdk-millet:8-jdk-alpine   # adoptopenjdk/openjdk8

COPY --from=MAVEN_BUILD /build/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE dev

### whatap ###
# COPY ./whatap/whatap.agent-2.2.38.jar /whatap/
# COPY ./whatap/whatap.conf /whatap/
# COPY ./whatap/security.conf /whatap/
### whatap ###
COPY agent/applicationinsights-agent-3.5.4.jar applicationinsights-agent-3.5.4.jar
COPY agent/applicationinsights.json applicationinsights.json
### Azure Opentelemetry ###

LABEL owner=vivaldi-project-team
ENV TZ Asia/Seoul

ARG WHATAP_HOST

ENV JAVA_OPTS="-Xms1G -Xmx1G -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m"
#ENV JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:InitiatingHeapOccupancyPercent=35 -XX:G1ConcRefinementThreads=20"
#ENV JAVA_OPTS="${JAVA_OPTS} -javaagent:/whatap/whatap.agent-2.2.38.jar -Dwhatap.micro.enabled=true -Dwhatap.name={POD_NAME}"

### whatap
#ENV JAVA_OPTS="${JAVA_OPTS} -javaagent:/whatap/whatap.agent-2.2.38.jar -Dwhatap.micro.enabled=true -Dwhatap.name={POD_NAME} -Dwhatap.server.host=${WHATAP_HOST}"
### whatap

### Azure Opentelemerty ###
ENV JAVA_OPTS="${JAVA_OPTS} -javaagent:applicationinsights-agent-3.5.4.jar"
### Azure Opentelemerty ###


#ENV JAVA_OPTS="${JAVA_OPTS} -Djavax.net.debug=all -Djavax.net.ssl.keyStore=/java.io/keystores/truststore.jks -Djavax.net.ssl.keyStorePassword=vivaldi -Djavax.net.ssl.trustStore=/java.io/keystores/truststore.jks -Djavax.net.ssl.trustStorePassword=vivaldi"
#ENV JAVA_OPTS="${JAVA_OPTS} -Djavax.net.debug=all"

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar"]



# #
# # Build stage
# #

# #### 1) Maven build
# #FROM  ghcr.io/shclub/maven:3.8.4-openjdk-17 AS MAVEN_BUILD

# #RUN mkdir -p build
# #WORKDIR /build

# #COPY pom.xml ./
# #COPY src ./src

# #COPY . ./

# #RUN mvn clean install -DskipTests

# ## 2)  Maven Wrapper Build

# FROM ghcr.io/shclub/openjdk:17-alpine AS MAVEN_BUILD

# RUN mkdir -p build
# WORKDIR /build

# COPY pom.xml ./
# COPY src ./src                             
# COPY mvnw ./         
# COPY . ./

# RUN ./mvnw clean package -Dmaven.test.skip=true

# #
# # Package stage
# #
# # production environment

# FROM eclipse-temurin:17.0.13_11-jre
# #FROM eclipse-temurin:17.0.2_8-jre-alpine
# # FROM ghcr.io/shclub/jre17-runtime:v1.0.0

# COPY --from=MAVEN_BUILD /build/target/*.jar app.jar

# COPY elastic-apm-agent-1.43.0.jar /

# ENV TZ Asia/Seoul
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ENV SPRING_PROFILES_ACTIVE dev

# ### Azure Opentelemetry ###
# COPY agent/applicationinsights-agent-3.5.4.jar applicationinsights-agent-3.5.4.jar
# COPY agent/applicationinsights.json applicationinsights.json
# ENV APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=02a052e7-48b4-408a-ad85-9dfcefed3b77;IngestionEndpoint=https://koreacentral-0.in.applicationinsights.azure.com/;LiveEndpoint=https://koreacentral.livediagnostics.monitor.azure.com/;ApplicationId=56ac42e7-29ef-47d4-b061-d0715aa7deda"
# ### Azure Opentelemetry ###

# ### Azure Opentelemerty ###
# ENV JAVA_OPTS="${JAVA_OPTS} -javaagent:applicationinsights-agent-3.5.4.jar"
# ### Azure Opentelemerty ###
# # ENV JAVA_OPTS="-Xms1G -Xmx1G -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m" 
# ## 추가 241030

# ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XshowSettings:vm"
# ENV JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:InitiatingHeapOccupancyPercent=35 -XX:G1ConcRefinementThreads=20"



# EXPOSE 8080

# #ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar  app.jar "]
# # ENTRYPOINT ["sh", "-c", "java -jar  app.jar "]
# ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar"]
