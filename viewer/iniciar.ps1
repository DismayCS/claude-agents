$ErrorActionPreference = "Stop"
$port = 8743
$dir = $PSScriptRoot

Write-Host "Servindo o viewer em http://localhost:$port (Ctrl+C para parar)"
Start-Process "http://localhost:$port/agents-viewer.html"
Set-Location $dir
python -m http.server $port
