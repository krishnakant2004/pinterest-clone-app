// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoardModelAdapter extends TypeAdapter<BoardModel> {
  @override
  final int typeId = 0;

  @override
  BoardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      coverImageUrl: fields[3] as String?,
      pinCount: fields[4] as int,
      isPrivate: fields[5] as bool,
      userId: fields[6] as String,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      collaboratorIds: (fields[9] as List?)?.cast<String>(),
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BoardModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.coverImageUrl)
      ..writeByte(4)
      ..write(obj.pinCount)
      ..writeByte(5)
      ..write(obj.isPrivate)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.collaboratorIds)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
