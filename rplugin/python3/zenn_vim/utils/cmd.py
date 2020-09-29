import typing
import subprocess
from itertools import chain

from .output import *


def call_system_command(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    if daemon:
        _command: list = command + ["&", "echo", "$"]
    else:
        _command = command
    if debug:
        display_message(nvim, f"{_command}")
    result: subprocess.CompletedProcess = subprocess.run(
        command, capture_output=capture_output, encoding="utf-8"
    )
    out, err = result.stdout, result.stderr
    if result.returncode is not 0:
        if debug:
            display_error(nvim, err, command)
        else:
            display_error(nvim, err)
        return err
    else:
        if debug:
            display_message(nvim, result.stdout)
        display_message(nvim, out)
        return out


def kill_system_command_daemon(nvim, pid: int, debug=True):
    display_message(nvim, "server killed")
    call_system_command(nvim, ["kill", "-9", pid], debug=debug, daemon=False)
    display_message(nvim, "server killed")


def parse_command_f_args(args: list):
    return list(chain.from_iterable(args))


def call_npm(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    return call_system_command(nvim, ["npm"] + command, debug, daemon=daemon)


def call_zenn_command(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    return call_system_command(nvim, ["npx", "zenn"] + command, debug, daemon=daemon)
