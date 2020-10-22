FROM centos:7.2.1511 AS base

ENV TZ Asia/Shanghai 
COPY start.sh /cfs/bin/
RUN curl -s -o /bin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 && \
    curl -s -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo && \
    yum install -y epel-release && \
    yum install -y jq wget bind-utils snappy snappy-devel fuse && \
    chmod +x /bin/tini && chmod +x /cfs/bin/start.sh && \
    mkdir -p /cfs/bin /cfs/conf /cfs/logs /cfs/data

ENTRYPOINT ["/bin/tini", "--"]
CMD [""]

FROM base AS server
COPY bin/cfs-server /cfs/bin/

FROM base AS client
COPY bin/cfs-client /cfs/bin/
COPY bin/cfs-cli /cfs/bin/
