FROM debian:buster as builder
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
        libpng16-16 \
        libpng-dev
ENV jgrpp_version=0.41.0
ENV opengfx_version=0.6.0
RUN curl -fLo jgrpp-$jgrpp_version.tar.gz https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$jgrpp_version.tar.gz
RUN curl -fLo opengfx-$opengfx_version-all.zip https://cdn.openttd.org/opengfx-releases/$opengfx_version/opengfx-$opengfx_version-all.zip
RUN echo "3ffd42b99c21f80f5fc1732e06b3d49a31ea5ce0cc73c6d43fea1b4b1ff8c94c *jgrpp-$jgrpp_version.tar.gz" | sha256sum -c
RUN echo "d419c0f5f22131de15f66ebefde464df3b34eb10e0645fe218c59cbc26c20774 *opengfx-$opengfx_version-all.zip" | sha256sum -c
RUN tar -xvf jgrpp-$jgrpp_version.tar.gz
RUN mkdir /tmp/build

WORKDIR /tmp/build
RUN cmake \
        -G Ninja \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DDEFAULT_PERSONAL_DIR=. \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
        -DOPTION_DEDICATED=ON \
        /tmp/OpenTTD-patches-jgrpp-$jgrpp_version
RUN ninja
RUN ninja install

WORKDIR /tmp
RUN unzip opengfx-$opengfx_version-all.zip
RUN mv opengfx-$opengfx_version.tar /usr/share/games/openttd/baseset/opengfx-$opengfx_version.tar

FROM debian:buster
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
           zlib1g \
           liblzma5 \
           liblzo2-2 \
           libpng16-16 \
    && rm -rvf /var/lib/apt/lists/*
RUN useradd -ms /bin/sh -d /data openttd
COPY --from=builder /usr/games/openttd /usr/games/openttd
COPY --from=builder /usr/share/games/openttd/ /usr/share/games/openttd/
COPY --from=builder /usr/share/doc/openttd/ /usr/share/doc/openttd/
COPY --from=builder /usr/share/man/man6/openttd.6.gz /usr/share/man/man6/openttd.6.gz
USER openttd:openttd
WORKDIR /data
EXPOSE 3979
EXPOSE 3979/udp
ENTRYPOINT ["/usr/games/openttd"]
