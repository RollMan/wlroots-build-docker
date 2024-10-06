ARG DEST=/wlroots-0.17.4-drm-prebuilt-amd64-linux

FROM debian:bookworm AS build
ARG DEST
ENV PKG_CONFIG_PATH ${DEST}/share/pkgconfig:${DEST}/lib/x86_64-linux-gnu/pkgconfig
ENV LD_LIBRARY_PATH ${DEST}/lib:${DEST}/lib/x86_64-linux-gnu
ENV CPATH ${DEST}/include
ENV C_INCLUDE_PATH ${DEST}/include
ENV CPLUS_INCLUDE_PATH ${DEST}/include
RUN apt update && apt install -y \
    libxcb-xinput-dev \
    glslang-tools \
    libxcb-present-dev \
    glslang-dev \
    libxcb-dri3-dev \
    build-essential \
    cmake \
    curl \
    doxygen \
    gdb \
    git \
    graphviz \
    hwdata \
    lcov \
    libbz2-dev \
    libdrm-dev \
    libegl-dev \
    libffi-dev \
    libffi-dev \
    libgbm-dev \
    libgdbm-compat-dev \
    libgdbm-dev \
    libinput-dev \
    libinput-pad-dev \
    libliftoff-dev \
    liblzma-dev \
    libncurses5-dev \
    libpixman-1-dev \
    libreadline6-dev \
    libseat-dev \
    libsqlite3-dev \
    libssl-dev \
    libudev-dev \
    libvulkan-dev \
    libxcb-composite0-dev \
    libxcb-ewmh-dev \
    libxcb-icccm4-dev \
    libxcb-render-util0-dev \
    libxcb-res0-dev \
    libxcb1-dev \
    libxkbcommon-dev \
    libxml2-dev \
    lzma \
    lzma-dev \
    meson \
    pkg-config \
    tk-dev \
    uuid-dev \
    vim-tiny \
    wayland-protocols \
    xmlto \
    xsltproc \
    xwayland \
    zlib1g-dev \
;
WORKDIR /wlroots

# TODO: use ARG for version digits.

RUN curl -O https://gitlab.freedesktop.org/wayland/wayland/uploads/6dacf0ae5fc5dbd2fa6510d317853259/wayland-1.22.93.tar.xz && \
    tar xf wayland-1.22.93.tar.xz && \
    cd wayland-1.22.93 && \
    meson setup build/ --prefix=${DEST} && \
    ninja -C build/ install
RUN curl -O https://gitlab.freedesktop.org/wayland/wayland-protocols/uploads/8e42ac41cda1522d5a39ca79f3b3899d/wayland-protocols-1.32.tar.xz && \
    tar xf wayland-protocols-1.32.tar.xz && \
    cd wayland-protocols-1.32 && \
    meson setup build/ --prefix=${DEST} && \
    ninja -C build/ install

# Build libdisplay-info
RUN curl -O https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/0.2.0/libdisplay-info-0.2.0.tar.bz2 && \
    tar xf libdisplay-info-0.2.0.tar.bz2 && \
    cd libdisplay-info-0.2.0 && \
    meson setup build/ --prefix=${DEST} && \
    ninja -C build/ install

# Build libliftoff
RUN curl -O https://gitlab.freedesktop.org/emersion/libliftoff/-/archive/v0.5.0/libliftoff-v0.5.0.tar.bz2 && \
    tar xf libliftoff-v0.5.0.tar.bz2 && \
    cd libliftoff-v0.5.0 && \
    meson setup build/ --prefix=${DEST} && \
    ninja -C build/ install

RUN cd / && \
    tar Jcf ${DEST}.tar.xz ${DEST}


RUN curl -O https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/0.17.4/wlroots-0.17.4.tar.gz && \
    tar xf wlroots-0.17.4.tar.gz && \
    cd wlroots-0.17.4 && \
    PKG_CONFIG_PATH=${DEST}/share/pkgconfig:${DEST}/lib/x86_64-linux-gnu/pkgconfig meson setup build/ --prefix=${DEST} && \
    ninja -C build/ install

RUN cd / && tar Jcf ${DEST}.tar.xz ${DEST}

FROM scratch AS final
ARG DEST
COPY --from=build ${DEST}.tar.xz /
