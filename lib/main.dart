import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TaskHomePage(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final DateTime? due;
  final bool done;

  Task({
    required this.id,
    required this.title,
    this.due,
    this.done = false,
  });

  Task copyWith({String? title, DateTime? due, bool? done}) {
    return Task(
      id: id,
      title: title ?? this.title,
      due: due ?? this.due,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'due': due?.toIso8601String(),
        'done': done,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        due: map['due'] != null ? DateTime.parse(map['due'] as String) : null,
        done: map['done'] as bool? ?? false,
      );
}

class TaskStore {
  static const _key = 'tasks_v1';

  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final list = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromMap).toList();
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((t) => t.toMap()).toList();
    await prefs.setString(_key, json.encode(list));
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final _store = TaskStore();
  List<Task> _tasks = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _store.load();
    setState(() {
      _tasks = list;
      _loading = false;
    });
  }

  Future<void> _addTask() async {
    final result = await showDialog<_NewTaskResult>(
      context: context,
      builder: (_) => const _NewTaskDialog(),
    );
    if (result == null) return;
    final t = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: result.title,
      due: result.due,
    );
    setState(() => _tasks = [..._tasks, t]);
    await _store.save(_tasks);
  }

  Future<void> _toggleDone(Task t) async {
    final updated = t.copyWith(done: !t.done);
    setState(() {
      _tasks = _tasks.map((e) => e.id == t.id ? updated : e).toList();
    });
    await _store.save(_tasks);
  }

  Future<void> _delete(Task t) async {
    setState(() {
      _tasks = _tasks.where((e) => e.id != t.id).toList();
    });
    await _store.save(_tasks);
  }

  List<Task> get _filtered {
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? _tasks
        : _tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    list.sort((a, b) {
      // Önce tamamlanmamışlar, sonra tarihe göre
      if (a.done != b.done) return a.done ? 1 : -1;
      final ad = a.due?.millisecondsSinceEpoch ?? 1 << 62;
      final bd = b.due?.millisecondsSinceEpoch ?? 1 << 62;
      return ad.compareTo(bd);
    });
    return list;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        actions: [
          IconButton(
            tooltip: 'Yeni görev',
            onPressed: _addTask,
            icon: const Icon(Icons.add_task),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Görev ara…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? const _EmptyView()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final t = _filtered[i];
                    return Dismissible(
                      key: ValueKey(t.id),
                      background: Container(
                        color: Colors.red.withOpacity(0.85),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _delete(t),
                      child: ListTile(
                        leading: Checkbox(
                          value: t.done,
                          onChanged: (_) => _toggleDone(t),
                        ),
                        title: Text(
                          t.title,
                          style: t.done
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        subtitle: t.due == null
                            ? null
                            : Text(
                                'Son tarih: ${_fmtDate(t.due!)}',
                              ),
                        trailing: IconButton(
                          tooltip: 'Sil',
                          icon: const Icon(Icons.close),
                          onPressed: () => _delete(t),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        label: const Text('Görev ekle'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_note, size: 72),
            SizedBox(height: 16),
            Text(
              'Henüz görev yok',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Sağ alttan “Görev ekle” ile başlayabilirsin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTaskResult {
  final String title;
  final DateTime? due;
  _NewTaskResult(this.title, this.due);
}

class _NewTaskDialog extends StatefulWidget {
  const _NewTaskDialog();

  @override
  State<_NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<_NewTaskDialog> {
  final _controller = TextEditingController();
  DateTime? _due;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni görev'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Görev başlığı',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(_due == null
                    ? 'Son tarih (opsiyonel)'
                    : 'Son tarih: ${_fmtDate(_due!)}'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) setState(() => _due = picked);
                },
                icon: const Icon(Icons.event),
                label: const Text('Tarih seç'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(context, _NewTaskResult(title, _due));
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
