import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool done;
  @HiveField(3)
  DateTime? remindAt;
  @HiveField(4)
  int? notificationId;

  Task({
    required this.id,
    required this.title,
    this.done = false,
    this.remindAt,
    this.notificationId,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      done: fields[2] as bool,
      remindAt: fields[3] as DateTime?,
      notificationId: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.done)
      ..writeByte(3)
      ..write(obj.remindAt)
      ..writeByte(4)
      ..write(obj.notificationId);
  }
}
