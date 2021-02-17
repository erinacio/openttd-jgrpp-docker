#!/bin/sh
set -ex
jgrpp_version=0.40.2
opengfx_version=0.6.0
cd /build/
apt-get update
apt-get upgrade -y
apt-get install -y \
    cmake \
    wget \
    unzip \
    xz-utils \
    build-essential \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    liblzma5 \
    liblzma-dev \
    liblzo2-2 \
    liblzo2-dev \
    libpng16-16 \
    libpng-dev
wget https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$jgrpp_version.tar.gz
wget https://cdn.openttd.org/opengfx-releases/$opengfx_version/opengfx-$opengfx_version-all.zip
echo "9065cd9ba1714f95774e09a3ea19769bdc10cb5597e77cf2ba45123195fd92df *jgrpp-$jgrpp_version.tar.gz" | sha256sum -c
echo "d419c0f5f22131de15f66ebefde464df3b34eb10e0645fe218c59cbc26c20774 *opengfx-$opengfx_version-all.zip" | sha256sum -c
tar -xvf jgrpp-$jgrpp_version.tar.gz
cd OpenTTD-patches-jgrpp-$jgrpp_version/bin
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DDEFAULT_PERSONAL_DIR=. \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DOPTION_DEDICATED=ON \
    ..
make install
cd /build
unzip opengfx-$opengfx_version-all.zip
mv opengfx-$opengfx_version.tar /usr/share/games/openttd/baseset/opengfx-$opengfx_version.tar
useradd -ms /bin/sh -d /data openttd
apt-get remove -y \
    wget \
    unzip \
    xz-utils \
    build-essential \
    pkg-config \
    zlib1g-dev \
    liblzma-dev \
    liblzo2-dev \
    libpng-dev
apt-get autoremove -y
apt-get clean
rm -rvf /build /var/lib/apt/lists/*
