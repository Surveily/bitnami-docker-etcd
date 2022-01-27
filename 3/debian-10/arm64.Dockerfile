FROM docker.io/bitnami/minideb:buster
LABEL maintainer "Bitnami <containers@bitnami.com>"

ENV HOME="/" \
    OS_ARCH="arm64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gzip procps tar
RUN mkdir -p /opt/bitnami/common/bin /opt/bitnami/etcd/bin
RUN curl -SL https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_arm64 -o /opt/bitnami/common/bin/yq &&  chmod a+x /opt/bitnami/common/bin/yq
RUN curl -SL https://github.com/tianon/gosu/releases/download/1.14/gosu-arm64 -o /opt/bitnami/common/bin/gosu && chmod a+x /opt/bitnami/common/bin/gosu
RUN curl -SL https://github.com/etcd-io/etcd/releases/download/v3.5.1/etcd-v3.5.1-linux-arm64.tar.gz | tar --strip-components=1 -xzC /opt/bitnami/etcd/bin
RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami

COPY rootfs /
RUN /opt/bitnami/scripts/etcd/postunpack.sh
ENV BITNAMI_APP_NAME="etcd" \
    BITNAMI_IMAGE_VERSION="3.5.1-debian-10-r96" \
    ETCDCTL_API="3" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/etcd/bin:$PATH"

EXPOSE 2379 2380

WORKDIR /opt/bitnami/etcd
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/etcd/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/etcd/run.sh" ]
