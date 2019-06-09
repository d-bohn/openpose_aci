# inspired by https://gist.github.com/sberryman/6770363f02336af82cb175a83b79de33
# https://gist.github.com/moiseevigor/11c02c694fc0c22fccd59521793aeaa6
# https://github.com/esemeniuc/openpose-docker/blob/master/Dockerfile

#base image: nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
#FROM blvc/caffe:gpu
FROM nvidia/cuda:10.0-cudnn7-devel

ENV DEBIAN_FRONTEND=noninteractive

#get deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-dev python3-pip \
    git g++ wget make cmake \
    libprotobuf-dev protobuf-compiler \
    libopencv-dev libgoogle-glog-dev \
    libboost-all-dev \
    libhdf5-dev libatlas-base-dev \
    software-properties-common unzip

# RUN cp -ruax /opt/caffe/build/include/caffe/proto/ /opt/caffe/include/caffe
RUN pip3 install numpy opencv-python

RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz && \
    tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt && \
    rm cmake-3.14.2-Linux-x86_64.tar.gz

ENV PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"

#install nvidia drivers for the aci gpus
RUN add-apt-repository -y ppa:graphics-drivers/ppa
RUN apt-get install -y nvidia-390-dev

# download openpose
#RUN cd /opt && \
#    wget -O openpose.zip https://github.com/CMU-Perceptual-Computing-Lab/openpose/archive/v1.5.0.zip && \
#    unzip openpose.zip && \
#    rm -f openpose.zip && \
#    mv openpose-1.5.0 openpose

RUN cd /opt && \
    git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose

# compile openpose
ENV OPENPOSE_ROOT=/opt/openpose/
RUN cd /opt/openpose && \
    git submodule init && \
    git submodule update --remote

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
      -DBUILD_PYTHON=ON .. / && \
    make all -j"$(nproc)"
