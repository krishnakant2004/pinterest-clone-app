/// Domain entity for Like - pure Dart class without framework dependencies
class Like {
  final String id;
  final String pinId;
  final String userId;
  final DateTime? createdAt;

  const Like({
    required this.id,
    required this.pinId,
    required this.userId,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Like &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pinId == other.pinId &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ pinId.hashCode ^ userId.hashCode;
}
