import typing


def display_message(nvim, msg):
    nvim.command(f'echomsg "{msg}"')


def display_error(nvim, error_msg: str, command: typing.Optional[list] = None):
    nvim.command("echohl ErrorMsg")
    if command is not None:
        nvim.command(f'echomsg "{command}"')
        nvim.command(f'echomsg "zenn-vim: {error_msg}"')
        nvim.command("echohl None")
