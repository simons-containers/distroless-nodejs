FROM archlinux:base-devel-20260308.0.497099 AS builder

ARG GCC_VERSION
ARG NODEJS_VERSION

ARG GCC_SOURCE
ARG NODEJS_RELEASE

RUN pacman -Syu --noconfirm wget >/dev/null

WORKDIR /build/gcc
RUN curl --silent --show-error --location --output gcc.tar.gz \
    "${GCC_SOURCE}" \
    && tar xf gcc.tar.gz --strip-components=1 \
    && ./contrib/download_prerequisites \
    && mkdir build && cd build \
    && ../configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --libexecdir=/usr/lib \
        --disable-multilib \
        --disable-bootstrap \
        --enable-languages=c,c++ \
        --enable-libatomic \
    && make -j$(nproc) all-target-libgcc all-target-libstdc++-v3 all-target-libatomic \
    && mkdir -p /base/usr/lib && ln -s lib /base/usr/lib64 \
    && make install-target-libgcc DESTDIR=/base \
    && make install-target-libstdc++-v3 DESTDIR=/base \
    && make install-target-libatomic DESTDIR=/base

WORKDIR /extract/nodejs
RUN curl --silent --show-error --location --output nodejs.tar.xz \
    "${NODEJS_RELEASE}" \
    && tar xf nodejs.tar.xz --strip-components=1 \
    && mv bin /base/usr/ \
    && mv lib/node_modules /base/usr/lib/

RUN find /base/usr/lib -type f \( -name '*.so' -o -name '*.so.*' \) \
        -exec sh -c 'strip --strip-unneeded "$1" || :' _ {} \; \
    && find /base/usr -type f \
        \( -name '*.h' -o -name '*.a' -o -name '*.o' -o -name '*.la' \) -delete \
    && rm -rf \
        /base/usr/include \
        /base/usr/lib/{cmake,pkgconfig,gconv} \
        /base/usr/lib/gcc /base/usr/share/gcc-${GCC_VERSION} \
        /base/usr/sbin \
        /base/usr/share/man \
        /base/usr/bin/openssl
       
FROM ghcr.io/simons-containers/distroless-glibc:2.43

ARG GCC_VERSION
ARG NODEJS_VERSION

COPY --from=builder /base/usr/ /usr/

WORKDIR /usr/bin
ENTRYPOINT ["/usr/bin/node"]

LABEL org.opencontainers.image.title="distroless nodejs"
LABEL org.opencontainers.image.description="distroless nodejs"
LABEL org.opencontainers.image.version="${NODEJS_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-nodejs"
LABEL org.opencontainers.image.base.libs="gcc@${GCC_VERSION}"
