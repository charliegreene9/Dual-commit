# # You can prefill the details of the personal access token by
# # appending the name,
# # description, and list of scopes to the URL. For example:
# # https://gitlab.example.com/-/user_settings/personal_access_tokens?name=Example+Access+token&description=My+description&scopes=api,read_user

# # Empty clipboard of copied password
# from ctypes import windll

# if windll.user32.OpenClipboard(None):
#     windll.user32.EmptyClipboard()
#     windll.user32.CloseClipboard()

# # pyperclip.copy("")
# # Linux
# # import os as o

# # o.system("echo|xclip")

# # Windows
# # import os

# # os.system("fc|clip")

import datetime as dt
import os
import re
import sys
import time
import tkinter as tk
from getpass import getpass

import chromedriver_autoinstaller
import pyautogui as pya
import pyperclip
from dotenv import load_dotenv, set_key
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys


def timed_input(title="Input dialog box", msg: str = "", timeout: int = 10000):
    w = tk.Tk()
    w.title(title)
    tk.Label(text=msg, font=("Georgia 15 bold")).pack(pady=30)
    timed_input.data = ""
    wFrame = tk.Frame(w, background="light yellow", padx=20, pady=20)
    wFrame.pack()
    wEntryBox = tk.Entry(wFrame, background="white", width=100)
    wEntryBox.focus_force()
    wEntryBox.pack()

    def fin():
        timed_input.data = str(wEntryBox.get())
        w.destroy()

    wSubmitButton = tk.Button(w, text="OK", command=fin, default="active")
    wSubmitButton.pack()

    # Code in order to have a stroke on "Return" instead of pressing ok
    def fin_R(event):
        fin()

    w.bind("<Return>", fin_R)

    w.after(
        timeout, w.destroy
    )  # This is the KEY INSTRUCTION that destroys the dialog box after
    # the given timeout in milliseconds
    w.mainloop()


def copy_clipboard():
    pya.hotkey("ctrl", "c")
    time.sleep(
        0.01
    )  # ctrl-c is usually very fast but your program may execute faster
    return pyperclip.paste()


def setup_browser():
    # TODO: Add code to download the driver
    chromedriver_autoinstaller.install()
    chrome_options = Options()
    # chrome_options.add_argument("--headless") # comment out for dev
    chrome_options.add_argument("--window-size=1920x1080")
    driver = webdriver.Chrome(options=chrome_options)

    return driver


def login(driver, login_credentials: dict):
    driver.find_element(By.NAME, "username").send_keys(
        f"{login_credentials['username']}"
    )
    driver.find_element(By.NAME, "password").send_keys(
        f"{login_credentials['password']}"
    )
    driver.find_element(By.NAME, "password").send_keys(Keys.RETURN)
    time.sleep(2)


def get_to_login(driver):
    # Complete these steps so that the login function can be run
    # For this institution (VU Amsterdam) clicking an element
    # Will reveal the login inputs
    driver.find_element(By.XPATH, '//*[@id="gl_tab_nav__tab_1"]').click()


def create_token(driver):
    # Get the project name
    proj_name = os.getcwd().split(".git")[0].split("\\")[-2]
    # Clicking on button to make a new token
    driver.find_element(
        By.XPATH,
        "/html/body/div[1]/div[2]/div[4]/main/section/div[2]/section/div/header/div[2]/button/span",
    ).click()
    # TODO: See if project slug can be retrieved from .git folder
    driver.find_element(By.ID, "personal_access_token_name").send_keys(
        f"{proj_name}"
    )
    driver.find_element(
        By.XPATH, '//*[@id="personal_access_token_description"]'
    ).send_keys("")
    # TODO: Try to grab description from the .git folder
    timed_input(
        "Expiration date",
        """When should the token expire?
        [Enter the date in 'yyyy-mm-dd' format]""",
        15000,
    )
    expiration_date = timed_input.data
    # Setting a date two months from date of use
    ## To use in the case of input error/skip
    default_date = dt.datetime.now() + dt.timedelta(days=60)
    default_date = default_date.strftime("%Y-%m-%d")
    if expiration_date == "":
        print("No date given. Defaulting to 2 month token...")
        expiration_date = default_date
    elif re.search("\d{4}\-\d{2}\-\d{2}", expiration_date):
        print("""Date was either not completed or was an incorrect format.
              Defaulting to 2 month token...""")
        expiration_date = default_date
    driver.find_element(
        By.XPATH, '//*[@id="personal_access_token_expires_at"]'
    ).send_keys(expiration_date)
    driver.find_element(
        By.XPATH, '//*[@id="personal_access_token_expires_at"]'
    ).send_keys(Keys.RETURN)


def get_token(driver):
    driver.find_element(
        By.XPATH,
        "/html/body/div[1]/div[2]/div[4]/main/section/div[2]/div/div/div[2]/div/div/div/div/div/button[1]/svg",
    ).click()
    driver.find_element(By.XPATH, '//*[@id="new-access-token"]').click()
    # Copy the token and add it to the .env
    token = copy_clipboard()
    set_key(".env", os.environ["GITLAB-TOKEN"], token)
    # Copying a blank string to avoid mistakenly pasting the token
    pyperclip.copy("")


def main():
    # Load in environment variables
    load_dotenv()
    driver = setup_browser()
    driver.get(os.getenv("GITLAB-URL"))  # for gitlab.com itself
    try:
        get_to_login(driver)
    except Exception as e:
        print(e)
    # Login credentials are filled in here
    login_credentials = {}
    timed_input("Username: ", "Please provide your GitLab username")
    login_credentials["username"] = timed_input.data
    if login_credentials["username"] == "":
        print("Failed to provide a username. Terminating program...")
        sys.exit()
    login_credentials["password"] = getpass("Password: ")
    login(driver, login_credentials)
    create_token(driver)
    # Save to env file
    get_token(driver)
    # End script


if __name__ == "__main__":
    main()
