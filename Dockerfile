ARG DEST=/wlroots-0.17.4-drm-prebuilt-amd64-linux

FROM debian:bookworm AS build
ARG DEST
ENV PKG_CONFIG_PATH=${DEST}/share/pkgconfig:${DEST}/lib/x86_64-linux-gnu/pkgconfig
ENV LD_LIBRARY_PATH=${DEST}/lib:${DEST}/lib/x86_64-linux-gnu
ENV CPATH=${DEST}/include
ENV C_INCLUDE_PATH=${DEST}/include
ENV CPLUS_INCLUDE_PATH=${DEST}/include
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

# Build wayland-server
RUN --mount=type=bind,source=wayland/,target=. meson setup /build/wayland/ --prefix=${DEST} && \
    ninja -C /build/wayland/ install

# Build wayland-protocols
RUN --mount=type=bind,source=wayland-protocols/,target=. meson setup /build/wayland-protocols/ --prefix=${DEST} && \
    ninja -C /build/wayland-protocols/ install

# Build libdisplay-info
RUN --mount=type=bind,source=libdisplay-info/,target=. meson setup /build/libdisplay-info/ --prefix=${DEST} && \
    ninja -C /build/libdisplay-info/ install

# Build libliftoff
RUN --mount=type=bind,source=libliftoff/,target=. meson setup /build/libliftoff/ --prefix=${DEST} && \
    ninja -C /build/libliftoff/ install

# Build wlroots
RUN --mount=type=bind,source=wlroots,target=. PKG_CONFIG_PATH=${DEST}/share/pkgconfig:${DEST}/lib/x86_64-linux-gnu/pkgconfig meson setup /build/wlroots/ --prefix=${DEST} && \
    ninja -C /build/wlroots/ install

RUN cd / && tar Jcf ${DEST}.tar.xz ${DEST}

FROM scratch AS final
ARG DEST
COPY --from=build ${DEST}.tar.xz /
