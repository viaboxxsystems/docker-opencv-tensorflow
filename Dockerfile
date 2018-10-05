FROM ubuntu:18.04

ENV TENSORFLOW_DIR /tensorflow
ENV DEBIAN_FRONTEND noninteractive

RUN echo "Europe/Berlin" > /etc/timezone
# Install Bazel 
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install  wget curl openjdk-8-jdk gnupg 
RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" |  tee /etc/apt/sources.list.d/bazel.list 
RUN curl https://bazel.build/bazel-release.pub.gpg |  apt-key add -

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install cmake python-pip libboost-all-dev qtdeclarative5-dev qt5-default libopencv-dev python-opencv  libcurl4-gnutls-dev openjdk-8-jdk  pkg-config zip g++ zlib1g-dev unzip python curl bazel && apt-get -y autoremove

WORKDIR /
RUN wget https://github.com/tensorflow/tensorflow/archive/v1.9.0.tar.gz && tar -xvzf v1.10.1.tar.gz  && mv tensorflow-1.10.1 tensorflow

WORKDIR /tensorflow
RUN ./configure (without CUDA and without all other stuff)
RUN bazel build --jobs=6 --verbose_failures -c opt --copt=-mavx --copt=-mfpmath=both --copt=-msse4.2 //tensorflow:libtensorflow_cc.so

#WORKDIR /
#RUN pip install kafka-python 
#RUN git clone https://github.com/edenhill/librdkafka.git
#RUN cd librdkafka && ./configure && make && make install

#WORKDIR /
#RUN git clone https://github.com/mfontanini/cppkafka.git
#RUN cd cppkafka &&  mkdir build && cd build && cmake ../ && make && make install

WORKDIR /
#opencv (world_module)
RUN git clone https://github.com/opencv/opencv.git
RUN wget https://github.com/opencv/opencv.git/archive/v3.4.3.tar.gz && tar -xvzf v3.4.3.tar.gz  && mv opencv-3.4.3 opencv
RUN cd opencv && mkdir build && cd build && -D BUILD_opencv_world=ON ../ && make && make install
