#!/usr/bin/env python3
"""
Lightweight UI crawler for Android apps using ADB + UIAutomator XML dumps.

Goal: Map onboarding flow of YAZIO (or any package) and save a graph with
screenshots and UI trees. Designed for semi-automatic exploration with
safe heuristics (focus on Continue/Next/Skip/etc.).

Usage:
  python scripts/yazio_flowmap.py --device emulator-5556 --pkg de.yazio.android \
         --out data/yazio_flow --max-steps 25 --max-depth 3 --top-k 3

Outputs:
  - <out>/nodes/<n>_tree.xml
  - <out>/nodes/<n>_screenshot.png
  - <out>/flow.json (nodes, edges)

Notes:
  - This does NOT copy assets or texts for reuse; it's only a structural map.
  - Requires `adb` in PATH.
"""

import argparse
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET


def sh(cmd, timeout=20, binary=False):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        out, err = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        p.kill()
        out, err = p.communicate()
    if p.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\n{err.decode('utf-8','ignore')}")
    return out if binary else out.decode("utf-8", "ignore")


def adb(device, *args, binary=False, timeout=20):
    cmd = ["adb", "-s", device] + list(args)
    return sh(cmd, timeout=timeout, binary=binary)


def launch_app(device, pkg):
    try:
        adb(device, "shell", "monkey", "-p", pkg, "-c", "android.intent.category.LAUNCHER", "1")
        time.sleep(1.2)
    except Exception as e:
        print(f"[warn] launch_app: {e}")


def dump_ui_xml(device):
    path_hint = "/sdcard/window_dump.xml"
    out = adb(device, "shell", "uiautomator", "dump", path_hint)
    if "UI hierchary dumped to" not in out and "UI hierarchy dumped to" not in out:
        # Some ROMs write different message; continue anyway
        pass
    xml = adb(device, "shell", "cat", path_hint)
    return xml


def take_screenshot(device):
    return adb(device, "exec-out", "screencap", "-p", binary=True)


def parse_nodes(xml_text):
    root = ET.fromstring(xml_text)
    nodes = []
    for node in root.iter():
        if node.tag.lower() == 'node':
            clickable = node.attrib.get('clickable') == 'true'
            text = node.attrib.get('text', '')
            desc = node.attrib.get('content-desc', '')
            bounds = node.attrib.get('bounds', '')
            res_id = node.attrib.get('resource-id', '')
            if bounds:
                m = re.findall(r"\d+", bounds)
                if len(m) == 4:
                    x1, y1, x2, y2 = map(int, m)
                else:
                    x1 = y1 = x2 = y2 = 0
            else:
                x1 = y1 = x2 = y2 = 0
            nodes.append({
                'clickable': clickable,
                'text': text,
                'desc': desc,
                'id': res_id,
                'bounds': [x1, y1, x2, y2],
            })
    return nodes


KEYWORDS = [
    # Positive defaults (prioritize onboarding/permissions/next actions)
    'continue', 'next', 'skip', 'get started', 'start', 'ok', 'allow',
    "i'm committed", 'im committed', 'concluir', 'continuar', 'próximo', 'pular',
    'permitir', 'aceitar', 'aceite', 'avançar', 'prosseguir', 'seguir', 'pronto',
]

# Negative defaults (deprioritize monetization/sharing/legal detours)
AVOID_DEFAULTS = [
    'buy', 'subscribe', 'subscription', 'trial', 'free trial', 'restore', 'upgrade',
    'pro', 'premium', 'shop', 'store', 'comprar', 'assinar', 'assinatura', 'avaliar', 'rate',
    'share', 'facebook', 'twitter', 'instagram', 'terms', 'privacy', 'policy', 'política',
    'conta', 'entrar com', 'sign in with', 'log in with'
]

# Permission-accept patterns for auto handling
ALLOW_PATTERNS = [
    'allow', 'permitir', 'ok', 'enquanto o app estiver em uso', 'while using the app',
    'only this time', 'somente desta vez', 'permita', 'aceitar'
]


def score_node(n, prefer_terms=None, avoid_terms=None, bottom_bias_ref=None):
    text = f"{n['text']} {n['desc']} {n['id']}".strip().lower()
    base = 0
    # Strong positive signals
    for k in KEYWORDS:
        if k in text:
            base += 5
    # Custom prefer list
    if prefer_terms:
        for k in prefer_terms:
            if k and k in text:
                base += 3
    # Custom avoid and defaults
    penalties = 0
    avoid_all = (avoid_terms or []) + AVOID_DEFAULTS
    for k in avoid_all:
        if k and k in text:
            penalties += 4
    base -= penalties
    if n['clickable']:
        base += 1
    # prefer visible-sized targets
    x1, y1, x2, y2 = n['bounds']
    if (x2 - x1) > 40 and (y2 - y1) > 30:
        base += 1
    # small boost for primary/button-like ids
    if any(t in text for t in ['button', 'primary', 'continue', 'next']):
        base += 1
    # bottom bias: prefer CTAs near the bottom of the screen
    if bottom_bias_ref is not None and bottom_bias_ref > 0:
        try:
            # normalize by max y2, add up to +2 bonus
            ratio = min(1.0, max(0.0, y2 / float(bottom_bias_ref)))
            base += int(2 * ratio)
        except Exception:
            pass
    return base


def center(bounds):
    x1,y1,x2,y2 = bounds
    return (x1+x2)//2, (y1+y2)//2


def signature(nodes):
    # hash of ids + texts + clickable structure
    parts = []
    for n in nodes:
        parts.append((n['id'][:40], n['text'][:40], n['desc'][:40], n['clickable']))
    data = json.dumps(parts, ensure_ascii=False).encode('utf-8')
    return hashlib.sha1(data).hexdigest()[:12]


def tap(device, x, y):
    adb(device, "shell", "input", "tap", str(x), str(y))


def go_back(device):
    adb(device, "shell", "input", "keyevent", "4")


def ensure_dirs(out_dir):
    os.makedirs(os.path.join(out_dir, 'nodes'), exist_ok=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--device', default='emulator-5556')
    ap.add_argument('--pkg', default='de.yazio.android')
    ap.add_argument('--out', default='data/yazio_flow')
    ap.add_argument('--max-steps', type=int, default=25)
    ap.add_argument('--max-depth', type=int, default=3)
    ap.add_argument('--top-k', type=int, default=3)
    ap.add_argument('--prefer', type=str, default='')
    ap.add_argument('--avoid', type=str, default='')
    ap.add_argument('--per-screen-limit', type=int, default=5, help='Max clicks to try per unique screen signature')
    ap.add_argument('--stop-when-text', type=str, default='', help='Stop exploring when this text appears on screen')
    ap.add_argument('--detect-tabbar-stop', action='store_true', help='Stop when a bottom tab bar is detected (>=3 labels near bottom)')
    ap.add_argument('--auto-allow', action='store_true', help='Auto-accept runtime permission dialogs if detected')
    args = ap.parse_args()

    ensure_dirs(args.out)
    launch_app(args.device, args.pkg)

    nodes_db = {}
    edges = []
    visited = set()
    saved_counter = 0
    per_screen_clicks = {}

    def save_state(sig, xml_text, step_index):
        nonlocal saved_counter
        if sig in nodes_db:
            return
        png = take_screenshot(args.device)
        node_dir = os.path.join(args.out, 'nodes')
        with open(os.path.join(node_dir, f"{step_index:03d}_{sig}_tree.xml"), 'w', encoding='utf-8') as f:
            f.write(xml_text)
        with open(os.path.join(node_dir, f"{step_index:03d}_{sig}_screenshot.png"), 'wb') as f:
            f.write(png)
        nodes_db[sig] = {'id': sig, 'index': step_index}
        saved_counter += 1

    def capture_signature():
        xml_text = dump_ui_xml(args.device)
        nodes = parse_nodes(xml_text)
        sig = signature(nodes)
        return sig, xml_text, nodes

    def find_allow(nodes):
        for n in nodes:
            if not n['clickable']:
                continue
            txt = f"{n['text']} {n['desc']}`{n['id']}".lower()
            if any(k in txt for k in ALLOW_PATTERNS):
                return n
        return None

    def detect_tabbar(nodes):
        # naive: count unique short labels for clickable elements near bottom
        max_y2 = 0
        for n in nodes:
            max_y2 = max(max_y2, n['bounds'][3])
        labels = set()
        for n in nodes:
            if not n['clickable']:
                continue
            x1, y1, x2, y2 = n['bounds']
            if max_y2 <= 0:
                continue
            if y2 >= max_y2 - 200 and (x2 - x1) > 40 and (y2 - y1) > 30:
                label = (n['text'] or n['desc']).strip().lower()
                label = re.sub(r"\s+", " ", label)
                if 0 < len(label) <= 16:
                    labels.add(label)
        return len(labels) >= 3

    steps_done = 0

    prefer_terms = [s.strip().lower() for s in args.prefer.split(',') if s.strip()]
    avoid_terms = [s.strip().lower() for s in args.avoid.split(',') if s.strip()]

    def explore(depth, parent_sig=None, parent_step=0):
        nonlocal steps_done
        if steps_done >= args.max_steps or depth > args.max_depth:
            return
        sig, xml_text, nodes = capture_signature()
        if sig not in nodes_db:
            save_state(sig, xml_text, steps_done)
        visited.add(sig)

        # Stop conditions
        if args.stop_when_text:
            t = args.stop_when_text.strip().lower()
            if t and any(t in (f"{n['text']} {n['desc']}").lower() for n in nodes):
                return
        if args.detect_tabbar_stop and detect_tabbar(nodes):
            return

        # Per-screen click limit
        per_screen_clicks.setdefault(sig, 0)
        if per_screen_clicks[sig] >= max(1, args.per_screen_limit):
            return

        # Auto-allow permission dialogs
        if args.auto_allow:
            allow_node = find_allow(nodes)
            if allow_node is not None and steps_done < args.max_steps:
                x, y = center(allow_node['bounds'])
                tap(args.device, x, y)
                time.sleep(0.8)
                sig2, xml2, _ = capture_signature()
                edges.append({'from': sig, 'to': sig2, 'action': 'auto:allow'})
                steps_done += 1
                if sig2 not in visited:
                    save_state(sig2, xml2, steps_done)
                    explore(depth + 1, parent_sig=sig, parent_step=steps_done)
                # return to try normal exploration from original screen
                for _ in range(3):
                    cur_sig, _, _ = capture_signature()
                    if cur_sig == sig:
                        break
                    go_back(args.device)
                    time.sleep(0.5)

        # choose top-k candidates with tuned scoring
        max_y2 = 0
        for n in nodes:
            max_y2 = max(max_y2, n['bounds'][3])
        cands = sorted(
            [n for n in nodes if n['clickable']],
            key=lambda n: score_node(n, prefer_terms=prefer_terms, avoid_terms=avoid_terms, bottom_bias_ref=max_y2),
            reverse=True
        )[:max(1, args.top_k)]
        if not cands:
            return
        for n in cands:
            if steps_done >= args.max_steps:
                break
            x, y = center(n['bounds'])
            action_label = (n['text'] or n['desc'] or n['id']).strip()[:60]
            tap(args.device, x, y)
            time.sleep(0.9)
            sig2, xml2, _ = capture_signature()
            edges.append({'from': sig, 'to': sig2, 'action': action_label})
            steps_done += 1
            per_screen_clicks[sig] += 1
            if sig2 not in visited:
                save_state(sig2, xml2, steps_done)
                explore(depth + 1, parent_sig=sig, parent_step=steps_done)
            # go back to previous state to try other actions
            for _ in range(3):
                if steps_done >= args.max_steps:
                    break
                cur_sig, _, _ = capture_signature()
                if cur_sig == sig:
                    break
                go_back(args.device)
                time.sleep(0.6)

    explore(1)

    # write flow.json
    out = {
        'nodes': list(nodes_db.values()),
        'edges': edges,
        'device': args.device,
        'package': args.pkg,
        'generated_at': int(time.time()),
    }
    with open(os.path.join(args.out, 'flow.json'), 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print(f"Saved {len(nodes_db)} nodes, {len(edges)} edges -> {args.out}")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"[error] {e}")
        sys.exit(1)
