// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leasson.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeassonAdapter extends TypeAdapter<Leasson> {
  @override
  final int typeId = 1;

  @override
  Leasson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leasson(
      name: fields[0] as String,
      inhalt: (fields[1] as List).cast<String>(),
      inhaltOriginal: fields[2] as String,
      inhaltChooseTranslate: (fields[3] as List).cast<String>(),
      inhaltTranslate: (fields[4] as List).cast<String>(),
      audioName: fields[5] as String,
      audioPath: fields[6] as String,
      sprache: fields[7] as String,
      loading: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Leasson obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.inhalt)
      ..writeByte(2)
      ..write(obj.inhaltOriginal)
      ..writeByte(3)
      ..write(obj.inhaltChooseTranslate)
      ..writeByte(4)
      ..write(obj.inhaltTranslate)
      ..writeByte(5)
      ..write(obj.audioName)
      ..writeByte(6)
      ..write(obj.audioPath)
      ..writeByte(7)
      ..write(obj.sprache)
      ..writeByte(8)
      ..write(obj.loading);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeassonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
