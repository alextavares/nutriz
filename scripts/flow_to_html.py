#!/usr/bin/env python3
"""
Render a flow.json to a self-contained HTML (uses Viz.js CDN) that visualizes
the Graphviz DOT without requiring Graphviz installed.

Usage:
  python scripts/flow_to_html.py --in data/nutritracker_flow/flow.json --out data/nutritracker_flow/flow.html
"""
import argparse, json, re

def sanitize(s: str) -> str:
    s = s or ""
    s = s.replace("\n"," ").strip()
    s = re.sub(r"[\"<>]", "", s)
    return s[:60]

def to_dot(data):
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])
    lines = ['digraph flow {', '  rankdir=LR;', '  node [shape=rectangle, style=rounded, fontsize=10];']
    for n in nodes:
        nid = n['id']
        lines.append(f'  "{nid}" [label="{nid[:6]}"];')
    for e in edges:
        lbl = sanitize(e.get('action',''))
        lines.append(f'  "{e["from"]}" -> "{e["to"]}" [label="{lbl}"];')
    lines.append('}')
    return "\n".join(lines)

HTML_TMPL = """
<!doctype html>
<meta charset="utf-8" />
<title>Flow Graph</title>
<style>
  body { background:#111; color:#eee; font-family: system-ui, sans-serif; }
  #graph { text-align:center; margin: 24px; }
  .wrap { max-width: 1200px; margin: auto; }
  pre { background:#222; padding:12px; white-space:pre-wrap; }
  a { color:#9cf; }
  .meta { color:#bbb; font-size:12px; }
  svg { background:#1a1a1a; border-radius: 8px; }
}</style>
<div class="wrap">
  <h2>Flow Graph</h2>
  <div id="graph">Rendering…</div>
  <details>
    <summary>DOT source</summary>
    <pre id="dot"></pre>
  </details>
  <p class="meta">Rendered with Viz.js · Save this file and open in a browser.</p>
</div>
<script src="https://cdn.jsdelivr.net/npm/viz.js@2.1.2/viz.js"></script>
<script src="https://cdn.jsdelivr.net/npm/viz.js@2.1.2/full.render.js"></script>
<script>
const dot = `%DOT%`;
document.getElementById('dot').textContent = dot;
const viz = new Viz();
viz.renderSVGElement(dot).then(svg => {
  document.getElementById('graph').innerHTML='';
  document.getElementById('graph').appendChild(svg);
}).catch(err => {
  document.getElementById('graph').textContent = 'Error rendering graph: ' + err;
});
</script>
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--in', dest='inp', required=True)
    ap.add_argument('--out', dest='out', required=True)
    args = ap.parse_args()
    with open(args.inp,'r',encoding='utf-8') as f:
        data=json.load(f)
    dot = to_dot(data)
    html = HTML_TMPL.replace('%DOT%', dot.replace('`','\\`'))
    with open(args.out,'w',encoding='utf-8') as f:
        f.write(html)
    print('HTML written to', args.out)

if __name__=='__main__':
    main()

