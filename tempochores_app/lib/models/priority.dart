import 'package:hive/hive.dart';

part 'priority.g.dart';

@HiveType(typeId: 2)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}
