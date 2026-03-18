# VadaPav — compile to JS + run tests
# Run from: ~/projects/vada-pav-lang/

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "`n=== Compile to JS ===" -ForegroundColor Cyan
koka --target=js vadapav.kk
if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Compiled OK" -ForegroundColor Green

# Find the output directory
$outDir = Get-ChildItem -Path ".koka" -Directory -Recurse |
    Where-Object { $_.Name -match "^js-" } |
    Select-Object -First 1

if (-not $outDir) {
    Write-Host "Cannot find JS output directory!" -ForegroundColor Red
    exit 1
}
Write-Host "Output: $($outDir.FullName)" -ForegroundColor DarkGray

# Copy test + editor into the output directory
Copy-Item -Path "test.mjs" -Destination $outDir.FullName -Force
Copy-Item -Path "editor.html" -Destination $outDir.FullName -Force

Write-Host "`n=== Run Tests ===" -ForegroundColor Cyan
node "$($outDir.FullName)\test.mjs"
