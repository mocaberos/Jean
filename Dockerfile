FROM oraclelinux:8-slim

ARG NAXSI_VER=1.3
ARG NGINX_VER=1.21.6
ARG NAXSI_CONFIG_VERSION="unknown"

ENV NAXSI_VER=${NAXSI_VER}
ENV NGINX_VER=${NGINX_VER}
ENV NAXSI_CONFIG_VERSION=${NAXSI_CONFIG_VERSION}

RUN microdnf update && microdnf upgrade -y
RUN microdnf install -y tar gzip gcc-c++ pcre-devel zlib-devel make unzip libuuid-devel gettext
RUN microdnf clean all

WORKDIR /tmp
RUN curl -L "https://github.com/nbs-system/naxsi/archive/${NAXSI_VER}.tar.gz" -o "naxsi_${NAXSI_VER}.tar.gz"
RUN curl -L "https://nginx.org/download/nginx-${NGINX_VER}.tar.gz" -o "nginx-${NGINX_VER}.tar.gz"
RUN tar vxf "naxsi_${NAXSI_VER}.tar.gz"; rm -rf "naxsi_${NAXSI_VER}.tar.gz"
RUN tar vxf "nginx-${NGINX_VER}.tar.gz"; rm -rf "nginx-${NGINX_VER}.tar.gz"

WORKDIR /tmp/nginx-${NGINX_VER}
RUN ./configure \
    --add-dynamic-module=../naxsi-${NAXSI_VER}/naxsi_src/ \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --user=nginx \
    --group=nginx \
    --with-http_auth_request_module \
    --with-http_v2_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-pcre \
    --with-pcre-jit


RUN mkdir /var/cache/nginx
RUN mkdir /var/log/nginx
RUN ln -s /dev/stdout /var/log/nginx/access.log
RUN ln -s /dev/stderr /var/log/nginx/error.log
RUN make modules
RUN make
RUN make install

RUN mkdir /app
RUN mkdir /etc/nginx/modules
RUN mkdir /etc/nginx/rules
COPY ./docker-entrypoint.sh /app/docker-entrypoint.sh
COPY ./config /app/config
COPY ./config/rules/*.rules /etc/nginx/rules
RUN cp "/tmp/nginx-${NGINX_VER}/objs/ngx_http_naxsi_module.so" /etc/nginx/modules
RUN cp "/tmp/naxsi-${NAXSI_VER}/naxsi_config/naxsi_core.rules" /etc/nginx/rules
RUN rm -rf /tmp/*

RUN microdnf remove tar gzip gcc-c++ pcre-devel zlib-devel make unzip libuuid-devel

RUN useradd --user-group --no-create-home nginx

EXPOSE 1191
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["nginx", "-c", "/etc/nginx/nginx.conf"]
