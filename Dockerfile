FROM centos:7

ENV RESTIC_VERSION=0.8.3 \
    OC_VERSION=3.7.1 \
    OC_SHA=ab0f056 \
    GO_VERSION=1.10 \
    GO_SHA=b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33 \
    PATH=$PATH:/usr/local/go/bin \
    GOPATH=/go

# Install Restic
WORKDIR /tmp
RUN yum -y -q -e 0 install bzip2 && yum clean all && \
    curl -O -s -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 >/dev/null && \
    curl -O -s -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/SHA256SUMS >/dev/null && \
    fgrep restic_${RESTIC_VERSION}_linux_amd64.bz2 SHA256SUMS | sha256sum -c - && \
    bzip2 -d restic_${RESTIC_VERSION}_linux_amd64.bz2 && \
    mv /tmp/restic_${RESTIC_VERSION}_linux_amd64 /usr/local/bin/restic && \
    chmod +x /usr/local/bin/restic

# Install oc client
RUN curl -O -s -L https://github.com/openshift/origin/releases/download/v${OC_VERSION}/openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit.tar.gz >/dev/null && \
    curl -O -s -L https://github.com/openshift/origin/releases/download/v${OC_VERSION}/CHECKSUM >/dev/null && \
    fgrep openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit.tar.gz CHECKSUM | sha256sum -c - && \
    tar xzf openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit.tar.gz && \
    mv openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit/oc /usr/local/bin/oc && \
    rm -rf openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit openshift-origin-client-tools-v${OC_VERSION}-${OC_SHA}-linux-64bit.tar.gz && \
    chmod +x /usr/local/bin/oc

# Install Go
# TODO: Make image smaller by using multistage builds
RUN yum -y -q -e 0 install git && yum clean all && \
    curl -O -s -L https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz >/dev/null && \
    echo "${GO_SHA} go${GO_VERSION}.linux-amd64.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    go get -u github.com/golang/dep/cmd/dep

COPY ./ /go

# Build and install baas
RUN dep ensure && go build -o baas main.go