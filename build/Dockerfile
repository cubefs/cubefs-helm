FROM centos:7.2.1511 AS base
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    yum install -y jq wget bind-utils snappy snappy-devel 
RUN mkdir -p /cfs/bin /cfs/conf /cfs/logs /cfs/data

FROM base AS server
COPY bin/cfs-server /cfs/bin/

FROM base AS client
RUN yum install -y fuse
COPY bin/cfs-client /cfs/bin/