FROM openjdk:11-jdk

MAINTAINER Huanhuan Ye "https://github.com/yedamao"

# install sshd
ENV SSH_PORT=2022

RUN apt update && apt install -y openssh-server
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd && mkdir /root/.ssh
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

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

## env to .bashrc
RUN cd ${USER_HOME_DIR} && echo "export LANG=C.UTF-8" >> .bashrc \
  && echo "export MAVEN_HOME=/usr/share/maven" >> .bashrc \
  && echo "export JAVA_HOME=/usr/local/openjdk-11" >> .bashrc \
  && echo "export JAVA_VERSION=11.0.14.1" >> .bashrc \
  && echo "export PATH=/usr/local/openjdk-11/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> .bashrc

EXPOSE ${SSH_PORT}

CMD    ["sh", "-c", "/usr/sbin/sshd -D -p $SSH_PORT"]
