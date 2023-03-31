FROM ubuntu:22.04

MAINTAINER Huanhuan Ye "https://github.com/yedamao"

# install sshd
ENV SSH_PORT=2022
RUN apt update && apt install -y openssh-server sudo curl zsh tmux
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd && mkdir /root/.ssh
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# create user
ENV CREATE_USER_NAME=damao
RUN useradd $CREATE_USER_NAME -m -s /bin/zsh && adduser $CREATE_USER_NAME sudo

EXPOSE ${SSH_PORT}

CMD ["sh", "-c", "/usr/sbin/sshd -D -p $SSH_PORT"]
