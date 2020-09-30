import typing
import subprocess
from itertools import chain

from .output import *


def call_system_command(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    if daemon:
        # Todo: server manager to kill
        pass
        # _command: list = command + ["&", "echo", "$"]
        _command = command
    else:
        _command = command
    if debug:
        display_message(nvim, f"{_command}")
    result: subprocess.CompletedProcess = subprocess.run(
        _command, capture_output=capture_output, encoding="utf-8"
    )
    out, err = result.stdout, result.stderr
    if result.returncode is not 0:
        return err
    else:
        return out


def kill_system_command_daemon(nvim, pid: int, debug=False):
    display_message(nvim, "server killed")
    call_system_command(nvim, ["kill", "-9", pid], debug=debug, daemon=False)
    display_message(nvim, "server killed")


def parse_command_f_args(args: list):
    return list(chain.from_iterable(args))


def call_npm(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    return call_system_command(
        nvim,
        ["npm"] + command,
        debug=debug,
        capture_output=capture_output,
        daemon=daemon,
    )


def call_zenn_command(
    nvim, command: list, debug: bool = False, capture_output: bool = True, daemon=False
) -> str:
    return call_system_command(
        nvim,
        ["npx", "zenn"] + command,
        debug=debug,
        capture_output=capture_output,
        daemon=daemon,
    )
