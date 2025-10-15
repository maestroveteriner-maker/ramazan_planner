import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../main.dart';
import 'edit_task_page.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskStore store;
  int _tabIndex = 0;
  String _query = '';
  bool _sortByDue = true;

  @override
  void initState() {
    super.initState();
    store = TaskStore();
    store.addListener(_onStore);
    store.load();
  }

  @override
  void dispose() {
    store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<Task> tasks = store.items;

    // Filtering by tab
    if (_tabIndex == 0) {
      tasks = tasks.where((t) => t.due != null && DateUtils.isSameDay(t.due, now)).toList();
    } else if (_tabIndex == 1) {
      tasks = tasks.where((t) => t.due != null && t.due!.isAfter(DateTime(now.year, now.month, now.day).add(const Duration(days: 0)))).toList();
    }

    // Search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      tasks = tasks.where((t) =>
          t.title.toLowerCase().contains(q) ||
          (t.notes ?? '').toLowerCase().contains(q) ||
          (t.category ?? '').toLowerCase().contains(q)).toList();
    }

    // Sort
    tasks.sort((a, b) {
      if (_sortByDue) {
        final ad = a.due?.millisecondsSinceEpoch ?? 1 << 62;
        final bd = b.due?.millisecondsSinceEpoch ?? 1 << 62;
        final cmp = ad.compareTo(bd);
        if (cmp != 0) return cmp;
      }
      return b.priority.compareTo(a.priority);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        actions: [
          IconButton(
            tooltip: 'Export JSON',
            onPressed: () async {
              final data = await store.exportJson();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Export'),
                  content: SingleChildScrollView(child: SelectableText(data)),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            },
            icon: const Icon(Icons.file_upload_outlined),
          ),
          IconButton(
            tooltip: 'Import JSON',
            onPressed: () async {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Import JSON'),
                  content: TextField(
                    controller: controller,
                    maxLines: 10,
                    decoration: const InputDecoration(hintText: 'Paste your JSON here'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () async {
                        await store.importJson(controller.text);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: const Text('Import'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                isDense: true,
                suffixIcon: IconButton(
                  tooltip: _sortByDue ? 'Tarihe göre' : 'Önceliğe göre',
                  onPressed: () => setState(() => _sortByDue = !_sortByDue),
                  icon: const Icon(Icons.sort),
                ),
              ),
            ),
          ),
        ),
      ),
      body: !store.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text('Henüz görev yok. + ile ekle.'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final t = tasks[i];
                    return TaskTile(
                      task: t,
                      onToggle: () => store.toggle(t.id),
                      onDelete: () => store.remove(t.id),
                      onEdit: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskPage(task: t)));
                        setState(() {});
                      },
                    );
                  },
                ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Bugün'),
          NavigationDestination(icon: Icon(Icons.upcoming_outlined), selectedIcon: Icon(Icons.upcoming), label: 'Yaklaşan'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Tümü'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditTaskPage()));
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Görev'),
      ),
    );
  }
}
