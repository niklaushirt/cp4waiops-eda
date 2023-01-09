FROM ubuntu:22.10

ARG DEBIAN_FRONTEND=noninteractive

ENV DockerHOME=/home/app

# set work directory
RUN mkdir -p $DockerHOME

# where your code lives
WORKDIR $DockerHOME

RUN apt-get update && apt-get install -y \
  openssh-server \
  ansible \
  kafkacat \
  python3-pip \
  npm \
  jq \
  curl \
  nano \
  unzip \
  && rm -rf /var/lib/apt/lists/*


# install dependencies
RUN pip install --upgrade pip

RUN pip install -Iv 'resolvelib<0.6.0'
RUN pip install aiohttp

RUN ansible-galaxy collection install ansible.eda
RUN ansible-playbook -i localhost, -c local ansible.eda.install_rulebook_cli --ask-become-pass

COPY * ./
COPY ./rulebooks ./rulebooks
COPY ./playbooks ./playbooks

RUN chmod +x startup.sh

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
ENV EDA_REPO=https://github.com/niklaushirt/cp4waiops-eda.git

ENTRYPOINT /home/app/startup.sh

