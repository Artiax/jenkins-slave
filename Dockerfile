FROM openjdk:8-jdk-alpine

#######################################################################
# Installing additional packages
#######################################################################

RUN apk add --no-cache \
    git curl jq bash docker \
    btrfs-progs e2fsprogs e2fsprogs-extra iptables xfsprogs xz pigz zfs

#######################################################################
# Configure jenkins directory
#######################################################################

ENV JENKINS_HOME=/var/jenkins

RUN mkdir -p ${JENKINS_HOME}/.jenkins

#######################################################################
# Installing docker-in-docker
#######################################################################

RUN addgroup -S dockremap && \
    adduser -S -G dockremap dockremap && \
    echo "dockremap:165536:65536" >> /etc/subuid && \
    echo "dockremap:165536:65536" >> /etc/subgid

ARG DIND_COMMIT=37498f009d8bf25fbb6199e8ccd34bed84f2874b
ARG DIND_URL=https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind

RUN curl -fsSL ${DIND_URL} -o /usr/local/bin/dind && \
    chmod +x /usr/local/bin/dind

#######################################################################
# Installing kubectl
#######################################################################

ARG KUBECTL_VERSION=1.9.8
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA256=dd7cdde8b7bc4ae74a44bf90f3f0f6e27206787b27a84df62d8421db24f36acd

WORKDIR /tmp

RUN curl -fsSL ${KUBECTL_URL} -o /usr/local/bin/kubectl && \
    echo "${KUBECTL_SHA256}  /usr/local/bin/kubectl" | sha256sum -c - && \
    chmod +x /usr/local/bin/kubectl

WORKDIR /

#######################################################################
# Installing helm
#######################################################################

ARG HELM_VERSION=2.13.1
ARG HELM_ARCHITECTURE=linux-amd64
ARG HELM_URL=https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-${HELM_ARCHITECTURE}.tar.gz
ARG HELM_SHA256_URL=https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-${HELM_ARCHITECTURE}.tar.gz.sha256

WORKDIR /tmp

RUN curl -fsSL ${HELM_URL} -o helm-${HELM_ARCHITECTURE}.tar.gz && \
    echo "$(curl -fsSL ${HELM_SHA256_URL})  helm-${HELM_ARCHITECTURE}.tar.gz" | sha256sum -c - && \
    tar -xvzf helm-${HELM_ARCHITECTURE}.tar.gz -C /usr/local/bin/ ${HELM_ARCHITECTURE}/helm && \
    rm -f helm-${HELM_ARCHITECTURE}.tar.gz

WORKDIR /

#######################################################################
# Copying and laying down the files
#######################################################################

COPY mappedFiles /tmp/mappedFiles
COPY fileMappings.json /tmp/

RUN mv /tmp/mappedFiles/bin/fileMapper.sh /usr/local/bin/ && \
    fileMapper.sh /tmp/fileMappings.json && \
    rm -rf /tmp/mappedFiles

#######################################################################
# Miscellaneous configuration
#######################################################################

ENTRYPOINT ["entrypoint.sh"]
