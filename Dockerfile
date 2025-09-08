FROM ubuntu:22.04
LABEL maintainer="Andrew Geyko <ageyko@mpi-sws.org>"


ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies in one layer
RUN apt-get update && apt-get install -y \
    coreutils \
    wget \
    vim \
    git \
    gcc-11 \
    g++-11 \
    make \
    cmake \
    clang-format \
    libboost-dev \
    libboost-program-options-dev \
    python3 \
    python3-pip \
    python3-venv \
    libprotobuf-dev \
    protobuf-compiler \
    openmpi-bin \
    openmpi-doc \
    libopenmpi-dev 
 
## Create Python venv: Required for Python 3.11
RUN python3 -m venv /opt/venv/astra-sim
ENV PATH="/opt/venv/astra-sim/bin:$PATH"
RUN pip3 install --upgrade pip

## Add astra-sim to PYTHONPATH
ENV PYTHONPATH="/app/astra-sim"

# STG dependencies
RUN pip3 install numpy sympy graphviz pandas
### ======================================================

ARG ABSL_VER=20240722.0
# Download source
WORKDIR /opt
RUN wget https://github.com/abseil/abseil-cpp/releases/download/${ABSL_VER}/abseil-cpp-${ABSL_VER}.tar.gz
RUN tar -xf abseil-cpp-${ABSL_VER}.tar.gz
RUN rm abseil-cpp-${ABSL_VER}.tar.gz

## Compile Abseil
WORKDIR /opt/abseil-cpp-${ABSL_VER}/build
RUN cmake .. \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/opt/abseil-cpp-${ABSL_VER}/install"
RUN cmake --build . --target install --config Release --parallel $(nproc)
ENV absl_DIR="/opt/abseil-cpp-${ABSL_VER}/install"
### ======================================================

ARG PROTOBUF_VER=29.0
# Download source
WORKDIR /opt
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VER}/protobuf-${PROTOBUF_VER}.tar.gz
RUN tar -xf protobuf-${PROTOBUF_VER}.tar.gz
RUN rm protobuf-${PROTOBUF_VER}.tar.gz

## Compile Protobuf
WORKDIR /opt/protobuf-${PROTOBUF_VER}/build
RUN cmake .. \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_ABSL_PROVIDER=package \
    -DCMAKE_INSTALL_PREFIX="/opt/protobuf-${PROTOBUF_VER}/install"
RUN cmake --build . --target install --config Release --parallel $(nproc)
ENV PATH="/opt/protobuf-${PROTOBUF_VER}/install/bin:$PATH"
ENV protobuf_DIR="/opt/protobuf-${PROTOBUF_VER}/install"

# Also, install Python protobuf package
RUN pip3 install protobuf==5.${PROTOBUF_VER}

# Set the environment variable
ENV PROTOBUF_FROM_SOURCE=True
### ======================================================

### ==================== Clone Directory ===========================
WORKDIR /app/
