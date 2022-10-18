FROM ubuntu:focal
COPY build_files /build_ws
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    sudo bash ca-certificates git build-essential pkg-config \
    autoconf automake zlib1g-dev libtool bison byacc flex ccache \
    unzip python3.8 libncurses5 cmake pkg-config wget libglib2.0-dev \
    bison flex libpcap-dev libgcrypt-dev qt5-default qttools5-dev \
    qtmultimedia5-dev libqt5svg5-dev libc-ares-dev libsdl2-mixer-2.0-0 \
    libsdl2-image-2.0-0 libsdl2-2.0-0
#WORKDIR /build_ws
RUN chmod +x /build_ws/entrypoint.sh && mkdir -p /build_ws/output 
ENTRYPOINT [ "/build_ws/entrypoint.sh" ]
VOLUME [ "/build_ws/output" ]