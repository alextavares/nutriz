MCP Android helpers

Tools in this folder are tiny PowerShell wrappers over adb so an MCP "shell" server can call them easily and get predictable outputs.

Prereqs
- Android Platform-Tools in PATH (adb) or set env var ADB_PATH
- A running emulator (e.g., emulator-5556, emulator-5558)

Scripts
- screencap.ps1: prints base64 PNG of current screen
  Usage: pwsh -File scripts/mcp-android/screencap.ps1 -Serial emulator-5556

- tap.ps1: taps at screen coordinates
  Usage: pwsh -File scripts/mcp-android/tap.ps1 -Serial emulator-5556 -X 500 -Y 1200

- dump_ui.ps1: dumps current UI hierarchy (XML) to stdout
  Usage: pwsh -File scripts/mcp-android/dump_ui.ps1 -Serial emulator-5556

- type_text.ps1: types text into focused field
  Usage: pwsh -File scripts/mcp-android/type_text.ps1 -Serial emulator-5556 -Text "Oi mundo"

MCP config (config.toml)
Place this in %APPDATA%\mcp\config.toml (Windows) or ~/.config/mcp/config.toml:

[servers.adb_shell]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-shell"]
environment = { ADB_SERIAL = "emulator-5556", ADB_PATH = "C:\\Android\\platform-tools\\adb.exe" }

# Example calls from the MCP client (tools.shell/exec):
# pwsh -NoLogo -NoProfile -File scripts/mcp-android/screencap.ps1
# pwsh -NoLogo -NoProfile -File scripts/mcp-android/tap.ps1 -X 420 -Y 960
# pwsh -NoLogo -NoProfile -File scripts/mcp-android/type_text.ps1 -Text "teste"
# pwsh -NoLogo -NoProfile -File scripts/mcp-android/dump_ui.ps1

