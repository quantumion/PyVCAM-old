FROM ubuntu:22.04 as system
SHELL ["/bin/sh", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo=1.9.9-1ubuntu2.4 \
    git=1:2.34.1-1ubuntu1.11 \
    python3-pip=22.0.2+dfsg-1ubuntu0.4 \
    python3-dev=3.10.6-1~22.04 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# set up non-root user
RUN adduser --disabled-password --uid 1001 --ingroup sudo app && \
    usermod -aG users app && \
    echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER app
ENV PATH="/home/app/.local/bin:$PATH"

RUN python3 -m pip install --no-cache-dir --user --upgrade pip==24.0

# install pvcam and sdk
FROM system as build
WORKDIR /app
COPY ./pvcam ./pvcam

WORKDIR /app/pvcam/app
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN yes Y | ./pvcam__install_helper-Ubuntu.sh

WORKDIR /app/pvcam/sdk
RUN yes Y | ./pvcam-sdk__install_helper-Ubuntu.sh
ENV PVCAM_SDK_PATH=/opt/pvcam/sdk

# build python application
FROM build
WORKDIR /app
COPY . .
RUN python3 -m pip install --user --no-cache-dir .

ENTRYPOINT ["aqctl_pyvcam"]
CMD ["-p", "3249", "--bind", "*"]
