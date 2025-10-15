#!/usr/bin/env bash
set -e
APP_NAME="ramazan_planner"
if [ -d "$APP_NAME" ]; then
  echo "Folder '$APP_NAME' already exists. Remove it or choose another directory."
  exit 1
fi
flutter --version >/dev/null 2>&1 || { echo "Flutter is not installed or not in PATH."; exit 1; }
flutter create $APP_NAME
cp -r ramazan_planner/lib "$APP_NAME/"
cp ramazan_planner/pubspec.yaml "$APP_NAME/"
cd "$APP_NAME"
flutter pub get
echo "Setup complete. Now run: flutter run"
