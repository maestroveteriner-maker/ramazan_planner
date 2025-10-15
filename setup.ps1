Param(
  [string]$AppName = "ramazan_planner"
)
$ErrorActionPreference = "Stop"

if (Test-Path $AppName) {
  Write-Error "Folder '$AppName' already exists. Remove it or choose another directory."
}

# Check flutter
try {
  flutter --version | Out-Null
} catch {
  Write-Error "Flutter is not installed or not in PATH."
}

flutter create $AppName
Copy-Item -Recurse -Force "ramazan_planner\lib" "$AppName"
Copy-Item -Force "ramazan_planner\pubspec.yaml" "$AppName\pubspec.yaml"
Set-Location $AppName
flutter pub get
Write-Host "Setup complete. Now run: flutter run"
