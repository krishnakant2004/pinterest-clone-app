// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikeModelAdapter extends TypeAdapter<LikeModel> {
  @override
  final int typeId = 2;

  @override
  LikeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LikeModel(
      id: fields[0] as String,
      pinId: fields[1] as String,
      userId: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      isSynced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LikeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pinId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
