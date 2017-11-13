# s2i-java
FROM openshift/base-centos7
MAINTAINER Jorge Morales <jmorales@redhat.com>
# HOME in base image is /opt/app-root/src

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.6
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

RUN (update-ca-trust force-enable && \
    echo $'-----BEGIN CERTIFICATE-----\nMIIDUTCCAjmgAwIBAgIJAL6F6F9CU9nbMA0GCSqGSIb3DQEBBQUAMB4xHDAaBgNV\nBAMTE3N3Y2dpbnQxLmh2bG5ldC5uZXQwHhcNMTIwMzA3MTI0NDU4WhcNMzIwMzAy\nMTI0NDU4WjAeMRwwGgYDVQQDExNzd2NnaW50MS5odmxuZXQubmV0MIIBIjANBgkq\nhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3XwvO5w7CzSkaBwkdWnCGsVFl1JDps/w\nxkkBMHxdDhH7f6Xj/lPSECOE7LMycEcEirHvheFTV8tvR9/SNDwdRl1qiw+fYXGa\nJ+Gnw9pewkb9m99ULXwXuydWzazAITWPk2KO6q9YiwQ3qrykYYTXSnkCWcLNzTgl\nLFhGgPVWXMvwLJCHYVSO4e3me3bWDVCkKvSoV7GiYnp3ilJjXESU/H/K9RD36zQh\n7Vt0y82Mdd4nwix3c4rwl/6gnoaargL9nWrQWwCJikxN368SZVqLcNbWLd19Ys2K\nk6juKNmAIcdjlboWwTy5/77Xbe5GvaOLJBB88/q+LvAYPZB3ildvGQIDAQABo4GR\nMIGOMA8GCWCGSAGG+EIBDQQCFgAwHQYDVR0OBBYEFCbrpebORUqTbyK1dXbVOsVD\nTt8uME4GA1UdIwRHMEWAFCbrpebORUqTbyK1dXbVOsVDTt8uoSKkIDAeMRwwGgYD\nVQQDExNzd2NnaW50MS5odmxuZXQubmV0ggkAvoXoX0JT2dswDAYDVR0TBAUwAwEB\n/zANBgkqhkiG9w0BAQUFAAOCAQEAQyp4Ycv5rXjOB8Z0M88cSx3muU5PH6BSST3/\ntxkR5cStd1Y0Au1c2gQYvx6Yg4wAmiPHC8YZyOIqpUdrbNE+LFfrQif5lrzGdO+m\n6pkXHLmuChJSIS59mSyDV1ruFFg3xV3g0wUfoD0BflH3UlOMug7THKeLpyUnINGY\nZXLN2Hz/wFN2Tcdp1AJQ8qPGUM2HPp5gg4RE9GxC4oTre0PvBa1dUpxOzzvpiySs\ns3L3BBTncR0Qug4hx4HbK4MScPSmsiwhwaAV2S5jQZx6JOfERUMaJ36HDqJDF+d8\nu5s6DWbwcUo2kYpE++YEWfu+2u2HzF4h6LyQYlmfgsDyWjCBpg==\n-----END CERTIFICATE-----' >/etc/pki/ca-trust/source/anchors/PCAcert.crt && \
    update-ca-trust extract)

ENV MAVEN_VERSION 3.3.9
RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2
ENV PATH=/opt/maven/bin/:$PATH

#ENV GRADLE_VERSION 2.6
#RUN curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
#    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
#    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
#    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
#    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle
#ENV PATH=/opt/gradle/bin/:$PATH

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Java (fatjar) applications with maven or gradle" \
      io.k8s.display-name="Java S2I builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-2.6,java,microservices,fatjar"

# TODO (optional): Copy the builder files into /opt/openshift
# COPY ./<builder_folder>/ /opt/openshift/
# COPY Additional files,configurations that we want to ship by default, like a default setting.xml
COPY ./contrib/settings.xml $HOME/.m2/

LABEL io.openshift.s2i.scripts-url=image:///usr/local/sti
COPY ./sti/bin/ /usr/local/sti

RUN chown -R 1001:1001 /opt/openshift

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
