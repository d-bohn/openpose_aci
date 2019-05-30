# inspired by https://gist.github.com/sberryman/6770363f02336af82cb175a83b79de33
# https://gist.github.com/moiseevigor/11c02c694fc0c22fccd59521793aeaa6

FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

LABEL maintainer="Daniel Albohn <d.albohn@gmail.com>"

RUN apt-get update -y && apt-get --assume-yes install \
    build-essential unzip cmake git \
    # General dependencies
    libatlas-base-dev libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler \
    # Remaining dependencies
    libgflags-dev libgoogle-glog-dev liblmdb-dev \
    # Python libs
    libopencv-dev \
    libeigen3-dev libviennacl-dev \
    doxygen wget libboost-all-dev

# RUN add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get -y update && \
#     apt-get --assume-yes install \
#     python3.6 \
#     libopencv-dev \
#     python-opencv
#
# RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
#     python3.6 get-pip.py
#
# RUN pip3 install --upgrade numpy scipy protobuf pandas
# RUN pip3 install opencv-python

RUN cp /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthreads.so

# download openpose
RUN cd /opt && \
    # wget -O openpose.zip https://github.com/CMU-Perceptual-Computing-Lab/openpose/archive/master.zip && \
    # unzip openpose.zip && \
    # rm -f openpose.zip
    git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose

# compile openpose

ENV OPENPOSE_ROOT /opt/openpose
RUN cd /opt/openpose && \
    git submodule init && \
    git submodule update --remote

# First two flags added for ACI without GPU support
RUN cd /opt/openpose && \
    mkdir -p build && cd build && \
    cmake \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_CAFFE=ON \
      -DBUILD_EXAMPLES=ON \
      -DDOWNLOAD_BODY_25_MODEL=ON \
      -DDOWNLOAD_BODY_COCO_MODEL=ON \
      -DDOWNLOAD_BODY_MPI_MODEL=ON \
      -DDOWNLOAD_HAND_MODEL=ON \
      -DBUILD_PYTHON=ON ../ && \
    make all -j"$(nproc)"
