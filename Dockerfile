# FROM alpine:3.4
# FROM alpine:3.6
FROM alpine:3.7

# ENV VERSION=v4.9.1 NPM_VERSION=2
# ENV VERSION=v6.14.3 NPM_VERSION=3
# ENV VERSION=v8.11.3 NPM_VERSION=5 YARN_VERSION=latest
# ENV VERSION=v10.7.0 NPM_VERSION=6 YARN_VERSION=latest
ENV VERSION=v0.10.48 NPM_VERSION=2 CFLAGS="-D__USE_MISC"

# For base builds
ENV CONFIG_FLAGS="--without-npm" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  for server in ipv4.pool.sks-keyservers.net keyserver.pgp.com ha.pool.sks-keyservers.net; do \
    gpg --keyserver $server --recv-keys \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      77984A986EBC2AA786BC0F66B01FBB92821C587A \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D && break; \
  done && \
  curl -sfSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sfSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep ': OK$' && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -z "$CONFIG_FLAGS" ]; then \
    if [ -n "$NPM_VERSION" ]; then \
      npm install -g npm@${NPM_VERSION}; \
    fi; \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts
