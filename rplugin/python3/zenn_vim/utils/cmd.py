import typing
import subprocess
from itertools import chain

from .cmd_server import CmdServerManager
from .output import *


def start_system_command_daemon(
    nvim, command: list, daemon_manager: CmdServerManager, debug=False
) -> dict:
    if daemon_manager is None:
        if debug:
            display_message(nvim, "Daemon manager does not exist!")
        return None
    else:
        return daemon_manager.generate_daemon(nvim, command, debug)


def kill_system_command_daemon(
    nvim, daemon_id: int, daemon_manager: CmdServerManager, debug=False
):
    if daemon_manager is None:
        if debug:
            display_message(nvim, "Daemon manager does not exist!")
    else:
        daemon_manager.kill_daemon(daemon_id)


def call_system_command(nvim, command: list, debug: bool = True):
    if debug:
        display_message(nvim, f"{command}")
    result: subprocess.CompletedProcess = subprocess.run(command, capture_output=debug)
    if result.returncode != 0:
        if debug:
            display_error(nvim, result.stderr, command)
        else:
            display_error(nvim, result.stderr)
        return result.stderr
    else:
        if debug:
            display_message(nvim, result.stdout)
        return result.stdout


def parse_command_f_args(args: list):
    return list(chain.from_iterable(args))


def call_npm(nvim, command: list, debug: bool = False) -> str:
    return call_system_command(nvim, ["npm", "run"] + command, debug)


def call_zenn_command(nvim, command: list, debug: bool = False) -> str:
    return call_system_command(nvim, ["npx", "zenn"] + command, debug)
