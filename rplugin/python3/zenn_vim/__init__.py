try:
    import neovim

    @neovim.plugin
    class ZennEntryPoint(object):
        def __init__(self, nvim):
            self.nvim = nvim
            self.registory = Registry(nvim)

        @neovim.function("_zenn_start", sync=True)
        def start(self, args):
            self.nvim.out_write("zenn server start.\n")
            self.registory.test(args)
            # return True

        @neovim.function("_zenn_resume", sync=True)
        def resume(self, args):
            self.nvim.out_write("zenn server resume.\n")
            # return True


except ImportError:
    pass


class Registry:
    def __init__(self, nvim):
        self.nvim = nvim

    def test(self, args):
        self.nvim.command("echohl ErrorMsg")
        self.nvim.command(f"echomsg string({args})")
        self.nvim.command("echohl None")
