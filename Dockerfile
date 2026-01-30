FROM docker.io/library/debian:trixie as builder
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
ENV jgrpp_version=0.69.2
ENV opengfx_version=8.0
RUN curl -fLo jgrpp-$jgrpp_version.tar.gz https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$jgrpp_version.tar.gz
RUN curl -fLo opengfx-$opengfx_version-all.zip https://cdn.openttd.org/opengfx-releases/$opengfx_version/opengfx-$opengfx_version-all.zip
RUN echo "438e5effb2b3c2f9f6accdaeec4d71f6036352b6f9aa177c5b9b23ef25d28a54 *jgrpp-$jgrpp_version.tar.gz" | sha256sum -c
RUN echo "43a0c1dabf39cb865394f3a6cc36d4da5c10ecfaaf55652043104806810903be *opengfx-$opengfx_version-all.zip" | sha256sum -c
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

FROM docker.io/library/debian:trixie
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
ENV XDG_CONFIG_HOME=/data
VOLUME ["/data"]
ENTRYPOINT ["/usr/bin/openttd"]
