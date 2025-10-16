import 'package:flutter/material.dart';
import '../data/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planner')),
      body: _tasks.isEmpty
          ? const Center(child: Text('Henüz görev yok'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final t = _tasks[index];
                return ListTile(
                  title: Text(t.title),
                  leading: Checkbox(
                    value: t.done,
                    onChanged: (v) => setState(() => t.done = v ?? false),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _tasks.add(Task(id: DateTime.now().toString(), title: 'Yeni görev'));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
