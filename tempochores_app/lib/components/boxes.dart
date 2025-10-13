import 'package:hive/hive.dart';
import 'package:tempochores_app/models/chore.dart';
import 'package:tempochores_app/components/storage_init.dart';

class Boxes {
  static Box<Chore> chores() => Hive.box<Chore>(StorageInit.choreBoxName);
}
