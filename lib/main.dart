import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'models/task.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class TaskStore extends ChangeNotifier {
  static const _key = 'tasks_v1';
  final _uuid = const Uuid();
  List<Task> _items = [];
  bool _loaded = false;

  List<Task> get items => _items;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _items = Task.decodeList(raw);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Task.encodeList(_items).length.toString(), ''); // noop to ensure disk write
    await prefs.setString(_key, Task.encodeList(_items));
  }

  Future<void> add(Task t) async {
    _items.add(t);
    await save();
    notifyListeners();
  }

  Future<void> create({
    required String title,
    String? notes,
    DateTime? due,
    int priority = 0,
    String? category,
  }) async {
    final t = Task(id: _uuid.v4(), title: title, notes: notes, due: due, priority: priority, category: category);
    await add(t);
  }

  Future<void> update(Task t) async {
    final idx = _items.indexWhere((e) => e.id == t.id);
    if (idx != -1) {
      _items[idx] = t;
      await save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await save();
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx].done = !_items[idx].done;
      await save();
      notifyListeners();
    }
  }

  Future<String> exportJson() async {
    return Task.encodeList(_items);
  }

  Future<void> importJson(String json) async {
    _items = Task.decodeList(json);
    await save();
    notifyListeners();
  }
}
