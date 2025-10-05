#!/usr/bin/env python3
"""
Compare two flow.json artifacts (from yazio_flowmap.py) and produce a small
HTML report with basic metrics and action label overlaps.

Usage:
  python scripts/compare_flows.py --a data/yazio_flow/flow.json \
                                  --b data/nutritracker_flow/flow.json \
                                  --out data/flow_compare/report.html
"""
import argparse, json, re, os
from collections import Counter

def clean_label(s: str) -> str:
    s = (s or '').strip().lower()
    s = re.sub(r"\s+", " ", s)
    return s[:100]

def load_flow(path: str):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])
    labels = [clean_label(e.get('action','')) for e in edges if e.get('action')]
    return {
        'nodes': nodes,
        'edges': edges,
        'labels': [l for l in labels if l]
    }

HTML = """
<!doctype html>
<meta charset="utf-8" />
<title>Flow Comparison</title>
<style>
 body { background:#111; color:#eee; font-family: system-ui, sans-serif; }
 h2 { margin: 12px 0; }
 .wrap { max-width: 1100px; margin: 24px auto; }
 .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
 .card { background:#1a1a1a; padding: 12px 16px; border-radius: 8px; }
 table { width: 100%; border-collapse: collapse; }
 th, td { text-align: left; padding: 6px 8px; border-bottom: 1px solid #333; }
 small { color:#aaa; }
 code { background:#222; padding:2px 4px; border-radius:4px; }
 a { color:#9cf; }
 ul { margin:6px 0 0 18px; }
</style>
<div class="wrap">
  <h2>Flow Comparison</h2>
  <div class="grid">
    <div class="card">
      <h3>A</h3>
      <p><small>%A_PATH%</small></p>
      <p>Nodes: <b>%A_N%</b> · Edges: <b>%A_E%</b></p>
      <h4>Top Actions</h4>
      <table>
        <tr><th>Label</th><th>Count</th></tr>
        %A_TOP%
      </table>
    </div>
    <div class="card">
      <h3>B</h3>
      <p><small>%B_PATH%</small></p>
      <p>Nodes: <b>%B_N%</b> · Edges: <b>%B_E%</b></p>
      <h4>Top Actions</h4>
      <table>
        <tr><th>Label</th><th>Count</th></tr>
        %B_TOP%
      </table>
    </div>
  </div>
  <div class="grid" style="margin-top:16px;">
    <div class="card">
      <h3>Overlap</h3>
      <p>Common action labels (<b>%OVER_N%</b>):</p>
      <ul>%OVER%</ul>
    </div>
    <div class="card">
      <h3>Unique</h3>
      <div class="grid">
        <div>
          <h4>Only in A</h4>
          <ul>%ONLY_A%</ul>
        </div>
        <div>
          <h4>Only in B</h4>
          <ul>%ONLY_B%</ul>
        </div>
      </div>
    </div>
  </div>
</div>
"""

def render_top(counter: Counter, k=15):
    rows = []
    for label, count in counter.most_common(k):
        safe = label.replace('<','').replace('>','')
        rows.append(f"<tr><td>{safe}</td><td>{count}</td></tr>")
    return '\n'.join(rows)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--a', required=True)
    ap.add_argument('--b', required=True)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    A = load_flow(args.a)
    B = load_flow(args.b)
    ca = Counter(A['labels'])
    cb = Counter(B['labels'])
    set_a = set(ca.keys())
    set_b = set(cb.keys())
    overlap = sorted(list(set_a & set_b))
    only_a = sorted(list(set_a - set_b))
    only_b = sorted(list(set_b - set_a))

    html = (HTML
      .replace('%A_PATH%', args.a)
      .replace('%B_PATH%', args.b)
      .replace('%A_N%', str(len(A['nodes'])))
      .replace('%A_E%', str(len(A['edges'])))
      .replace('%B_N%', str(len(B['nodes'])))
      .replace('%B_E%', str(len(B['edges'])))
      .replace('%A_TOP%', render_top(ca))
      .replace('%B_TOP%', render_top(cb))
      .replace('%OVER_N%', str(len(overlap)))
      .replace('%OVER%', '\n'.join(f'<li>{l}</li>' for l in overlap[:50]))
      .replace('%ONLY_A%', '\n'.join(f'<li>{l}</li>' for l in only_a[:50]))
      .replace('%ONLY_B%', '\n'.join(f'<li>{l}</li>' for l in only_b[:50]))
    )

    os.makedirs(os.path.dirname(args.out) or '.', exist_ok=True)
    with open(args.out, 'w', encoding='utf-8') as f:
        f.write(html)
    print('Report written to', args.out)

if __name__ == '__main__':
    main()

