FROM openjdk:11-jre-slim



WORKDIR /home/app



RUN apt update \
&& apt install maven -y



COPY mvnw .
COPY mvnw.cmd .
COPY pom.xml .
COPY src src



# RUN mvn -f ./pom.xml clean package install



# COPY --from=build /home/app/target/*.jar /usr/local/lib/app.jar
EXPOSE 8080
ENTRYPOINT mvn -f ./pom.xml clean package install \
&& cp -rd ./target/*.jar /usr/local/lib/app.jar \
&& java -jar /usr/local/lib/app.jar