# Using the Controller
Once the server program is running, use a separate program to send commands for the controller to the server program.

## Simple Python Communications Remote Procedure Call Tool
Use [`sipyco_rpctool`](https://m-labs.hk/artiq/sipyco-manual/#remote-procedure-call-tool) to send commands to the controller over the network.
[`SiPyCo`](https://m-labs.hk/artiq/sipyco-manual/#remote-procedure-call-tool) comes as part of the [standard ARTIQ installation](https://m-labs.hk/artiq/manual/installing.html).
It can also be installed separately using [pip](https://python.land/virtual-environments/installing-packages-with-pip):
```sh
$ python -m pip install git+https://sipyco@git+https://github.com/m-labs/sipyco.git
```

Use the command line interface of the tool to list the targets and methods available on the controller server program and send commands:
```sh
$ sipyco_rpctool <hostname=::1> <port=3249> list-targets
$ sipyco_rpctool <hostname=::1> <port=3249> list-methods
$ sipyco_rpctool <hostname=::1> <port=3249> call <method> <args>
```

The controller server program can be terminated with `sipyco`:
```sh
$ sipyco_rpctool <hostname=::1> <port=3249> call terminate
```

## ARTIQ Script
The laser controller may be controlled like any other [ARTIQ](https://m-labs.hk/artiq/manual/index.html) device in a script:
```python
from artiq.experiment import *

class PyVCAMDemo(EnvExperiment):
    def build(self):
        self.setattr_device("core")
        self.setattr_device("pyvcam")

    @kernel
    def run(self):
        self.core.reset()
        print(self.lumibird_falcon.name())
```
