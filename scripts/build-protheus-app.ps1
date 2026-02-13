param(
  [string]$AppName = "stock-contol-vue"
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$distDir = Join-Path $projectRoot "dist"
$resourceDir = Join-Path $projectRoot "Protheus\Resource"
$stagingDir = Join-Path $resourceDir $AppName
$zipPath = Join-Path $resourceDir "$AppName.zip"
$appPath = Join-Path $resourceDir "$AppName.app"

if (-not (Test-Path $distDir)) {
  throw "Build nao encontrado em '$distDir'. Execute 'npm run build' antes."
}

New-Item -ItemType Directory -Path $resourceDir -Force | Out-Null

if (Test-Path $stagingDir) {
  Remove-Item -Path $stagingDir -Recurse -Force
}

if (Test-Path $zipPath) {
  Remove-Item -Path $zipPath -Force
}

if (Test-Path $appPath) {
  Remove-Item -Path $appPath -Force
}

New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
Copy-Item -Path (Join-Path $distDir "*") -Destination $stagingDir -Recurse -Force

Compress-Archive -Path $stagingDir -DestinationPath $zipPath -Force
Move-Item -Path $zipPath -Destination $appPath -Force

Write-Host "APP gerado em: $appPath"
