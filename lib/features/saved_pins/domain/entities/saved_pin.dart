/// Domain entity for SavedPin - pure Dart class without framework dependencies
class SavedPin {
  final String id;
  final String pinId;
  final String boardId;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final String? link;
  final int width;
  final int height;
  final String? photographer;
  final String? avgColor;
  final DateTime? savedAt;

  const SavedPin({
    required this.id,
    required this.pinId,
    required this.boardId,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.title,
    this.description,
    this.link,
    required this.width,
    required this.height,
    this.photographer,
    this.avgColor,
    this.savedAt,
  });

  double get aspectRatio => width / height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPin && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
