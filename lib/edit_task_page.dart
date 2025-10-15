import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../main.dart';

class EditTaskPage extends StatefulWidget {
  final Task? task;
  const EditTaskPage({super.key, this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _category = TextEditingController();
  DateTime? _due;
  int _priority = 0;
  late final TaskStore store;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    store = TaskStore();
    store.load();
    final t = widget.task;
    if (t != null) {
      _title.text = t.title;
      _notes.text = t.notes ?? '';
      _category.text = t.category ?? '';
      _due = t.due;
      _priority = t.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Görevi Düzenle' : 'Yeni Görev'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
            tooltip: 'Kaydet',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notlar', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.event),
                    label: Text(_due == null
                        ? 'Tarih/Saat'
                        : DateFormat('dd MMM yyyy HH:mm').format(_due!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Öncelik', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Düşük')),
                      DropdownMenuItem(value: 1, child: Text('Orta')),
                      DropdownMenuItem(value: 2, child: Text('Yüksek')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _due ?? now,
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due ?? now),
    );
    setState(() {
      _due = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final t = widget.task;
    if (t == null) {
      await store.create(
        title: _title.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        due: _due,
        priority: _priority,
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      );
    } else {
      t.title = _title.text.trim();
      t.notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      t.due = _due;
      t.priority = _priority;
      t.category = _category.text.trim().isEmpty ? null : _category.text.trim();
      await store.update(t);
    }
    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
