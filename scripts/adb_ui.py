#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET


def run(cmd, check=True, capture_output=True):
    if capture_output:
        return subprocess.run(cmd, check=check, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    else:
        return subprocess.run(cmd, check=check)


class AdbUI:
    def __init__(self, serial: str):
        self.serial = serial

    def adb(self, *args, check=True, capture_output=True):
        return run(["adb", "-s", self.serial, *args], check=check, capture_output=capture_output)

    def screen_size(self):
        out = self.adb("shell", "wm", "size").stdout.strip()
        m = re.search(r"Physical size: (\d+)x(\d+)", out)
        if not m:
            raise RuntimeError(f"Cannot read screen size: {out}")
        return int(m.group(1)), int(m.group(2))

    def tap(self, x: int, y: int):
        self.adb("shell", "input", "tap", str(x), str(y), capture_output=False)

    def swipe(self, x1, y1, x2, y2, duration_ms=300):
        self.adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration_ms), capture_output=False)

    def key(self, keycode: str):
        self.adb("shell", "input", "keyevent", keycode, capture_output=False)

    def screencap(self, out_path: str):
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        with open(out_path, "wb") as f:
            p = subprocess.Popen(["adb", "-s", self.serial, "exec-out", "screencap", "-p"], stdout=f)
            p.wait(timeout=10)

    def dump_ui(self, local_path: str):
        tmp = "/sdcard/uidump.xml"
        try:
            self.adb("shell", "uiautomator", "dump", tmp)
            os.makedirs(os.path.dirname(local_path), exist_ok=True)
            self.adb("pull", tmp, local_path)
            return local_path
        except Exception:
            return None

    def find_bounds_by_texts(self, texts):
        """Return center (x,y) for the first matching node by text/content-desc regex list."""
        dump_path = os.path.join("/tmp", f"uidump_{self.serial}.xml")
        path = self.dump_ui(dump_path)
        if not path or not os.path.exists(dump_path):
            return None
        tree = ET.parse(dump_path)
        root = tree.getroot()
        def match(node_text):
            return any(re.search(pat, node_text, re.I) for pat in texts)
        for node in root.iter("node"):
            t = node.attrib.get("text", "")
            c = node.attrib.get("content-desc", "")
            if match(t) or match(c):
                b = node.attrib.get("bounds")
                if not b:
                    continue
                m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", b)
                if not m:
                    continue
                x1, y1, x2, y2 = map(int, m.groups())
                return (x1 + x2) // 2, (y1 + y2) // 2
        return None

    def tap_text(self, texts):
        pt = self.find_bounds_by_texts(texts)
        if pt:
            self.tap(*pt)
            return True
        return False

    def wait_text(self, texts, timeout=8, interval=0.7):
        deadline = time.time() + timeout
        while time.time() < deadline:
            if self.find_bounds_by_texts(texts):
                return True
            time.sleep(interval)
        return False

    def type_text(self, text: str):
        escaped = (
            text.replace(" ", "%s")
                .replace("&", "")
                .replace("(", "")
                .replace(")", "")
                .replace("|", "")
        )
        self.adb("shell", "input", "text", escaped, capture_output=False)


def main():
    parser = argparse.ArgumentParser(description="ADB UI helper")
    parser.add_argument("serial", help="adb device serial, e.g., emulator-5554")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sc = sub.add_parser("screencap")
    sc.add_argument("out")

    tp = sub.add_parser("taptext")
    tp.add_argument("pattern", nargs="+", help="regex patterns to match text/content-desc")

    wt = sub.add_parser("waittext")
    wt.add_argument("pattern", nargs="+")
    wt.add_argument("--timeout", type=int, default=8)

    sw = sub.add_parser("swipe")
    sw.add_argument("x1", type=int); sw.add_argument("y1", type=int)
    sw.add_argument("x2", type=int); sw.add_argument("y2", type=int)
    sw.add_argument("--dur", type=int, default=300)

    kb = sub.add_parser("key")
    kb.add_argument("keycode")

    tptext = sub.add_parser("type")
    tptext.add_argument("text")

    args = parser.parse_args()
    ui = AdbUI(args.serial)

    if args.cmd == "screencap":
        ui.screencap(args.out)
    elif args.cmd == "taptext":
        ok = ui.tap_text(args.pattern)
        sys.exit(0 if ok else 1)
    elif args.cmd == "waittext":
        ok = ui.wait_text(args.pattern, timeout=args.timeout)
        sys.exit(0 if ok else 1)
    elif args.cmd == "swipe":
        ui.swipe(args.x1, args.y1, args.x2, args.y2, args.dur)
    elif args.cmd == "key":
        ui.key(args.keycode)
    elif args.cmd == "type":
        ui.type_text(args.text)


if __name__ == "__main__":
    main()
