# PVCAM Python Wrapper ARTIQ Network Device Support Package

`PyVCAM` is an [ARTIQ network device support package](https://m-labs.hk/artiq/manual/developing_a_ndsp.html) providing an Python-based interface to [Teledyne](https://www.teledynevisionsolutions.com/en-CA) Photometrics and QImaging [PVCAM](https://www.photometrics.com/support/download/pvcam/request/3-3-1-3-64-bit)-based cameras.
It is a Python3.X wrapper for the `PVCAM` SDK. This project is a fork of the [PyVCAM Wrapper](https://github.com/Photometrics/PyVCAM) developed by [Teledyne Photometrics](https://github.com/Photometrics) and is dependent on `PyVCAM v2.1.5`.
This package was primarily tested with the [Teledyne Prime BSI sCMOS camera](https://www.teledynevisionsolutions.com/products/prime-bsi/?segment=tvs&vertical=tvs%20-%20photometrics).

## Quick Start

<!-- A [Docker container](https://www.docker.com/) tested on [Ubuntu 22.04 LTS Linux x86_64 architecture](https://www.releases.ubuntu.com/22.04/) can quickly start the controller application:
```sh
$ pip install git+https://github.com/quantumion/PyVCAM.git
$ cd lumibird falcon controller
$ docker compose build && docker compose up -d
```
-->

Install the package in a virtual environment.
Then, the controller server can be started from the command line:
```sh
$ python -m pyvcam -p <port=3249>
```

Send commands to the controller with [sipyco_rpctool](https://m-labs.hk/artiq/sipyco-manual/index.html#remote-procedure-call-tool) or an [ARTIQ script](https://m-labs.hk/artiq/manual/index.html).

## Acknowledgements
This package is developed and supported as part of the [QuantumIon project](https://tqt.uwaterloo.ca/project-details/quantumion-an-open-access-quantum-computing-platform/) at the [Institute for Quantum Computing](https://uwaterloo.ca/institute-for-quantum-computing/[) at the [University of Waterloo](https://uwaterloo.ca/).
This package was developed thanks in part to funding from the [Natural Sciences and Engineering Research Council (NSERC)](https://www.nserc-crsng.gc.ca/index_eng.asp) and the [Canada First Research Excellence Fund (CFREF)](https://www.cfref-apogee.gc.ca/home-accueil-eng.aspx).
