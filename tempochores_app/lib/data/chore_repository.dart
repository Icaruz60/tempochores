import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/chore.dart';
import '../models/priority.dart';

class ChoreRepository {
  static const boxName = 'chores';
  final _uuid = const Uuid();

  Box<Chore> get _box => Hive.box<Chore>(boxName);

  List<Chore> getAll({bool sort = true}) {
    final list = _box.values.toList();
    if (sort) list.sort(_sortByPriorityThenName);
    return list;
  }

  Chore? getById(String id) => _box.get(id);

  Future<Chore> create(String name, {Priority priority = Priority.medium}) async {
    final chore = Chore(id: _uuid.v4(), name: name.trim(), priority: priority);
    await _box.put(chore.id, chore);
    return chore;
  }

  Future<void> upsert(Chore chore) async => _box.put(chore.id, chore);
  Future<void> delete(String id) async => _box.delete(id);

  Future<void> addTime(String id, Duration d) async {
    final c = _box.get(id);
    if (c == null) return;
    c.addTime(d);
    await _box.put(id, c);
  }

  Future<void> clearTimes(String id) async {
    final c = _box.get(id);
    if (c == null) return;
    c.timesSeconds.clear();
    await _box.put(id, c);
  }

  List<Chore> planChores(
  Duration availableTime, {
  String filter = 'Mixed Chores',
  List<Chore>? source, // optional list of chores to plan from
}) {
  var chores = source ?? getAll(sort: true);

  switch (filter) {
    case 'Longest Chores':
      chores.sort((a, b) => b.averageDuration.compareTo(a.averageDuration));
      break;
    case 'Shortest Chores':
      chores.sort((a, b) => a.averageDuration.compareTo(b.averageDuration));
      break;
    case 'Mixed Chores':
      chores.shuffle();
      break;
  }

  final planned = <Chore>[];
  var remaining = availableTime;

  for (final c in chores) {
    final dur = c.averageDuration;
    if (dur > Duration.zero && dur <= remaining) {
      planned.add(c);
      remaining -= dur;
    }
  }

  return planned;
}


  Stream<BoxEvent> watch() => _box.watch();

  int _priorityRank(Priority p) => switch (p) {
        Priority.high => 3,
        Priority.medium => 2,
        Priority.low => 1,
      };

  int _sortByPriorityThenName(Chore a, Chore b) {
    final pa = _priorityRank(a.priority);
    final pb = _priorityRank(b.priority);
    if (pa != pb) return pb.compareTo(pa);
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
