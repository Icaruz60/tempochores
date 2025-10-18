import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/chore.dart';
import '../models/priority.dart';

class ChoreRepository {
  static const boxName = 'chores';
  final _uuid = const Uuid();

  Box<Chore> get _box => Hive.box<Chore>(boxName);

  List<Chore> getAll({bool sortByPriorityThenName = true}) {
    final list = _box.values.toList();
    if (sortByPriorityThenName) {
      list.sort((a, b) {
        // high > medium > low
        int pA = _priorityRank(a.priority);
        int pB = _priorityRank(b.priority);
        if (pA != pB) return pB.compareTo(pA);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    return list;
  }

  int _priorityRank(Priority p) {
    switch (p) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }

  Chore? getById(String id) => _box.get(id);

  Future<Chore> create({
    required String name,
    Priority priority = Priority.medium,
  }) async {
    final chore = Chore(id: _uuid.v4(), name: name.trim(), priority: priority);
    await _box.put(chore.id, chore);
    return chore;
  }

  Future<void> save(Chore chore) async => _box.put(chore.id, chore);

  Future<void> delete(String id) async => _box.delete(id);

  Future<void> addTime(String id, Duration d) async {
    final c = _box.get(id);
    if (c == null) return;
    c.addTime(d);
    await c.save();
  }

  Future<void> clearTimes(String id) async {
    final c = _box.get(id);
    if (c == null) return;
    c.timesSeconds.clear();
    await c.save();
  }

  Stream<BoxEvent> watch() => _box.watch();

  List<Chore> getPrioritizedChores(Duration availableTime) {
    final all = getAll(sortByPriorityThenName: true);
    final selected = <Chore>[];
    var remaining = availableTime;

    // Go through each priority in order
    for (final priority in [Priority.high, Priority.medium, Priority.low]) {
      final samePriority = all.where((c) => c.priority == priority);

      for (final chore in samePriority) {
        final avg = chore.averageDuration;
        if (avg <= remaining) {
          selected.add(chore);
          remaining -= avg;
        }
      }
    }
    return selected;
  }
}
