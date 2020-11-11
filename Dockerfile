#FROM java
#ADD ./target/myproject-0.0.1-SNAPSHOT.jar /myproject-0.0.1-SNAPSHOT.jar
#ADD ./run.sh /run.sh
#RUN chmod a+x /run.sh
#EXPOSE 8080:8080
#CMD /run.sh

FROM openjdk:8-jdk-alpine
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

