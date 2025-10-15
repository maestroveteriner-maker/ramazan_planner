import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dueText = task.due == null ? '' : DateFormat('dd MMM HH:mm').format(task.due!);
    final prio = ['•', '••', '•••'][task.priority.clamp(0, 2)];

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 24), child: const Icon(Icons.check, color: Colors.white)),
      secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), child: const Icon(Icons.delete, color: Colors.white)),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Silinsin mi?'),
              content: const Text('Bu görevi silmek istediğine emin misin?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
              ],
            ),
          );
          if (ok == true) onDelete();
          return ok == true;
        }
      },
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null),
        ),
        subtitle: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (task.category != null && task.category!.isNotEmpty)
              Chip(label: Text(task.category!), visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            if (dueText.isNotEmpty) Text('⏰ $dueText'),
            Text(prio, style: const TextStyle(letterSpacing: 1.5)),
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
      ),
    );
  }
}