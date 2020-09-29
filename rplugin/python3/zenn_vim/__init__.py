from .utils import cmd, cmd_server, output

try:
    import neovim

    @neovim.plugin
    class ZennEntryPoint(object):
        def __init__(self, nvim):
            self.nvim = nvim
            self.daemon_manager = cmd_server.CmdServerManager()
            self.preview_server_id = None

        @neovim.function("_zenn_init", sync=True)
        def zenn_init(self, args):
            cmd.call_zenn_command(self.nvim, ["init"])
            output.display_message(self.nvim, "Zenn init finished")
            # return True

        @neovim.function("_zenn_preview", sync=True)
        def preview(self, args):
            if self.preview_server_id is not None:
                output.display_message(self.nvim, "Already running")
                return
            _args = cmd.parse_command_f_args(args)
            _command = ["preview"] + _args
            _id, _daemon = cmd.start_system_command_daemon(
                self.nvim, _command, self.daemon_manager
            )
            self.preview_server_id = _id
            _daemon.run()
            output.display_message(self.nvim, "Zenn preview start")

        @neovim.function("_zenn_stop_preview", sync=True)
        def kill_preview(self, args):
            self.daemon_manager.kill_daemon(self.preview_server_id)
            output.display_message(self.nvim, "Zenn preview successfully finished")
            # cmd.call_system_command(self.nvim, cmd.parse_command_f_args(args), True)

        @neovim.function("_zenn_resume", sync=True)
        def resume(self, args):
            self.nvim.out_write("zenn server resume.\n")
            # return True


except ImportError:
    pass
