# Ramazan Planner

Minimal, offline **planner** app you can run and customize. Built with Flutter.

## Quick Start

1. Unzip the project.
2. Open the folder in VS Code or Android Studio.
3. Make sure you have Flutter installed. (Flutter 3.22+ recommended)
4. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## What it does

- Tasks with title, notes, due date/time, category, and priority (0–2).
- Views: Today, Upcoming, All.
- Local persistence using `shared_preferences` (no backend).
- Search, sort, bulk-complete, and JSON export/import.

## Folder layout

```
lib/
  models/task.dart
  pages/home_page.dart
  pages/edit_task_page.dart
  widgets/task_tile.dart
  main.dart
```

## License

You may use it commercially. No attribution required.
© 2025 Ramazan Öcal
---

## Tek komutla kurulum

**macOS/Linux:**
```bash
unzip ramazan_planner.zip
cd /path/to/download
bash ramazan_planner/setup.sh
cd ramazan_planner
flutter run
```

**Windows (PowerShell):**
```powershell
Expand-Archive -Path .\ramazan_planner.zip -DestinationPath .
Set-Location .\
powershell -ExecutionPolicy Bypass -File .\ramazan_planner\setup.ps1
Set-Location .\ramazan_planner
flutter run
```
