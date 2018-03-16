FROM centos:7

ENV RESTIC_VERSION=0.8.3 \
    OC_VERSION=3.7.1 \
    OC_SHA=ab0f056

# Install Restic
WORKDIR /tmp
RUN yum -y -q -e 0 install bzip2 && \
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

COPY bin/* /usr/local/bin/
