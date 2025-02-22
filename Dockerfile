# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OPENSSL_PREFIX=/usr/local
ENV OPENSSL_CONF=${OPENSSL_PREFIX}/ssl/openssl.cnf

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    perl \
    python3 \
    g++ \
    libtool \
    automake \
    autoconf \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    zlib1g-dev \
    && apt clean

RUN apt update && apt install -y ca-certificates

# Set working directory
WORKDIR /opt

# Clone and build OpenSSL 3.2 from source
RUN git clone --depth 1 --branch openssl-3.2.0 https://github.com/openssl/openssl.git && \
    cd openssl && \
    ./config --prefix=${OPENSSL_PREFIX} --openssldir=${OPENSSL_PREFIX}/ssl shared zlib && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Update system path to use the new OpenSSL
ENV PATH="${OPENSSL_PREFIX}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${OPENSSL_PREFIX}/lib"

# Verify OpenSSL version
RUN openssl version -a

# Clone and build liboqs
RUN git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git && \
    cd liboqs && \
    mkdir build && cd build && \
    cmake -GNinja -DCMAKE_INSTALL_PREFIX=${OPENSSL_PREFIX} .. && \
    ninja && \
    ninja install && \
    ldconfig

# Clone and build the OQS-Provider with hybrid KEM support
RUN git clone --depth 1 https://github.com/open-quantum-safe/oqs-provider.git && \
    cd oqs-provider && \
    mkdir build && cd build && \
    cmake -GNinja -DCMAKE_PREFIX_PATH=${OPENSSL_PREFIX} \
          -DOQS_ENABLE_KEM_HYBRID=ON \
          -DOQS_KEM_DEFAULT=kyber768 \
          -DOQS_ENABLE_KEM_KYBER=ON \
          -DOQS_ENABLE_SIG=ON .. && \
    ninja && \
    ninja install && \
    ldconfig

# Verify that OQS-Provider is installed
RUN ls ${OPENSSL_PREFIX}/lib/ossl-modules/ | grep oqsprovider.so

# Ensure OpenSSL loads OQS provider
COPY openssl.conf ${OPENSSL_CONF}

# Set OpenSSL configuration globally
ENV OPENSSL_CONF=${OPENSSL_CONF}

# Set the container's entrypoint to OpenSSL
ENTRYPOINT ["openssl"]
