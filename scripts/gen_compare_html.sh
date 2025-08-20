#!/usr/bin/env bash
set -euo pipefail
SCREEN="${1:-home}"; OUT_DIR="docs/compare"; SRC_DIR="pr_captures/${SCREEN}"
mkdir -p "$OUT_DIR"

gen_screen() {
  local s="$1" out="${OUT_DIR}/${s}.html"
  cat > "$out" <<HTML
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"/>
<title>Comparação — ${s}</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:#111;color:#eee;margin:0;padding:20px}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.card{background:#1b1b1b;border-radius:10px;padding:12px}
.title{margin:0 0 8px 0;font-weight:600}
img{width:100%;height:auto;border-radius:8px;background:#000}
.meta{color:#aaa;font-size:12px;margin-top:6px}
</style></head><body>
<h1>${s^}: YAZIO (ref) vs NutriTracker</h1>
<div class="grid">
  <div class="card"><p class="title">YAZIO — Dark</p><img src="../../${SRC_DIR}/yazio_${s}_dark.png"/><div class="meta">${SRC_DIR}/yazio_${s}_dark.png</div></div>
  <div class="card"><p class="title">NutriTracker — Dark</p><img src="../../${SRC_DIR}/nutri_${s}_dark.png"/><div class="meta">${SRC_DIR}/nutri_${s}_dark.png</div></div>
  <div class="card"><p class="title">YAZIO — Light</p><img src="../../${SRC_DIR}/yazio_${s}_light.png"/><div class="meta">${SRC_DIR}/yazio_${s}_light.png</div></div>
  <div class="card"><p class="title">NutriTracker — Light</p><img src="../../${SRC_DIR}/nutri_${s}_light.png"/><div class="meta">${SRC_DIR}/nutri_${s}_light.png</div></div>
</div></body></html>
HTML
  echo "$out"
}

gen_index() {
  cat > "${OUT_DIR}/index.html" <<HTML
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"/>
<title>Comparações — Índice</title>
<style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;margin:16px}ul{line-height:1.9}</style></head>
<body><h1>Comparações — YAZIO vs NutriTracker</h1><ul>
<li><a href="./home.html">Home/Diário</a></li>
<li><a href="./search.html">Busca/Logging</a> (placeholder)</li>
<li><a href="./progress.html">Progresso/Analytics</a> (placeholder)</li>
<li><a href="./profile.html">Perfil/Metas</a> (placeholder)</li>
</ul></body></html>
HTML
}

# Generate current screen and placeholders for others if missing
gen_screen "$SCREEN" >/dev/null
for s in search progress profile; do
  [[ -f "${OUT_DIR}/${s}.html" ]] || gen_screen "$s" >/dev/null
done

gen_index
