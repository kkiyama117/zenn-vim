from .utils import cmd

try:
    import neovim

    @neovim.plugin
    class ZennEntryPoint(object):
        def __init__(self, nvim):
            self.nvim = nvim
            self.daemon_manager = cmd.CmdServerManager()

        @neovim.function("_zenn_init", sync=True)
        def zenn_init(self, args):
            cmd.call_zenn_command(self.nvim, ["init"])
            # return True

        @neovim.function("_zenn_preview", sync=True)
        def preview(self, args):
            _args = cmd.parse_command_f_args(args)
            _command = ["init"].extend(_args)
            cmd.call_zenn_command(self.nvim, _command)
            # cmd.call_system_command(self.nvim, cmd.parse_command_f_args(args), True)
            # return True

        @neovim.function("_zenn_resume", sync=True)
        def resume(self, args):
            self.nvim.out_write("zenn server resume.\n")
            # return True


except ImportError:
    pass
