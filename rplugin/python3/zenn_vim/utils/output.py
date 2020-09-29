import typing


def display_message(nvim, msg):
    nvim.command(f'echomsg string("{msg}")')


def display_error(nvim, error_msg: str, command: typing.Optional[list] = None):
    nvim.command("echohl ErrorMsg")
    if command is not None:
        nvim.command(f'echomsg "{command}"')
        display_message(nvim, f"zenn-vim: {error_msg}")
        nvim.command("echohl None")
