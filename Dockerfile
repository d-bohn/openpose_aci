# inspired by https://gist.github.com/sberryman/6770363f02336af82cb175a83b79de33
# https://gist.github.com/moiseevigor/11c02c694fc0c22fccd59521793aeaa6

FROM ubuntu:16.04

LABEL maintainer="Daniel Albohn <d.albohn@gmail.com>"

RUN apt-get update -y && apt-get --assume-yes install \
    build-essential unzip cmake git \
    # General dependencies
    libatlas-base-dev libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler \
    # Remaining dependencies, 14.04
    libgflags-dev libgoogle-glog-dev liblmdb-dev \
    # Python libs
    libopencv-dev python-opencv python-pip python-dev python-numpy \
    libeigen3-dev libviennacl-dev \
    doxygen wget libboost-all-dev \
    # FFMPEG dependencies
    checkinstall pkg-config yasm \
    libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev\
    libdc1394-22-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
    libv4l-dev libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev \
    libxvidcore-dev x264 v4l-utils

RUN pip install --upgrade numpy scipy protobuf pandas
RUN pip install opencv-python

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
      -DGPU_MODE="CPU_ONLY" \
      -DUSE_CUDNN=OFF \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_CAFFE=ON \
      -DBUILD_EXAMPLES=ON \
      -DDOWNLOAD_BODY_25_MODEL=ON \
      -DDOWNLOAD_BODY_COCO_MODEL=ON \
      -DDOWNLOAD_BODY_MPI_MODEL=ON \
      -DDOWNLOAD_HAND_MODEL=ON \
      -DBUILD_PYTHON=ON ../ && \
    make all -j"$(nproc)"
