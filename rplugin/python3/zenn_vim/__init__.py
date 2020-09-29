import typing

from .utils import cmd, output

try:
    import pynvim

    @pynvim.plugin
    class ZennEntryPoint(object):
        def __init__(self, nvim):
            self.nvim = nvim
            self.preview_pid: typing.Optional[int] = None

        @pynvim.function("_zenn_update")
        def zenn_update(self, args):
            zenn_update(self.nvim, args)

        @pynvim.function("_zenn_preview")
        def preview(self, args):
            zenn_preview(self.nvim, args)

        @pynvim.function("_zenn_stop_preview", sync=True)
        def kill_preview(self, args):
            kill_preview(self.nvim, args)


except ImportError:
    pass


def zenn_update(nvim, args):
    output.display_message(nvim, f"Zenn Update start. plz waiting.")
    result = cmd.call_npm(nvim, ["install", "zenn-cli@latest"])
    output.display_message(nvim, f"{result}")
    output.display_message(nvim, f"Zenn Update finished successfully")


def zenn_preview(nvim, args):
    _args = cmd.parse_command_f_args(args)
    _command = ["preview"] + _args
    _id = cmd.call_zenn_command(nvim, _command, daemon=True)
    port = _args if int(_args) else 8000
    output.display_message(nvim, f"Zenn preview start at localhost:{port}")


def kill_preview(self, args):
    output.display_message(
        self.nvim, "Zenn preview is stop automatically with vim closing"
    )
    try:
        if self.preview_pid is not None:
            cmd.kill_system_command_daemon(self.nvim, self.preview_pid)
        output.display_message(self.nvim, "Zenn preview successfully finished")
    except:
        output.display_message(self.nvim, "Stop Zenn preview Failed")
