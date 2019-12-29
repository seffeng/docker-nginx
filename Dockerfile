FROM    seffeng/alpine

MAINTAINER  seffeng "seffeng@sina.cn"

ARG BASE_DIR="/opt/websrv"

ENV VERSION=1.16.1\
 PCRE_VERSION="pcre-8.43"\
 ZLIB_VERSION="zlib-1.2.11"\
 CONFIG_DIR="${BASE_DIR}/config"\
 INSTALL_DIR=${BASE_DIR}/program/nginx\
 EXTEND="gcc g++ make bzip2 perl openssl-dev file"\
 WWWROOT_DIR="${BASE_DIR}/data/wwwroot"
 
ARG CONFIGURE="./configure\
 --conf-path=${CONFIG_DIR}/nginx/nginx.conf\
 --error-log-path=${CONFIG_DIR}/nginx/logs/error.log\
 --group=wwww\
 --http-log-path=${CONFIG_DIR}/nginx/logs/access.log\
 --lock-path=${CONFIG_DIR}/nginx/logs/lock.txt\
 --pid-path=${CONFIG_DIR}/nginx/logs/pid.txt\
 --prefix=${INSTALL_DIR}\
 --sbin-path=${INSTALL_DIR}/sbin/nginx\
 --user=www\
 --with-http_addition_module\
 --with-http_dav_module\
 --with-http_degradation_module\
 --with-http_flv_module\
 --with-http_gzip_static_module\
 --with-http_mp4_module\
 --with-http_random_index_module\
 --with-http_realip_module\
 --with-http_secure_link_module\
 --with-http_ssl_module\
 --with-http_stub_status_module\
 --with-http_sub_module\
 --with-mail\
 --with-mail_ssl_module\
 --with-pcre=/tmp/${PCRE_VERSION}\
 --with-stream_realip_module\
 --with-stream_ssl_module\
 --with-zlib=/tmp/${ZLIB_VERSION}"

WORKDIR /tmp
ADD nginx-${VERSION}.tar.gz ./
ADD ${PCRE_VERSION}.tar.gz ./
ADD ${ZLIB_VERSION}.tar.gz ./
COPY    conf ./conf

RUN apk update && apk add ${EXTEND} &&\
 mkdir -p ${WWWROOT_DIR} ${BASE_DIR}/logs ${BASE_DIR}/tmp ${CONFIG_DIR}/nginx/certs.d &&\
 addgroup wwww && adduser -H -D -G wwww www &&\
 cd nginx-${VERSION} &&\
 ${CONFIGURE} &&\
 make && make install &&\
 ln -s ${INSTALL_DIR}/sbin/nginx /usr/bin/nginx &&\
 cp -Rf /tmp/conf/* ${CONFIG_DIR}/nginx &&\
 apk del ${EXTEND} &&\
 rm -rf /var/cache/apk/* &&\
 rm -rf /tmp/*

VOLUME ["${CONFIG_DIR}/nginx/conf.d", "${CONFIG_DIR}/nginx/certs.d", "${BASE_DIR}/logs", "${WWWROOT_DIR}", "${BASE_DIR}/tmp"]

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]