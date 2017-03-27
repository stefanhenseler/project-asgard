FROM        debian
MAINTAINER  Stefan Henseler <stefan.henseler@synax.ch>

USER root

RUN apt-get update -y && \
    apt-get install jq wget git vim python unzip -y && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.5.3/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.5.3/bin/linux/amd64/kubefed && \
    chmod +x kubefed && \
    mv kubefed /usr/local/bin/kubefed && \
    wget https://github.com/kubernetes/kops/releases/download/1.5.3/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops

RUN git clone https://github.com/synax/project-asgard.git