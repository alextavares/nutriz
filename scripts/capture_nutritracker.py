#!/usr/bin/env python3
import os
import subprocess
import time
from pathlib import Path

SERIAL = os.environ.get("ADB_SERIAL", "emulator-5554")
ROOT = Path("assets/nutritracker")
ROOT.mkdir(parents=True, exist_ok=True)


def sh(cmd, check=True):
    return subprocess.run(cmd, check=check)


def adb(*args, check=True):
    return sh(["adb", "-s", SERIAL, *args], check=check)


def screencap(name):
    out = ROOT / name
    sh(["python3", "scripts/adb_ui.py", SERIAL, "screencap", str(out)])


def bottom_tab_sweep():
    # Tap across five equal segments at bottom to discover tabs
    # Determine size for y coordinate
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True)
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out.stdout)
    if m:
        w, h = int(m.group(1)), int(m.group(2))
    else:
        w, h = 1080, 1920
    y = int(h * 0.94)
    for i in range(5):
        x = int((i + 0.5) * (w / 5.0))
        adb("shell", "input", "tap", str(x), str(y))
        time.sleep(1.2)
        screencap(f"nt_tab_{i+1}.png")


def screen_size():
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    if not m:
        return 1080, 1920
    return int(m.group(1)), int(m.group(2))


def tap_fab():
    w, h = screen_size()
    x = int(w * 0.90)
    y = int(h * 0.86)
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(1.0)


def main():
    # Bring our app to foreground if not already
    adb("shell", "monkey", "-p", "com.nutritracker.app", "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(2)
    screencap("nt_home.png")

    # Try a left swipe (e.g., onboarding carousel)
    adb("shell", "input", "swipe", "1000", "1600", "200", "1600", "250")
    time.sleep(1)
    screencap("nt_swipe_1.png")

    # Explore bottom tabs if present
    bottom_tab_sweep()

    # Try FAB (add flow) and search
    tap_fab()
    screencap("nt_after_fab.png")
    # Try tapping a generic search spot in appbar
    w, h = screen_size()
    adb("shell", "input", "tap", str(int(w * 0.92)), str(int(h * 0.08)))
    time.sleep(1.0)
    screencap("nt_search_try.png")

    # Record a short video of navigating tabs
    remote = "/sdcard/nt_flow.mp4"
    adb("shell", "rm", "-f", remote, check=False)
    # Start recording
    # While recording, tap through tabs quickly
    # Note: screenrecord is blocking; we will run it with a timeout and do taps before/after
    # First some taps before recording to get variety
    bottom_tab_sweep()
    adb("shell", "screenrecord", "--time-limit", "8", remote)
    sh(["adb", "-s", SERIAL, "pull", remote, str(ROOT / "nt_flow_short.mp4")])


if __name__ == "__main__":
    main()
