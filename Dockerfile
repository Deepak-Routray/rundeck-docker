FROM openjdk:8

ENV DB_URL=localhost
ENV DB_SCHEMA=rundeck
ENV DB_USER=rundeck
ENV DB_PASS=rundeck
ENV SHARED_STORAGE=/rundeck

ENV RD_USER=rundeck
ENV RD_PASSWORD=rundeck
ENV RUNDECK_INSTALL_DIR=/opt/rundeck
ENV RSA_KEY_DIR=/var/lib/rundeck/.ssh
ENV JAVA_OPTIONS="-Xmx256m -Xms128m -XX:MaxMetaspaceSize=256m -XX:+PrintFlagsFinal"

EXPOSE 4440 4443 25

WORKDIR $RUNDECK_INSTALL_DIR

RUN apt-get update && apt-get install -y \
    uuid-runtime \
    vim

RUN mkdir -p $RSA_KEY_DIR

RUN wget http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-2.11.4.jar \
	&& wget http://central.maven.org/maven2/org/postgresql/postgresql/9.4-1206-jdbc42/postgresql-9.4-1206-jdbc42.jar -P /var/lib/rundeck/bootstrap/ 
 
# copy data directory
COPY ./data/bootstrap.sh /data/
COPY ./data/entrypoint.sh /data/
RUN chmod 777 /data/bootstrap.sh
RUN chmod 777 /data/entrypoint.sh

RUN sed -i -e 's/\r$//' /data/bootstrap.sh
RUN sed -i -e 's/\r$//' /data/entrypoint.sh
ENTRYPOINT ["/bin/bash","-c","/data/entrypoint.sh"]
