#!/usr/bin/env python3
import os
import subprocess
import time
from pathlib import Path

SERIAL = os.environ.get("ADB_SERIAL", "emulator-5554")
ROOT = Path("assets/reference_yazio")
ROOT.mkdir(parents=True, exist_ok=True)


def sh(cmd, check=True):
    return subprocess.run(cmd, check=check)


def adb(*args, check=True):
    return sh(["adb", "-s", SERIAL, *args], check=check)


def screencap(name):
    out = ROOT / name
    sh(["python3", "scripts/adb_ui.py", SERIAL, "screencap", str(out)])


def tap_text(*patterns):
    # Best-effort; ignore failure
    return subprocess.run(["python3", "scripts/adb_ui.py", SERIAL, "taptext", *patterns]).returncode == 0


def wait_text(timeout, *patterns):
    return sh(["python3", "scripts/adb_ui.py", SERIAL, "waittext", *patterns, "--timeout", str(timeout)]).returncode == 0


def swipe_left(times=1):
    # Generic left swipe: middle vertical
    # Coordinates tuned for typical phone screens; UI helper could compute size, but keep simple.
    for _ in range(times):
        adb("shell", "input", "swipe", "1000", "1600", "200", "1600", "250")
        time.sleep(0.6)


def record_video(seconds, fname):
    remote = "/sdcard/yazio_flow.mp4"
    adb("shell", "rm", "-f", remote, check=False)
    adb("shell", "screenrecord", "--time-limit", str(seconds), remote)
    sh(["adb", "-s", SERIAL, "pull", remote, str(ROOT / fname)])


def screen_size():
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    if not m:
        return 1080, 1920
    return int(m.group(1)), int(m.group(2))


def bottom_tab_sweep(prefix="yazio_tab"):
    w, h = screen_size()
    y = int(h * 0.94)
    for i in range(5):
        x = int((i + 0.5) * (w / 5.0))
        adb("shell", "input", "tap", str(x), str(y))
        time.sleep(1.2)
        screencap(f"{prefix}_{i+1}.png")


def tap_fab():
    # best-effort FAB tap at bottom-right
    w, h = screen_size()
    x = int(w * 0.90)
    y = int(h * 0.86)
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(1.0)


def try_open_search():
    # Try by text first, then tap top-right
    if tap_text("Buscar", "Pesquisa", "Search", "Procurar", "Find"):
        time.sleep(1.0)
        return True
    w, h = screen_size()
    # Typical appbar search icon area
    adb("shell", "input", "tap", str(int(w * 0.92)), str(int(h * 0.08)))
    time.sleep(1.0)
    return True


def main():
    # Launch YAZIO
    adb("shell", "monkey", "-p", "com.yazio.android", "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(2)

    # Onboarding screens: capture and swipe
    screencap("yazio_onboarding_1.png")
    swipe_left(1)
    screencap("yazio_onboarding_2.png")
    swipe_left(1)
    screencap("yazio_onboarding_3.png")

    # Try to tap common CTA to proceed
    tap_text("Começar", "Comece", "Vamos", "Continuar", "Próximo", "Avançar", "Pular", "Skip", "Get started", "Start", "Next", "Continue")
    time.sleep(2)
    screencap("yazio_post_cta.png")

    # Try to reach main dashboard by tapping potential skip/continue
    for _ in range(3):
        if tap_text("Pular", "Skip", "Depois", "Agora não", "Continuar", "Avançar"):
            time.sleep(2)
            screencap(f"yazio_cta_progress_{_+1}.png")

    # Short video of current flow state
    record_video(8, "yazio_flow_short.mp4")

    # Final screenshot after video
    screencap("yazio_dashboard_guess.png")

    # Explore tabs and common actions
    bottom_tab_sweep()
    screencap("yazio_after_tabs.png")

    # Try opening add-meal via FAB or text
    tap_fab()
    if tap_text("Adicionar", "Adicionar refeição", "Adicionar alimento", "Add", "Add food", "Add meal", "Log food"):
        time.sleep(1.2)
    screencap("yazio_add_flow.png")

    # Try to open search and capture
    try_open_search()
    screencap("yazio_search.png")
    record_video(6, "yazio_search_short.mp4")


if __name__ == "__main__":
    main()
