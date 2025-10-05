#!/usr/bin/env python3
"""
Convert a flow.json (from yazio_flowmap.py) to Graphviz DOT and optionally PNG.

Usage:
  python scripts/flow_to_dot.py --in data/yazio_flow_bfs/flow.json --out data/yazio_flow_bfs/flow

It will write:
  - <out>.dot
  - <out>.png (if Graphviz `dot` command is available)
"""
import argparse
import json
import os
import re
import subprocess


def has_dot():
    try:
        subprocess.run(["dot", "-V"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        return True
    except FileNotFoundError:
        return False


def sanitize(s: str) -> str:
    s = s or ""
    s = s.replace("\n", " ").strip()
    return re.sub(r"[\"<>]", "", s)[:40]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--in', dest='inp', required=True)
    ap.add_argument('--out', dest='out', required=True)
    args = ap.parse_args()

    with open(args.inp, 'r', encoding='utf-8') as f:
        data = json.load(f)

    nodes = data.get('nodes', [])
    edges = data.get('edges', [])

    node_ids = [n['id'] for n in nodes]
    dot_lines = [
        'digraph flow {',
        '  rankdir=LR;',
        '  node [shape=rectangle, style=rounded, fontsize=10];'
    ]

    for n in nodes:
        nid = n['id']
        label = f"{nid[:6]}"  # concise label
        dot_lines.append(f'  "{nid}" [label="{label}"];')

    for e in edges:
        a = sanitize(e.get('action', ''))
        dot_lines.append(f'  "{e["from"]}" -> "{e["to"]}" [label="{a}"];')

    dot_lines.append('}')
    dot_text = "\n".join(dot_lines)

    out_dot = args.out + '.dot'
    with open(out_dot, 'w', encoding='utf-8') as f:
        f.write(dot_text)
    print('DOT written to', out_dot)

    if has_dot():
        out_png = args.out + '.png'
        subprocess.run(["dot", "-Tpng", out_dot, "-o", out_png], check=False)
        if os.path.exists(out_png):
            print('PNG written to', out_png)
        else:
            print('Graphviz dot present but PNG not created')
    else:
        print('Graphviz `dot` not found; install graphviz to render PNG.')


if __name__ == '__main__':
    main()

