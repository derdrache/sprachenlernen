import 'package:hive/hive.dart';

part 'leasson.model.g.dart';
//flutter packages pub run build_runner build

@HiveType(typeId: 1)
class Leasson extends HiveObject{
  @HiveField(0)
  String name;
  @HiveField(1)
  List<String> inhalt;
  @HiveField(2)
  String inhaltOriginal;
  @HiveField(3)
  List<String> inhaltChooseTranslate;
  @HiveField(4)
  List<String> inhaltTranslate;
  @HiveField(5)
  String audioName;
  @HiveField(6)
  String audioPath;
  @HiveField(7)
  String sprache;
  @HiveField(8)
  int loading;


  Leasson({
     this.name = "",  this.inhalt = const [],  this.inhaltOriginal= "",
     this.inhaltChooseTranslate = const [],  this.inhaltTranslate = const [],
     this.audioName = "", this.audioPath = "",  this.sprache = "",
     this.loading = 0
  });

}