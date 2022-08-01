# syntax = docker/dockerfile:1.4.0

ARG S6_ARCH="amd64"

ARG TARGETPLATFORM="linux/amd64"
ARG BUILDPLATFORM="linux/amd64"

ARG CROSS_ARCH="x86_64"
ARG CROSS_ABI="musl"
ARG CROSS_TRIPLET="${CROSS_ARCH}-linux-${CROSS_ABI}"

ARG BEARSSL_VERSION="0.6"
ARG BEARSSL_REPO="bearssl.org/git/BearSSL"
ARG EXECLINE_VERSION="v2.9.0.1"
ARG EXECLINE_REPO="skarnet/execline"
ARG S6_VERSION="v2.11.1.2"
ARG S6_REPO="skarnet/s6"
ARG S6_DNS_VERSION="v2.3.5.4"
ARG S6_DNS_REPO="skarnet/s6-dns"
ARG S6_LINUX_INIT_VERSION="v1.0.8.0"
ARG S6_LINUX_INIT_REPO="skarnet/s6-linux-init"
ARG S6_LINUX_UTILS_VERSION="v2.6.0.0"
ARG S6_LINUX_UTILS_REPO="skarnet/s6-linux-utils"
ARG S6_NETWORKING_VERSION="v2.5.1.1"
ARG S6_NETWORKING_REPO="skarnet/s6-networking"
ARG S6_OVERLAY_VERSION="v3.1.1.2"
ARG S6_OVERLAY_MAJOR="3.1.1.2"
ARG S6_OVERLAY_REPO="just-containers/s6-overlay"
ARG S6_OVERLAY_HELPERS_VERSION="v0.1.0.0"
ARG S6_OVERLAY_HELPERS_REPO="just-containers/s6-overlay-helpers"
ARG S6_PORTABLE_UTILS_VERSION="v2.2.5.0"
ARG S6_PORTABLE_UTILS_REPO="skarnet/s6-portable-utils"
ARG S6_RC_VERSION="v0.5.3.2"
ARG S6_RC_REPO="skarnet/s6-rc"
ARG SKALIBS_VERSION="v2.12.0.1"
ARG SKALIBS_REPO="skarnet/skalibs"


## get add-contenv
#
FROM --platform="${BUILDPLATFORM}" "moonbuggy2000/s6-add-contenv:s6-overlay-v${S6_OVERLAY_MAJOR}" AS add-contenv

## get source
#
FROM --platform="${BUILDPLATFORM}" moonbuggy2000/fetcher:latest AS fetcher

FROM fetcher AS src_bearssl
ARG BEARSSL_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://bearssl.org/bearssl-${BEARSSL_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_execline
ARG EXECLINE_REPO
ARG EXECLINE_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${EXECLINE_REPO}/archive/refs/tags/${EXECLINE_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6
ARG S6_REPO
ARG S6_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_REPO}/archive/refs/tags/${S6_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_dns
ARG S6_DNS_REPO
ARG S6_DNS_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_DNS_REPO}/archive/refs/tags/${S6_DNS_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_linux_init
ARG S6_LINUX_INIT_REPO
ARG S6_LINUX_INIT_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_LINUX_INIT_REPO}/archive/refs/tags/${S6_LINUX_INIT_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_linux_utils
ARG S6_LINUX_UTILS_REPO
ARG S6_LINUX_UTILS_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_LINUX_UTILS_REPO}/archive/refs/tags/${S6_LINUX_UTILS_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_networking
ARG S6_NETWORKING_REPO
ARG S6_NETWORKING_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_NETWORKING_REPO}/archive/refs/tags/${S6_NETWORKING_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_overlay
ARG S6_OVERLAY_REPO
ARG S6_OVERLAY_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_OVERLAY_REPO}/archive/refs/tags/${S6_OVERLAY_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_overlay_helpers
ARG S6_OVERLAY_HELPERS_REPO
ARG S6_OVERLAY_HELPERS_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_OVERLAY_HELPERS_REPO}/archive/refs/tags/${S6_OVERLAY_HELPERS_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_portable_utils
ARG S6_PORTABLE_UTILS_REPO
ARG S6_PORTABLE_UTILS_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_PORTABLE_UTILS_REPO}/archive/refs/tags/${S6_PORTABLE_UTILS_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_s6_rc
ARG S6_RC_REPO
ARG S6_RC_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${S6_RC_REPO}/archive/refs/tags/${S6_RC_VERSION}.tar.gz" | tar xzf - --strip 1

FROM fetcher AS src_skalibs
ARG SKALIBS_REPO
ARG SKALIBS_VERSION
WORKDIR /src
RUN wget --no-check-certificate -qO- "https://github.com/${SKALIBS_REPO}/archive/refs/tags/${SKALIBS_VERSION}.tar.gz" | tar xzf - --strip 1


## build the source
#
FROM --platform="${BUILDPLATFORM}" "muslcc/x86_64:${CROSS_TRIPLET}" AS builder
RUN apk -U add --no-cache bash llvm make git tar xz

ARG CROSS_ARCH
ARG CROSS_ABI
ARG CROSS_TRIPLET

# buildx builds fail for some/many non-amd64 platforms because it can't find binaries
RUN for binary in gcc ar ranlib strip; do \
    ln -s "/${CROSS_ARCH}-linux-${CROSS_ABI}/bin/${binary}" "/bin/${CROSS_ARCH}-linux-${CROSS_ABI}-${binary}"; \
    ln -s "/${CROSS_ARCH}-linux-${CROSS_ABI}/bin/${binary}" "/${CROSS_ARCH}-linux-${CROSS_ABI}/bin/${CROSS_ARCH}-linux-${CROSS_ABI}-${binary}"; \
  done

RUN mkdir -p /buildroot/out/staging

ENV PATH="/${CROSS_ARCH}-linux-${CROSS_ABI}/bin:${PATH}" \
    CC="gcc" \
    CXX="gcc"

WORKDIR /buildroot/src/skalibs
COPY --from=src_skalibs /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared --with-default-path=/command:/buildroot/sbin:/buildroot/bin:/usr/sbin:/usr/bin:/sbin:/bin --with-sysdep-devurandom=yes --with-sysdep-grndinsecure=no \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/execline
COPY --from=src_execline /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared --disable-pedantic-posix \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6
COPY --from=src_s6 /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-rc
COPY --from=src_s6_rc /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-linux-init
COPY --from=src_s6_linux_init /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-portable-utils
COPY --from=src_s6_portable_utils /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-linux-utils
COPY --from=src_s6_linux_utils /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-dns
COPY --from=src_s6_dns /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/bearssl
COPY --from=src_bearssl /src .
RUN mkdir -p /buildroot/out/staging/include \
  && cp -a ./inc/*.h /buildroot/out/staging/include/ \
  && make lib -j$(nproc) \
  && mkdir -p /buildroot/out/staging/lib \
  && cp -f build/libbearssl.a /buildroot/out/staging/lib/

WORKDIR /buildroot/src/s6-networking
COPY --from=src_s6_networking /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared --enable-ssl=bearssl --with-ssl-path=/buildroot/out/staging \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-overlay-helpers
COPY --from=src_s6_overlay_helpers /src .
RUN DESTDIR=/buildroot/out/staging ./configure --host="${CROSS_TRIPLET}" --enable-slashpackage --enable-static-libc --disable-shared \
  && make -j$(nproc) \
  && make strip \
  && make DESTDIR=/buildroot/out/staging -L install update global-links

WORKDIR /buildroot/src/s6-overlay
COPY --from=src_s6_overlay /src .

ARG S6_ARCH

# rootfs-overlay-arch
WORKDIR /out/rootfs-overlay-arch
RUN cp -a /buildroot/out/staging/package /buildroot/out/staging/command ./ \
  && rm -rf ./package/*/*/include ./package/*/*/library \
  && tar -Jcf "/out/s6-overlay-${S6_ARCH}.tar.xz" --owner=0 --group=0 --numeric-owner .

# symlinks-overlay-arch
WORKDIR /out/symlinks-overlay-arch
RUN mkdir -p ./usr/bin \
  && for i in $(ls -1 /out/rootfs-overlay-arch/command); do \
    ln -s "../../command/$i" ./usr/bin/; \
  done \
  && tar -Jcf "/out/s6-overlay-symlinks-${S6_ARCH}.tar.xz" --owner=0 --group=0 --numeric-owner .

ARG S6_OVERLAY_VERSION

# rootfs-overlay-noarch
WORKDIR /out/rootfs-overlay-noarch
ARG S6_OVERLAY_VERSION
RUN cp -ar /buildroot/src/s6-overlay/layout/rootfs-overlay/* ./ \
  && find ./ -type f -name .empty -print | xargs rm -f -- \
  && find ./ -name '*@VERSION@*' -print | while read name; do \
    mv -f "$name" $(echo "$name" | sed -e "s/@VERSION@/${S6_OVERLAY_VERSION##*v}/"); \
  done \
  && find ./ -type f -size +0c -print | xargs sed -i -e "s|@SHEBANGDIR@|/command|g; s/@VERSION@/${S6_OVERLAY_VERSION##*v}/g;" -- \
  && ln -s s6-overlay-${S6_OVERLAY_VERSION##*v} ./package/admin/s6-overlay \
  && tar -Jcf /out/s6-overlay-noarch.tar.xz --owner=0 --group=0 --numeric-owner .

# symlinks-overlay-noarch
WORKDIR /out/symlinks-overlay-noarch
RUN mkdir -p ./usr/bin \
  && for i in $(ls -1 /out/rootfs-overlay-noarch/command); do \
    ln -s "../../command/$i" ./usr/bin/; \
  done \
  && tar -Jcf /out/s6-overlay-symlinks-noarch.tar.xz --owner=0 --group=0 --numeric-owner .

# syslogd-overlay-noarch
WORKDIR /out/syslogd-overlay-noarch
RUN cp -ar /buildroot/src/s6-overlay/layout/syslogd-overlay/* ./ \
  && find ./ -type f -name .empty -print | xargs rm -f -- \
  && find ./ -name '*@VERSION@*' -print | while read name; do \
    mv -f "$name" $(echo "$name" | sed -e "s/@VERSION@/${S6_OVERLAY_VERSION##v*}/"); \
  done \
  && find ./ -type f -size +0c -print | xargs sed -i -e 's|@SHEBANGDIR@|/command|g; s/@VERSION@/${S6_OVERLAY_VERSION##v*}/g;' -- \
  && tar -Jcf /out/syslogd-overlay-noarch.tar.xz --owner=0 --group=0 --numeric-owner .


## an image with nothing but tarballs
#
FROM --platform="${BUILDPLATFORM}" scratch AS out-tarballs
COPY --from=builder /out/*.tar.* /

## an image with nothing but overlay files
#
FROM --platform="${BUILDPLATFORM}" scratch AS out-overlay
COPY --from=builder /out/rootfs-overlay-arch/ /out/rootfs-overlay-noarch/ /out/symlinks-overlay-arch/ /out/symlinks-overlay-noarch/ /
COPY --from=add-contenv / /
