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


def ui(*args):
    return subprocess.run(["python3", "scripts/adb_ui.py", SERIAL, *args])


def screencap(name):
    sh(["python3", "scripts/adb_ui.py", SERIAL, "screencap", str(ROOT / name)])


def screen_size():
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    if not m:
        return 1080, 1920
    return int(m.group(1)), int(m.group(2))


def bottom_tab(index):
    w, h = screen_size()
    y = int(h * 0.94)
    x = int((index + 0.5) * (w / 5.0))
    adb("shell", "input", "tap", str(x), str(y))


def flow_dashboard_diary():
    ui("taptext", "Diário", "Diary", "Home", "Início", "Hoje", "Today")
    time.sleep(1.0)
    screencap("nt_diary.png")


def flow_add_meal():
    w, h = screen_size()
    adb("shell", "input", "tap", str(int(w * 0.90)), str(int(h * 0.86)))
    time.sleep(1.0)
    ui("taptext", "Adicionar", "Adicionar refeição", "Add", "Add meal", "Log food")
    time.sleep(1.2)
    screencap("nt_add_meal_open.png")


def flow_search_food():
    if ui("taptext", "Buscar", "Pesquisa", "Search", "Procurar").returncode != 0:
        w, h = screen_size()
        adb("shell", "input", "tap", str(int(w * 0.92)), str(int(h * 0.08)))
    time.sleep(1.0)
    ui("type", "banana")
    time.sleep(2.0)
    screencap("nt_search_banana.png")
    # Tentar abrir um resultado
    w, h = screen_size()
    adb("shell", "input", "tap", str(int(w * 0.5)), str(int(h * 0.35)))
    time.sleep(1.2)
    screencap("nt_food_detail.png")


def flow_goals_analytics_settings():
    for label, fname in [
        (["Metas", "Meta", "Goals"], "nt_goals.png"),
        (["Estatísticas", "Analytics", "Insights"], "nt_analytics.png"),
    ]:
        if ui("taptext", *label).returncode == 0:
            time.sleep(1.2)
            screencap(fname)
    if ui("taptext", "Configurações", "Ajustes", "Settings").returncode != 0:
        w, h = screen_size()
        adb("shell", "input", "tap", str(int(w * 0.08)), str(int(h * 0.08)))
    time.sleep(1.0)
    screencap("nt_settings.png")


def main():
    adb("shell", "monkey", "-p", "com.nutritracker.app", "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(2)
    flow_dashboard_diary()
    flow_add_meal()
    flow_search_food()
    flow_goals_analytics_settings()


if __name__ == "__main__":
    main()
