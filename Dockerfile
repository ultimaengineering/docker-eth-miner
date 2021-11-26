FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu14.04

WORKDIR /
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt-get update && apt-get -y install software-properties-common && add-apt-repository -y ppa:ethereum/ethereum -y && apt-get update
RUN apt-get install -y git \
     cmake \
     build-essential \
     libssl-dev \
     perl \
     gcc-7 \
     g++-7 \
     libdbus-1-dev

RUN git config --global user.email "evaderxander@gmail.com"
RUN git config --global user.name "A man"

# Git repo set up
RUN git clone https://github.com/ethereum-mining/ethminer.git; \
    cd ethminer; \
    git checkout tags/v0.19.0; \
    git submodule update --init --recursive; \
    git fetch origin 47348022be371df97ed1d8535bcb3969a085f60a; \
    git cherry-pick 47348022be371df97ed1d8535bcb3969a085f60a

ENV DEBIAN_FRONTEND=noninteractive
# Build
RUN cd ethminer; \
    mkdir build; \
    cd build; \
    cmake .. -DETHASHCUDA=ON -DETHASHCL=OFF -DETHSTRATUM=ON; \
    cmake --build .; \
    make install;

# Env setup
ENV GPU_FORCE_64BIT_PTR=0
ENV GPU_MAX_HEAP_SIZE=100
ENV GPU_USE_SYNC_OBJECTS=1
ENV GPU_MAX_ALLOC_PERCENT=100
ENV GPU_SINGLE_ALLOC_PERCENT=100

ENTRYPOINT ["/usr/local/bin/ethminer", "-U"]
