FROM python:3.12-rc-slim-bookworm as build

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# install base tools, pre-install dependencies to take advantage of caching
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    sudo \
    git \
    build-essential \
    gcc-multilib \
    g++-multilib \
    pkg-config \
    libtiff5-dev \
    libusb-1.0-0
# for some reason, pre-installing dkms breaks automated installation pipeline
# installation of dkms delegated to the pvcam installation scripts

# install pvcam and sdk
WORKDIR /app
COPY ./pvcam .

WORKDIR /app/app
RUN yes Y | ./pvcam__install_helper-Ubuntu.sh

WORKDIR /app/sdk
RUN yes Y | ./pvcam-sdk__install_helper-Ubuntu.sh
ENV PVCAM_SDK_PATH=/opt/pvcam/sdk

# upgrade pip
WORKDIR /app
RUN python -m pip install --upgrade pip

# build python application
FROM build
WORKDIR /app
COPY . .
RUN python -m pip install .

ENTRYPOINT aqctl_pyvcam -p 3249 --bind *
