// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_pin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedPinModelAdapter extends TypeAdapter<SavedPinModel> {
  @override
  final int typeId = 1;

  @override
  SavedPinModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedPinModel(
      id: fields[0] as String,
      pinId: fields[1] as String,
      boardId: fields[2] as String,
      userId: fields[3] as String,
      imageUrl: fields[4] as String,
      thumbnailUrl: fields[5] as String?,
      title: fields[6] as String?,
      description: fields[7] as String?,
      link: fields[8] as String?,
      width: fields[9] as int,
      height: fields[10] as int,
      photographer: fields[11] as String?,
      avgColor: fields[12] as String?,
      savedAt: fields[13] as DateTime?,
      isSynced: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SavedPinModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pinId)
      ..writeByte(2)
      ..write(obj.boardId)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.thumbnailUrl)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.link)
      ..writeByte(9)
      ..write(obj.width)
      ..writeByte(10)
      ..write(obj.height)
      ..writeByte(11)
      ..write(obj.photographer)
      ..writeByte(12)
      ..write(obj.avgColor)
      ..writeByte(13)
      ..write(obj.savedAt)
      ..writeByte(14)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPinModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
