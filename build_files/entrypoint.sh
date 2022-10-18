#!/bin/bash
# Based on MobileInsight Vagrant Installation Script by Yuanjie Li, Zengwen Yuan, Yunqi Guo (https://github.com/luckiday/wireshark-for-android)
alias python=python3
echo 'Building Wireshark for Android'

# Download and setup Android NDK r15c
cd ~
wget https://dl.google.com/android/repository/android-ndk-r15c-linux-x86_64.zip
unzip android-ndk-r15c-linux-x86_64.zip
echo 'export ANDROID_NDK_HOME=$HOME/android-ndk-r15c' >> ~/.bashrc
echo 'PATH=$PATH:$ANDROID_NDK_HOME' >> ~/.bashrc
source ~/.bashrc
rm android-ndk-r15c-linux-x86_64.zip

cd ~/android-ndk-r15c
python3 build/tools/make_standalone_toolchain.py \
    --arch arm \
    --api 26 \
    --stl gnustl \
    --unified-headers \
    --install-dir ~/android-ndk-toolchain

# Download tarballs
cd ~
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
tar xf libiconv-1.15.tar.gz
rm libiconv-1.15.tar.gz

wget http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.8.tar.gz
tar xf gettext-0.19.8.tar.gz
rm gettext-0.19.8.tar.gz

wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.37.tar.gz
tar xf libgpg-error-1.37.tar.gz
rm libgpg-error-1.37.tar.gz

wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.1.tar.bz2
tar xf libgcrypt-1.8.1.tar.bz2
rm libgcrypt-1.8.1.tar.bz2

wget http://ftp.gnome.org/pub/gnome/sources/glib/2.54/glib-2.54.3.tar.xz
tar xf glib-2.54.3.tar.xz
rm glib-2.54.3.tar.xz

wget https://github.com/c-ares/c-ares/releases/download/cares-1_15_0/c-ares-1.15.0.tar.gz
tar -xf c-ares-1.15.0.tar.gz
rm c-ares-1.15.0.tar.gz

wget https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz
tar -xf libffi-3.3.tar.gz
rm libffi-3.3.tar.gz

ws_ver=3.4.0
wget  http://www.mobileinsight.net/wireshark-3.4.0-rbc-dissector.tar.xz -O wireshark-3.4.0.tar.xz
tar -xf wireshark-3.4.0.tar.xz
rm wireshark-3.4.0.tar.xz


wget http://www.tcpdump.org/release/libpcap-1.9.1.tar.gz
tar -xf libpcap-1.9.1.tar.gz
rm libpcap-1.9.1.tar.gz

# Apply the patch to wireshark
cp /build_ws/ws_android.patch ./
cd wireshark-3.4.0
patch -p1 < ../ws_android.patch

# Compile wireshark first time
cd tools/lemon
cmake .
make
cp lemon ~/
echo "lemon is generated"

# Import the environment settings
cd ~
cp  /build_ws/envsetup.sh .
chmod +x envsetup.sh
source ~/envsetup.sh

# Compile libiconv
cd ~/libiconv-1.15
./configure --build=${BUILD_SYS} --host=arm-eabi --prefix=${PREFIX} --disable-rpath
make
make install

# Compile gettext
cd ~/gettext-0.19.8
./configure --build=${BUILD_SYS} --host=arm-eabi  --prefix=${PREFIX} --disable-rpath --disable-java --disable-native-java --disable-libasprintf --disable-openmp --disable-curses
make
make install

# Compile libgpgerror
cd ~/libgpg-error-1.37
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --enable-static --disable-shared
make
make install

# Compile libgcrypt
cd ~/libgcrypt-1.8.1
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --enable-static --disable-shared
make
make install

# Compile libpcap
cd ~/libpcap-1.9.1
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --enable-static --disable-shared
make
make install

# Compile glib
# Install libffi
cd ~/libffi-3.3
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --enable-static --disable-shared
make
make install

cd ~/c-ares-1.15.0/
unset CFLAGS
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --enable-static --disable-shared
make
make install

# Reset the CFLAGS
source ~/envsetup.sh
cd ~/glib-2.54.3
cp  /build_ws/android.cache .
./configure --build=${BUILD_SYS} --host=${TOOLCHAIN} --prefix=${PREFIX} --disable-dependency-tracking --cache-file=android.cache --enable-included-printf --enable-static --with-pcre=no --disable-libmount
make
make install

# Compile wireshark
cp /build_ws/build_ws.sh ./
chmod +x build_ws.sh
./build_ws.sh

# Copy libs
cd ~
mkdir ws_lib
cd ws_lib
cp ~/androidcc/lib/libgio-2.0.so .
cp ~/androidcc/lib/libglib-2.0.so .
cp ~/androidcc/lib/libgobject-2.0.so .
cp ~/androidcc/lib/libgmodule-2.0.so .
cp ~/androidcc/lib/libgthread-2.0.so .
cp /usr/local/lib/libwireshark.so .
cp /usr/local/lib/libwiretap.so .
cp /usr/local/lib/libwsutil.so .

cp -r ~/ws_lib  /build_ws/output

# Compile android_ws_dissector
cd ~/
git clone -b dev-6.0 https://github.com/mobile-insight/mobileinsight-core.git
cd mobileinsight-core/ws_dissector/
sed -i "s+/home/vagrant/+$HOME/+g" Makefile
make android
mkdir ws_bin
cp android_* ws_bin/
cp -r ws_bin /build_ws/output

echo 'Compilation completed'