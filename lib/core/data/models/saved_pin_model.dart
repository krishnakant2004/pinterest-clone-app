import 'package:hive/hive.dart';

part 'saved_pin_model.g.dart';

@HiveType(typeId: 1)
class SavedPinModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pinId;

  @HiveField(2)
  final String boardId;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String? thumbnailUrl;

  @HiveField(6)
  final String? title;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final String? link;

  @HiveField(9)
  final int width;

  @HiveField(10)
  final int height;

  @HiveField(11)
  final String? photographer;

  @HiveField(12)
  final String? avgColor;

  @HiveField(13)
  final DateTime? savedAt;

  @HiveField(14)
  final bool isSynced;

  SavedPinModel({
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
    this.isSynced = false,
  });

  /// Create from JSON (Supabase response)
  factory SavedPinModel.fromJson(Map<String, dynamic> json) {
    return SavedPinModel(
      id: json['id'] as String,
      pinId: json['pin_id'] as String,
      boardId: json['board_id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      width: json['width'] as int,
      height: json['height'] as int,
      photographer: json['photographer'] as String?,
      avgColor: json['avg_color'] as String?,
      savedAt:
          json['saved_at'] != null
              ? DateTime.parse(json['saved_at'] as String)
              : null,
      isSynced: true,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pin_id': pinId,
      'board_id': boardId,
      'user_id': userId,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'description': description,
      'link': link,
      'width': width,
      'height': height,
      'photographer': photographer,
      'avg_color': avgColor,
      'saved_at': savedAt?.toIso8601String(),
    };
  }

  double get aspectRatio => width / height;

  SavedPinModel copyWith({
    String? id,
    String? pinId,
    String? boardId,
    String? userId,
    String? imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? link,
    int? width,
    int? height,
    String? photographer,
    String? avgColor,
    DateTime? savedAt,
    bool? isSynced,
  }) {
    return SavedPinModel(
      id: id ?? this.id,
      pinId: pinId ?? this.pinId,
      boardId: boardId ?? this.boardId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      width: width ?? this.width,
      height: height ?? this.height,
      photographer: photographer ?? this.photographer,
      avgColor: avgColor ?? this.avgColor,
      savedAt: savedAt ?? this.savedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
