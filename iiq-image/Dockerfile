#!/usr/bin/env
ARG TOMCAT_VERSION=9.0.70
# Using tomcat as the base image
FROM tomcat:$TOMCAT_VERSION

LABEL Description="Dockerfile identityiq container"\
      Version="8.3"\
      Patch="p1"
LABEL Maintainer="Vikas Gupta"
# Set IIQ version
ENV IIQ_VERSION 8.3
# Tomcat directory
ENV CATALINA_HOME /usr/local/tomcat
# IIQ Install directory
ENV IIQ_INSTALL_DIR $CATALINA_HOME/webapps/identityiq
ENV PATH $CATALINA_HOME/bin:$PATH
# Update and Install required package
RUN apt-get update -y; \
    apt-get install iputils-ping default-mysql-client -y;
# Copy IIQ artifact after build
COPY build/deploy/identityiq.war $CATALINA_HOME/webapps/
# Copy tomcat config files
COPY config/tomcat.service /usr/lib/systemd/system/
COPY config/tomcat-users.xml $CATALINA_HOME/conf/
COPY config/tomcat-server.xml $CATALINA_HOME/conf/server.xml
COPY config/.keystore $CATALINA_HOME/conf/
# Copy DB config script
COPY script/install_iiq.sh /tmp
RUN mkdir $IIQ_INSTALL_DIR; \
    cd $IIQ_INSTALL_DIR && jar -xvf $CATALINA_HOME/webapps/identityiq.war; \
    rm -rf $CATALINA_HOME/webapps/identityiq.war; \
    chmod +x /tmp/install_iiq.sh $IIQ_INSTALL_DIR/WEB-INF/bin/iiq;
WORKDIR $CATALINA_HOME/
# open tomcat port
EXPOSE 8443/tcp
# Execute the iiq install script
ENTRYPOINT ["/tmp/install_iiq.sh"]
CMD ["MYSQL_ROOT_PASSWORD", "MYSQL_USER", "MYSQL_PASSWORD", "MYSQL_DATABASE", "MYSQL_HOST"]