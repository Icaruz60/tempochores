import 'package:hive/hive.dart';
import 'priority.dart';

part 'chore.g.dart';

@HiveType(typeId: 1)
class Chore extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Priority priority;

  /// Each entry is total seconds for a recorded run.
  @HiveField(3)
  List<int> timesSeconds;

  Chore({
    required this.id,
    required this.name,
    this.priority = Priority.medium,
    List<int>? timesSeconds,
  }) : timesSeconds = timesSeconds ?? [];

  int get avgSeconds {
    if (timesSeconds.isEmpty) return 0;
    final sum = timesSeconds.fold<int>(0, (a, b) => a + b);
    return sum ~/ timesSeconds.length;
  }

  Duration get averageDuration => Duration(seconds: avgSeconds);

  void addTime(Duration d) {
    timesSeconds.add(d.inSeconds);
  }

  void removeTimeAt(int index) {
    timesSeconds.removeAt(index);
  }
}
