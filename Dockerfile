FROM centos:7

ENV RESTIC_VERSION=0.8.3

# Install Restic
WORKDIR /tmp
RUN yum -y -q -e 0 install bzip2 && \
    curl -O -s -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 >/dev/null && \
    curl -O -s -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/SHA256SUMS >/dev/null && \
    fgrep restic_${RESTIC_VERSION}_linux_amd64.bz2 SHA256SUMS | sha256sum -c - && \
    bzip2 -d restic_${RESTIC_VERSION}_linux_amd64.bz2 && \
    mv /tmp/restic_${RESTIC_VERSION}_linux_amd64 /usr/local/bin/restic && \
    chmod +x /usr/local/bin/restic

COPY bin/* /usr/local/bin/