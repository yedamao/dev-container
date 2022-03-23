FROM openjdk:11-jdk

MAINTAINER Huanhuan Ye "https://github.com/yedamao"

# install sshd
ARG USER="root"
ARG PASSWORD="root"
ARG SSH_PORT=2022

Run apt update && apt install -y openssh-server
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo ${USER}:${PASSWORD} | chpasswd
RUN mkdir /var/run/sshd && mkdir /root/.ssh
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

# install maven
ARG MAVEN_VERSION=3.8.4
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG HTTP_PROXY=""

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && export http_proxy=${HTTP_PROXY} \
  && export https_proxy=${HTTP_PROXY} \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"


EXPOSE ${SSH_PORT}

CMD    ["/usr/sbin/sshd", "-D"]
