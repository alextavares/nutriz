#!/usr/bin/env python3
import subprocess
import time

SERIAL = "emulator-5554"


def adb(*args, check=True):
    return subprocess.run(["adb", "-s", SERIAL, *args], check=check)


def set_dark_mode(enabled: bool):
    subprocess.run(["adb", "-s", SERIAL, "shell", "cmd", "uimode", "night", "yes" if enabled else "no"])  # best-effort


def set_font_scale(scale: float):
    subprocess.run(["adb", "-s", SERIAL, "shell", "settings", "put", "system", "font_scale", str(scale)])


def screencap(app_pkg: str, out_path: str):
    # Launch and capture
    adb("shell", "monkey", "-p", app_pkg, "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(2)
    with open(out_path, "wb") as f:
        p = subprocess.Popen(["adb", "-s", SERIAL, "exec-out", "screencap", "-p"], stdout=f)
        p.wait(timeout=10)


def main():
    # Dark mode ON
    set_dark_mode(True)
    time.sleep(1)
    screencap("com.yazio.android", "assets/reference_yazio/yazio_dark_home.png")
    screencap("com.nutritracker.app", "assets/nutritracker/nt_dark_home.png")

    # Larger font scale
    set_font_scale(1.3)
    time.sleep(1)
    screencap("com.yazio.android", "assets/reference_yazio/yazio_fontlg_home.png")
    screencap("com.nutritracker.app", "assets/nutritracker/nt_fontlg_home.png")

    # Restore defaults
    set_dark_mode(False)
    set_font_scale(1.0)


if __name__ == "__main__":
    main()

