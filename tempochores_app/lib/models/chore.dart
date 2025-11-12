import 'dart:collection';
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

  /// Each entry = total seconds for one completed run.
  @HiveField(3)
  final List<int> _timesSeconds;

  Chore({
    required this.id,
    required this.name,
    this.priority = Priority.medium,
    List<int>? timesSeconds,
  }) : _timesSeconds = timesSeconds ?? [];

  // Read-only Views 
  UnmodifiableListView<int> get timesSeconds =>
      UnmodifiableListView(_timesSeconds);

  int get runCount => _timesSeconds.length;
  bool get hasHistory => _timesSeconds.isNotEmpty;

  // Derived Metrics
  int get totalSeconds =>
      _timesSeconds.fold<int>(0, (sum, s) => sum + s);

  int get avgSeconds =>
      hasHistory ? totalSeconds ~/ runCount : 0;

  Duration get averageDuration => Duration(seconds: avgSeconds);
  Duration get totalDuration => Duration(seconds: totalSeconds);

  // Mutators 
  void addTime(Duration d) => _timesSeconds.add(d.inSeconds);

  void removeTimeAt(int index) {
    if (index >= 0 && index < _timesSeconds.length) {
      _timesSeconds.removeAt(index);
    }
  }

  void clearTimes() => _timesSeconds.clear();

  // Utility 
  @override
  String toString() =>
      'Chore(id: $id, name: $name, priority: $priority, runs: $runCount, avg: ${averageDuration.inSeconds}s)';
}
