# VadaPav — build + serve the playground on port 7777
$port = 7777

# Build first
& "$PSScriptRoot\run.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

# Kill anything on our port
$conn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($conn) {
  $conn | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
  Start-Sleep -Milliseconds 500
}

$outDir = Get-ChildItem -Path ".koka" -Directory -Recurse | Where-Object { $_.Name -match "^js-" } | Select-Object -First 1
$url = "http://localhost:$port/editor.html"
Write-Host "`n$url" -ForegroundColor Green
Start-Process $url
npx http-server $($outDir.FullName) -p $port -c-1
