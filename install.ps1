# Aspiral MCP Universal Installer (Windows)
$ErrorActionPreference = "Stop"

$InstallDir = "$env:LOCALAPPDATA\Aspiral\bin"
$Repo = "DI-Solutions-Mx/aspiral-mcp"
$BaseUrl = if ($env:ASPIRAL_RELEASE_BASE_URL) { $env:ASPIRAL_RELEASE_BASE_URL } else { "https://github.com/$Repo/releases/latest/download" }
$BinaryName = "aspiral-mcp-win-x64.exe"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    Instalador Oficial Aspiral Monitoring MCP    " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if (-not (Test-Path -Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$TempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Write-Host "--> Descargando manifiesto de release..." -ForegroundColor Yellow
    $ManifestPath = Join-Path $TempDir "manifest.json"
    Invoke-WebRequest -Uri "$BaseUrl/manifest.json" -OutFile $ManifestPath -UseBasicParsing

    $Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    $Artifact = $Manifest.artifacts | Where-Object { $_.file -eq $BinaryName } | Select-Object -First 1
    if (-not $Artifact) {
        throw "No se encontró el artefacto $BinaryName en el manifiesto."
    }

    $ExpectedHash = [string]$Artifact.sha256
    $ExpectedHash = $ExpectedHash.Trim().ToLower()
    if ($ExpectedHash -notmatch '^[a-f0-9]{64}$') {
        throw "No se encontró un hash SHA-256 válido para $BinaryName en el manifiesto."
    }

    Write-Host "--> Descargando $BinaryName..." -ForegroundColor Yellow
    $TempBinary = Join-Path $TempDir $BinaryName
    Invoke-WebRequest -Uri "$BaseUrl/$BinaryName" -OutFile $TempBinary -UseBasicParsing

    Write-Host "--> Verificando integridad SHA-256..." -ForegroundColor Yellow
    $ActualHash = (Get-FileHash -Path $TempBinary -Algorithm SHA256).Hash.ToLower()

    if ($ActualHash -ne $ExpectedHash) {
        throw "La suma de verificación SHA-256 no coincide. Esperado: $ExpectedHash, Obtenido: $ActualHash"
    }

    $DestBinary = Join-Path $InstallDir "aspiral-mcp.exe"
    Move-Item -Path $TempBinary -Destination $DestBinary -Force

    Write-Host ""
    Write-Host "✓ Aspiral MCP instalado correctamente en: $DestBinary" -ForegroundColor Green
    Write-Host "✓ Configura en tu cliente MCP (Claude Desktop, Cursor, etc.):" -ForegroundColor Cyan
    Write-Host "    command: $DestBinary"
    Write-Host "    env:"
    Write-Host "      ASPIRAL_MCP_API_KEY=<tu_clave_asmcp>"
    Write-Host "      ASPIRAL_MCP_API_BASE_URL=https://monitoring.aspiral.com.mx"
    Write-Host "================================================" -ForegroundColor Cyan
}
finally {
    if (Test-Path -Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
