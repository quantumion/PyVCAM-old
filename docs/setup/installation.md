# Installation

## Prerequisites

PVCAM must be installed before PyVCAM can be installed.

* An understanding of PVCAM is very helpful for understanding PyVCAM.
* A C/C++ compiler is needed to build native source code. For Windows, MSVC 1928 was used for testing.
* The newest version of Python 3 which can be downloaded [here](https://www.python.org/downloads/).
* The latest PVCAM and PVCAM SDK which can be downloaded [here](https://www.photometrics.com/support/software/#software).
* PyVCAM was developed and tested using Microsoft Windows 10/64-bit. The build package also supports Linux, but testing has been minimal.

PVCAM and PyVCAM are supported on the following platforms:

* Linux - aarch64, x86_64, i686
* Windows - amd64, x86 32bit

## Clone the Repository
Clone the [repository](docs/setup/installation.md) to download the program, then navigate to the program directory:
```sh
$ git clone git@github.com:quantumion/PyVCAM.git
cd PyVCAM
```

<!-- ## Build and Run with Docker
Run the program in a [Docker container](https://www.docker.com/resources/what-container/) using [Docker Compose](https://docs.docker.com/compose/):
```sh
$ docker compose build && docker compose up -d
```

The container will build then run in the background.
The container has been tested on the [Ubuntu Linux x86_64](https://ubuntu.com/download/desktop) platform. -->

## Install with Pip
Install the program with [pip](https://pip.pypa.io/en/stable/index.html) in a virtual environment:
```sh
$ python -m virtualenv venv
$ source venv/bin/activate
$ pip install .
```

Alternatively, install directly from [GitHub](https://github.com/) with [pip](https://pip.pypa.io/en/stable/index.html) without cloning the [repository](https://github.com/quantumion/lumibird_falcon_controller):
```sh
$ pip install git+https://github.com/quantumion/PyVCAM.git
```

For development, install in [editable mode](https://setuptools.pypa.io/en/latest/userguide/development_mode.html) with [optional dependencies](https://setuptools.pypa.io/en/latest/userguide/dependency_management.html#optional-dependencies):
```sh
$ pip install -e .[dev]
```
