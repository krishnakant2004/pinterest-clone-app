/// Domain entity for Board - pure Dart class without framework dependencies
class Board {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int pinCount;
  final bool isPrivate;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? collaboratorIds;

  const Board({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.pinCount = 0,
    this.isPrivate = false,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.collaboratorIds,
  });

  Board copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    int? pinCount,
    bool? isPrivate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? collaboratorIds,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      pinCount: pinCount ?? this.pinCount,
      isPrivate: isPrivate ?? this.isPrivate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Board && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
