import 'package:hive/hive.dart';

part 'user_settings.model.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject{
  @HiveField(0)
  String eigeneSprache;

  UserSettings({required this.eigeneSprache});

}