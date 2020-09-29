from .output import display_message, display_error
import subprocess
from itertools import chain


class CmdServerManager:
    def __init__(self):
        self.daemon_list: list = []

    def generate_daemon(self, nvim, command: list, debug: bool = False) -> int:
        _daemon = CmdServer(nvim, command, debug=debug)
        self.daemon_list.append(_daemon)
        return len(self.daemon_list) - 1

    def kill_daemon(self, daemon_id: int):
        _daemon = self.daemon_list.get(daemon_id)
        if _daemon is not None:
            _daemon.kill()
            self.daemon_list[daemon_id] = None


class CmdServer:
    def __init__(self, nvim, command: list, debug: bool = False):
        self._nvim = nvim
        self._command: list = command
        self._proc = None
        self._debug: bool = debug

    def kill(self):
        if self._debug:
            display_message(self._nvim, f"Kill daemon ({self._command})")
        if self._proc is not None:
            self._proc.kill()
        else:
            display_message(self._nvim, f"Daemon is already killed")

    def run(self):
        with subprocess.Popen(
            self._command,
            encoding="UTF-8",
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        ) as proc:
            self._proc = proc
            if self._debug:
                display_message(self._nvim, f"Start daemon ({self._command})")
            try:
                while True:
                    msg = proc.stdout.readline().strip()
                    msg_err = proc.stderr.readline().strip()
                    if self._debug and msg != "":
                        display_message(self._nvim, msg)
                    if msg_err != "":
                        display_error(self._nvim, msg_err, command=self._command)
            except subprocess.TimeoutExpired:
                proc.kill()
                outs, errs = proc.communicate()
                display_error(self._nvim, "Daemon Timeout", command=self._command)
            finally:
                self._proc = None
