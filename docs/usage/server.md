# Invoking the Server Program
The controller server program must be running in order to communicate with the controller.

<!-- ## Docker Compose
If using a [Docker container](https://www.docker.com/resources/what-container/) to run the controller program, build and launch the container with [Docker Compose](https://docs.docker.com/compose/) from the project root directory:
```sh
$ docker compose build && docker compose up -d
```

Stop the container with:
```sh
$ docker compose down
```
-->

## Virtual Environment
<!-- If not using a [Docker container](https://www.docker.com/resources/what-container/),  -->
Running the controller server program in a [virtual environment](https://virtualenv.pypa.io/en/latest/user_guide.html) is strongly recommended.
Create and invoke the virtual environment with `virtualenv`:
```sh
$ python -m pip install virtualenv
$ python -m virtualenv venv
$ source venv/bin/activate # POSIX
```

On Windows:
```powershell
$ source venv\Scripts\Activate.ps1 # Powershell
# OR
$ source venv\Scripts\activate.bat # cmd.exe
```

Then launch the program in the background:
```sh
$ python -m pyvcam -p <port=3249> &
```

Stop the program either by sending the `terminate` command with `sipyco_rpctool` or an [ARTIQ](https://m-labs.hk/artiq/manual/index.html) script, or by identifying the process ID and killing it:
```sh
$ ps | grep aqctl_lumibird
$ kill <pid>
```

If the controller server is not running in the program, it can be closed in the terminal window in which it is running by pressing `^C` (`Ctl-C`).

Exit the virtual environment with the `deactivate` command:
```sh
$ deactivate
```
