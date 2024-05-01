FROM python:3.12-rc-slim-bookworm as system
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \ 
    && apt-get clean

# set up non-root user
RUN adduser --disabled-password --uid 1001 --ingroup sudo app && \
    usermod -aG users app && \
    echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER app
ENV PATH="/home/app/.local/bin:$PATH"

RUN python -m pip install --user --upgrade pip

# install pvcam and sdk
FROM system as build
WORKDIR /app
COPY ./pvcam ./pvcam

WORKDIR /app/pvcam/app
RUN yes Y | ./pvcam__install_helper-Ubuntu.sh

WORKDIR /app/pvcam/sdk
RUN yes Y | ./pvcam-sdk__install_helper-Ubuntu.sh
ENV PVCAM_SDK_PATH=/opt/pvcam/sdk

# build python application
FROM build
WORKDIR /app
COPY . .
RUN python -m pip install --user .

ENTRYPOINT ["aqctl_pyvcam"]
CMD ["-p", "3249", "--bind", "*"]
