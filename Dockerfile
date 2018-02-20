FROM openjdk:8-jdk

#######################################################################
# Installing additional packages
#######################################################################

RUN apt-get update && \
    apt-get install -y jq iptables apt-transport-https ca-certificates curl software-properties-common

#######################################################################
# Configuring package repositories
#######################################################################

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

#######################################################################
# Installing docker
#######################################################################

RUN apt-get update && \
    apt-get install -y docker-ce && \
    rm -rf /var/lib/apt/lists/*

#######################################################################
# Installing kubectl
#######################################################################

ARG KUBECTL_VERSION=1.8.5
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA256=2663511441d44b844a25925b7d74d9326d86b8347408d21ed6efbd27a7f7109a

RUN curl -fsSL ${KUBECTL_URL} -o /usr/local/bin/kubectl && \
    echo "${KUBECTL_SHA256}  /usr/local/bin/kubectl" | sha256sum -c - && \
    chmod +x /usr/local/bin/kubectl

#######################################################################
# Installing helm
#######################################################################

ARG HELM_VERSION=2.7.1
ARG HELM_URL=https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz
ARG HELM_SHA256_URL=${HELM_URL}.sha256

WORKDIR /tmp

RUN curl -fsSL ${HELM_URL} -o helm-linux-amd64.tar.gz && \
    echo "$(curl -fsSL ${HELM_SHA256_URL})  helm-linux-amd64.tar.gz" | sha256sum -c - && \
    tar -xvzf helm-linux-amd64.tar.gz linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin/

WORKDIR /

#######################################################################
# Configure jenkins directory
#######################################################################

ENV JENKINS_HOME=/var/jenkins

RUN mkdir -p ${JENKINS_HOME}/.jenkins

#######################################################################
# Copying and laying down the files
#######################################################################

COPY mappedFiles /tmp/mappedFiles
COPY fileMappings.json /tmp/

RUN mv /tmp/mappedFiles/bin/fileMapper.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/fileMapper.sh && \
    fileMapper.sh /tmp/fileMappings.json && \
    chmod -R +x /usr/local/bin/ && \
    rm -rf /tmp/mappedFiles

#######################################################################
# Miscellaneous configuration
#######################################################################

ENTRYPOINT ["entrypoint.sh"]
