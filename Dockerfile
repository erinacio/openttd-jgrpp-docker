FROM debian:buster as builder
ENV jgrpp_version=0.40.4
ENV opengfx_version=0.6.0
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
RUN curl -fLo jgrpp-$jgrpp_version.tar.gz https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$jgrpp_version.tar.gz
RUN curl -fLo opengfx-$opengfx_version-all.zip https://cdn.openttd.org/opengfx-releases/$opengfx_version/opengfx-$opengfx_version-all.zip
RUN echo "c468d15d93a90f4148ca261610e7d7ee7a74142a888eccaebde0676c4db46bb8 *jgrpp-$jgrpp_version.tar.gz" | sha256sum -c
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
