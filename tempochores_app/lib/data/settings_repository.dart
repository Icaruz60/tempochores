import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ✅ gives you .listenable()

class SettingsRepository {
  static const _boxName = 'settings';
  static const _selectedKey = 'selectedChores';

  Box get _box => Hive.box(_boxName);

  List<String> get selectedChores =>
      List<String>.from(_box.get(_selectedKey, defaultValue: []));

  Future<void> toggleChore(String id) async {
    final list = List<String>.from(selectedChores);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _box.put(_selectedKey, list);
  }

  Future<void> clearSelections() async => _box.put(_selectedKey, []);

  ValueListenable<Box> listen() => _box.listenable(); // ✅ works now
}
