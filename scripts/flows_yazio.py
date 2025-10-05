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


def ui(*args):
    return subprocess.run(["python3", "scripts/adb_ui.py", SERIAL, *args])


def screencap(name):
    sh(["python3", "scripts/adb_ui.py", SERIAL, "screencap", str(ROOT / name)])


def bottom_tab(index):
    # Tap 0..4 across bottom
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    if not m:
        w, h = 1080, 1920
    else:
        w, h = int(m.group(1)), int(m.group(2))
    y = int(h * 0.94)
    x = int((index + 0.5) * (w / 5.0))
    adb("shell", "input", "tap", str(x), str(y))


def try_dismiss_onboarding():
    # Best-effort skip/continue
    for _ in range(5):
        if ui("taptext", "Pular", "Skip", "Agora não", "Continuar", "Avançar", "Start", "Get started").returncode == 0:
            time.sleep(1.2)
            screencap(f"yazio_onboarding_skip_{_+1}.png")
        else:
            break


def flow_dashboard_diary():
    # Try to land on dashboard/diary/home
    ui("taptext", "Diário", "Diario", "Diary", "Home", "Início", "Hoje", "Today")
    time.sleep(1.2)
    screencap("yazio_diary.png")


def flow_add_meal():
    # Try FAB or Add button
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    w, h = (int(m.group(1)), int(m.group(2))) if m else (1080, 1920)
    adb("shell", "input", "tap", str(int(w * 0.90)), str(int(h * 0.86)))
    time.sleep(1.0)
    ui("taptext", "Adicionar", "Adicionar refeição", "Add", "Add meal", "Log food")
    time.sleep(1.2)
    screencap("yazio_add_meal_open.png")


def flow_search_food():
    # Try tap search and type banana
    if ui("taptext", "Buscar", "Pesquisa", "Search", "Procurar").returncode != 0:
        # tap appbar right
        out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
        import re
        m = re.search(r"Physical size: (\d+)x(\d+)", out)
        w, h = (int(m.group(1)), int(m.group(2))) if m else (1080, 1920)
        adb("shell", "input", "tap", str(int(w * 0.92)), str(int(h * 0.08)))
    time.sleep(1.0)
    ui("type", "banana")
    time.sleep(2.0)
    screencap("yazio_search_banana.png")
    # Tentar abrir o primeiro resultado (tap no centro da lista)
    out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
    import re
    m = re.search(r"Physical size: (\d+)x(\d+)", out)
    w, h = (int(m.group(1)), int(m.group(2))) if m else (1080, 1920)
    adb("shell", "input", "tap", str(int(w * 0.5)), str(int(h * 0.35)))
    time.sleep(1.2)
    screencap("yazio_food_detail.png")


def flow_goals_analytics_settings_paywall():
    # Try tabs for goals/analytics
    for label, fname in [
        (["Metas", "Meta", "Goals"], "yazio_goals.png"),
        (["Estatísticas", "Analytics", "Insights"], "yazio_analytics.png"),
    ]:
        if ui("taptext", *label).returncode == 0:
            time.sleep(1.2)
            screencap(fname)

    # Settings: try gear area or text
    if ui("taptext", "Configurações", "Ajustes", "Settings").returncode != 0:
        out = subprocess.run(["adb", "-s", SERIAL, "shell", "wm", "size"], stdout=subprocess.PIPE, text=True).stdout
        import re
        m = re.search(r"Physical size: (\d+)x(\d+)", out)
        w, h = (int(m.group(1)), int(m.group(2))) if m else (1080, 1920)
        adb("shell", "input", "tap", str(int(w * 0.08)), str(int(h * 0.08)))
    time.sleep(1.0)
    screencap("yazio_settings.png")

    # Paywall/Pro
    if ui("taptext", "Pro", "Premium", "Assinatura", "Upgrade").returncode == 0:
        time.sleep(1.5)
        screencap("yazio_paywall.png")


def main():
    # Launch app
    adb("shell", "monkey", "-p", "com.yazio.android", "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(2)

    try_dismiss_onboarding()
    flow_dashboard_diary()
    flow_add_meal()
    flow_search_food()
    flow_goals_analytics_settings_paywall()


if __name__ == "__main__":
    main()
