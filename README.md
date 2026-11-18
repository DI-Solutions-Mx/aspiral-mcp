# Aspiral Monitoring MCP Server

[![Official Release](https://img.shields.io/github/v/release/DI-Solutions-Mx/aspiral-mcp?color=blue&label=release)](https://github.com/DI-Solutions-Mx/aspiral-mcp/releases)
[![Model Context Protocol](https://img.shields.io/badge/MCP-2024--11--05-blueviolet)](https://modelcontextprotocol.io)
[![License: Proprietary](https://img.shields.io/badge/license-Proprietary-red)](LICENSE)

Official, local, read-only [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server for **Aspiral Monitoring**. 

Enables AI assistants (Claude Desktop, Cursor, Gemini CLI, Windsurf) to securely inspect solar plant portfolios, financial ROI, CFE utility invoices, real-time telemetry, sync freshness, and generate executive 4-page editorial PDF reports.

---

## ⚡ 1-Prompt Quick Install

### macOS / Linux
Run in your terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/DI-Solutions-Mx/aspiral-mcp/main/install.sh | bash
```

### Windows (PowerShell)
Run in PowerShell:
```powershell
irm https://raw.githubusercontent.com/DI-Solutions-Mx/aspiral-mcp/main/install.ps1 | iex
```

The installer verifies SHA-256 integrity against the official release manifest and places the binary in `~/.aspiral/bin/aspiral-mcp` (or `%LOCALAPPDATA%\Aspiral\bin\aspiral-mcp.exe` on Windows).

---

## ⚙️ Client Configuration

Obtain an integration key (`asmcp_...`) from your Aspiral Monitoring settings dashboard.

### 1. Claude Desktop
Add to `claude_desktop_config.json`:
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "aspiral-monitoring": {
      "command": "/Users/<your-username>/.aspiral/bin/aspiral-mcp",
      "env": {
        "ASPIRAL_MCP_API_BASE_URL": "https://aspiral-monitoring.vercel.app",
        "ASPIRAL_MCP_API_KEY": "asmcp_your_api_key_here"
      }
    }
  }
}
```
*(On Windows, use `"command": "C:\\Users\\<your-username>\\AppData\\Local\\Aspiral\\bin\\aspiral-mcp.exe"`)*

### 2. Cursor
In Cursor Settings > Features > MCP Servers > Add New MCP Server:
- **Name:** `aspiral-monitoring`
- **Type:** `command`
- **Command:** `~/.aspiral/bin/aspiral-mcp`
- **Environment Variables:**
  - `ASPIRAL_MCP_API_BASE_URL`: `https://aspiral-monitoring.vercel.app`
  - `ASPIRAL_MCP_API_KEY`: `asmcp_your_api_key_here`

---

## 🛠️ Tool Catalog (16 Native Tools)

| Category | Tool | Description |
| :--- | :--- | :--- |
| **Portfolio** | `list_sites` | Lists all authorized solar installations for the integration key. |
| | `get_portfolio_overview` | Multi-site aggregated capacity (kWp), monthly generation, online/offline plants, and CO2 avoided. |
| **Financial & ROI** | `get_site_financial_savings` | Net monetary savings ($ MXN), simulated vs real CFE tariff, self-consumption %, and grid injection. |
| | `get_site_cfe_invoices` | Official CFE utility bills, base/intermediate/peak energy breakdown, demand charges, power factor penalty/bonus, and PDF download links. |
| **Goals & Targets** | `get_site_goals_tracking` | Annual & monthly production targets vs actual delivered kWh, deviation, and performance status (`exceeding`, `on_track`, `minor_deviation`, `critical_underproduction`). |
| | `get_site_energy_comparison` | Server-calculated expected vs actual generation, energy balance, and data provenance. |
| **Telemetry & Health** | `get_site_telemetry_history` | Granular daily time-series generation, solar irradiance (HSP), specific yield (kWh/kWp), and active devices. |
| | `get_sync_and_data_health` | Real-time ingestion latency, data freshness (`fresh`, `delayed`, `stale_frozen`), device connectivity breakdown, and pipeline diagnostic messages. |
| **Devices & Alerts** | `list_site_devices` | Inverters, sensors, and meters belonging to a site with safe operational status. |
| | `get_device_status` | Device connectivity, firmware, vendor/make, and last-seen timestamps. |
| | `list_site_alerts` | Persisted site operational alerts and warnings. |
| | `list_device_alerts` | Device-specific active or historical alerts. |
| **Reporting & PDF** | `get_monthly_report_data` | Structured JSON package for a specific calendar month. |
| | `get_annual_report_data` | Structured JSON package for a specific calendar year. |
| | `generate_monthly_report_pdf` | Generates a 4-page executive editorial PDF report with high-fidelity charts in the local output directory. |
| | `generate_annual_report_pdf` | Generates an annual executive PDF report. |

---

## 🔒 Security Architecture
- **Read-Only by Design:** The MCP server strictly issues read-only queries (`GET`). No mutations, deletions, or device write controls are exposed.
- **Data Safety:** All returned payloads are strictly delimited as data, preventing prompt injection attacks.
- **Zero-Trust Network Access:** Internal IP addresses, Modbus register maps, passwords, and raw cloud credentials are never transmitted to LLM clients.
- **Tenant Isolation:** Enforced via company-scoped API keys with constant-time verification.

---

## 📄 License
© 2026 DI Solutions Mx. All rights reserved. Proprietary software for Aspiral Monitoring clients and authorized partners.
