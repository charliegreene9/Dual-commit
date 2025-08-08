# You can prefill the details of the personal access token by
# appending the name,
# description, and list of scopes to the URL. For example:
# https://gitlab.example.com/-/user_settings/personal_access_tokens?name=Example+Access+token&description=My+description&scopes=api,read_user

# Empty clipboard of copied password
from ctypes import windll

if windll.user32.OpenClipboard(None):
    windll.user32.EmptyClipboard()
    windll.user32.CloseClipboard()

# pyperclip.copy("")
# Linux
# import os as o

# o.system("echo|xclip")

# Windows
# import os

# os.system("fc|clip")
