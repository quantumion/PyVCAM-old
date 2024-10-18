# ARTIQ Device Database
The controller must be added to the [ARTIQ system device database](https://m-labs.hk/artiq/manual/environment.html#the-device-database) in order to be [controlled from an ARTIQ script](../usage/controller.md#artiq-script).

## Device Database Entry
Add the following entry to the `device_db.py` file for the system:
```python
device_db["pyvcam"] = {
    "type": "controller",
    "host": "::1", # or IP address of the host computer for the laser controller
    "port": 3249, # default - may change based on system configuration
    "target": "pyvcam", # optional
    "command": "python -m pyvcam -p {port}>",
}
```
