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

## Differences from PyVCAM Wrapper

* Camera functions run like a normal function with `self.pyvcam.<function>()`.
* Functions with argument parameters may be input into parenthesis.
* **The `Camera` class in PyVCAM makes significant use of the [`@property` decorator](https://docs.python.org/3/library/functions.html#property), which is [incompatible with `SiPyCo`](https://github.com/m-labs/sipyco/issues/40). As a result, several functions implemented in the NDSP driver class are modified from their default style. Follow the style in the "Driver Wrapper" columns as shown below.**
* Example usage given that a camera object cam/self.pyvcam has already been created:

| Bare PyVCAM Class | Driver Wrapper                  | Result                           |
|-------------------|---------------------------------|----------------------------------|
| `print(cam.gain)` | `print(self.pyvcam.get_gain())` | Prints current gain value as int |
| `cam.gain = 1`    | `self.pyvcam.set_gain(1)`       | Sets gain value to 1             |


### How to use the wrapper

#### Single Image Example

This captures a single image with a 20 millisecond exposure time and prints the values of the first 5 pixels.
* Given that a camera object cam/self.pyvcam has already been created:

| Bare PyVCAM Class                    | Driver Wrapper                               |
|--------------------------------------|----------------------------------------------|
| `frame = cam.get_frame(exp_time=20)` | `frame = self.pyvcam.get_frame(exp_time=20)` |

`print("First five pixels of frame: {}, {}, {}, {}, {}".format(*frame[:5]))`

#### Reading Settings

This prints the current settings of the camera.
* Given that a camera object cam/self.pyvcam has already been created:

| Bare PyVCAM Class              | Driver Wrapper                               |
|--------------------------------|----------------------------------------------|
| `print(cam.exp_mode)`          | `print(self.pyvcam.get_exp_mode())`          |
| `print(cam.readout_port)`      | `print(self.pyvcam.get_readout_port())`      |
| `print(cam.speed_table_index)` | `print(self.pyvcam.get_speed_table_index())` |
| `print(cam.gain)`              | `print(self.pyvcam.get_gain())`              |


#### Changing Settings Example

This is an example of how to change some of the settings on the cameras.
* Given that a camera object cam/self.pyvcam has already been created:

| Bare PyVCAM Class                   | Driver Wrapper                                 |
|-------------------------------------|------------------------------------------------|
| `cam.exp_mode = "Internal Trigger"` | `self.pyvcam.set_exp_mode("Internal Trigger")` |
| `cam.readout_port = 0`              | `self.pyvcam.set_readout_port(0)`              |
| `cam.speed_table_index = 0`         | `self.pyvcam.set_speed_table_index(0)`         |
| `cam.gain = 1`                      | `self.pyvcam.set_gain(1)`                      |

More information on how to use this wrapper and how it works can be found [here](https://github.com/Photometrics/PyVCAM/blob/master/docs/PyVCAM%20Wrapper.md).
