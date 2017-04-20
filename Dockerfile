# spring-boot-centos7
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Mario Enrique Ramirez Mirola <dextor_men415@hotmail.com>

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 3.4.1
ENV GRADLE_VERSION 3.4.1
ENV MAVEN_VERSION 3.3.3
ENV JAVA_VERSION 1.8.0

# TODO: Set labels used in OpenShift to describe the builder image
ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Spring Boot applications with maven or gradle" \
      io.k8s.display-name="Spring Boot builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-3.4.1,springboot"

RUN yum update -y && \
  yum install -y curl && \
  yum install -y java-$JAVA_VERSION-openjdk java-$JAVA_VERSION-openjdk-devel && \
  yum clean all

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME /usr/lib/jvm/java 
ENV MAVEN_HOME /usr/share/maven

RUN curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

# TODO (optional): Copy the builder files into /opt/openshift
# COPY ./<builder_folder>/ /opt/openshift/
# COPY Additional files,configurations that we want to ship by default, like a default setting.xml

LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
COPY ./.s2i/bin/ /usr/local/s2i

ENV PATH=/opt/maven/bin/:/opt/gradle/bin/:$PATH

RUN chown -R 1001:1001 /opt/openshift

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
	# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
