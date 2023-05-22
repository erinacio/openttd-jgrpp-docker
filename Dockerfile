FROM debian:bullseye as builder
WORKDIR /tmp
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
    cmake \
    curl \
    unzip \
    xz-utils \
    build-essential \
    ninja-build \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    liblzma5 \
    liblzma-dev \
    liblzo2-2 \
    liblzo2-dev \
    libzstd-dev \
    libpng16-16 \
    libpng-dev
ENV jgrpp_version=0.53.3
ENV opengfx_version=7.1
RUN curl -fLo jgrpp-$jgrpp_version.tar.gz https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$jgrpp_version.tar.gz
RUN curl -fLo opengfx-$opengfx_version-all.zip https://cdn.openttd.org/opengfx-releases/$opengfx_version/opengfx-$opengfx_version-all.zip
RUN echo "e8a14df24df074c315e7a309cdb8d151c9eea9ef79723c0e2e662095d3108a4e *jgrpp-$jgrpp_version.tar.gz" | sha256sum -c
RUN echo "928fcf34efd0719a3560cbab6821d71ce686b6315e8825360fba87a7a94d7846 *opengfx-$opengfx_version-all.zip" | sha256sum -c
RUN tar -xvzf jgrpp-$jgrpp_version.tar.gz
RUN mkdir /tmp/build

WORKDIR /tmp/build
RUN cmake \
    -B build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_INSTALL_BINDIR=bin \
    -D CMAKE_INSTALL_DATADIR=/usr/share \
    -D OPTION_DEDICATED=ON \
    -D DEFAULT_PERSONAL_DIR=/data \
    -G Ninja \
    -S /tmp/OpenTTD-patches-jgrpp-$jgrpp_version
RUN ninja -C build
RUN ninja -C build install

WORKDIR /tmp
RUN unzip opengfx-$opengfx_version-all.zip
RUN mv opengfx-$opengfx_version.tar /usr/share/openttd/baseset/opengfx-$opengfx_version.tar

FROM debian:bullseye
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
           zlib1g \
           liblzma5 \
           liblzo2-2 \
           libzstd1 \
           libpng16-16 \
    && apt-get clean \
    && rm -rvf /var/lib/apt/lists/* /var/log/apt /var/log/dpkg.log
COPY --from=builder /usr/bin/openttd /usr/bin/openttd
COPY --from=builder /usr/share/openttd/ /usr/share/openttd/
COPY --from=builder /usr/share/doc/openttd/ /usr/share/doc/openttd/
COPY --from=builder /usr/share/man/man6/openttd.6.gz /usr/share/man/man6/openttd.6.gz
RUN useradd -ms /bin/sh -d /data openttd
USER openttd:openttd
EXPOSE 3979
EXPOSE 3979/udp
WORKDIR /data
ENV XDG_DATA_HOME=/data
VOLUME ["/data"]
ENTRYPOINT ["/usr/bin/openttd"]
