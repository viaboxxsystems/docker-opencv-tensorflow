FROM ubuntu:18.04

ENV TENSORFLOW_DIR /tensorflow
ENV DEBIAN_FRONTEND noninteractive
ENV OPENCV_VERSION 3.4.3
ENV TENSORFLOW 1.9.0
ENV LIB_DIR /src/source-libs
ENV LD_LIBRARY_PATH /lib:/usr/lib:/usr/local/lib

# Install Bazel
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install  wget curl openjdk-8-jdk gnupg
RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" |  tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg |  apt-key add -

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install  qtdeclarative5-dev qt5-default libopencv-dev librdkafka++1 libopencv-dev python-opencv libcurl4-gnutls-dev libeigen3-dev openjdk-8-jdk  pkg-config zip g++ zlib1g-dev unzip python curl bazel && apt-get -y autoremove

WORKDIR /
RUN wget https://github.com/tensorflow/tensorflow/archive/v${TENSORFLOW}.tar.gz && tar -xvzf v${TENSORFLOW}.tar.gz  && mv tensorflow-${TENSORFLOW} tensorflow

RUN cd tensorflow && ./configure
RUN cd tensorflow &&  bazel build --jobs=6 --verbose_failures -c opt --copt=-mavx --copt=-mfpmath=both --copt=-msse4.2 --incompatible_remove_native_http_archive=false //tensorflow:libtensorflow_cc.so
RUN cp /tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so /usr/local/lib

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install  qtdeclarative5-dev qt5-default libopencv-dev librdkafka-dev libopencv-dev python-opencv libcurl4-gnutls-dev libeigen3-dev openjdk-8-jdk  pkg-config zip g++ zlib1g-dev unzip python curl && \
    apt-get -y install build-essential cmake \
                       qt5-default libvtk6-dev \
                       zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libjasper-dev libopenexr-dev libgdal-dev \
                       libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev \
                       libtbb-dev libeigen3-dev && \
    apt-get -y autoremove


RUN apt-get -y install wget
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip  && mv opencv-${OPENCV_VERSION} OpenCV && cd OpenCV
RUN mkdir build && cd build

WORKDIR /OpenCV/build
RUN cd /OpenCV/build && cmake -D BUILD_opencv_world=ON ../
RUN cd /OpenCV/build && make -j2
RUN cd /OpenCV/build && make install && ldconfig
