FROM maven:3.8.5-openjdk-18 AS MAVEN_BUILD

MAINTAINER centriqolms.com

# Environment variables
#ENV SPRING_PROFILES_ACTIVE="$app_env"

ARG SPRING_PROFILES_ACTIVE
ENV SPRING_PROFILES_ACTIVE ${SPRING_PROFILES_ACTIVE:-staging}

RUN echo "DOCKER_File: The active spring env is : $SPRING_PROFILES_ACTIVE"


RUN mkdir -p /root/.m2 \
    && mkdir /root/.m2/repository
#COPY settings.xml /root/.m2
COPY . /build/

WORKDIR /build/
RUN mvn clean install
RUN mvn generate-sources
RUN mvn package -Dmaven.test.skip


FROM maven:3.8.5-openjdk-18

WORKDIR /app
ENV JAVA_TOOL_OPTIONS -agentlib:jdwp=transport=dt_socket,address=5010,server=y,suspend=n
COPY --from=MAVEN_BUILD /build/core-service/target/centriqo_lms_core_service-0.0.1-SNAPSHOT.jar /app/
ENTRYPOINT ["java", "-jar", "authmarshal-proxy-service-0.0.1-SNAPSHOT.jar"]