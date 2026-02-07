import 'package:hive/hive.dart';

part 'board_model.g.dart';

@HiveType(typeId: 0)
class BoardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? coverImageUrl;

  @HiveField(4)
  final int pinCount;

  @HiveField(5)
  final bool isPrivate;

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final DateTime? createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  @HiveField(9)
  final List<String>? collaboratorIds;

  @HiveField(10)
  final bool isSynced;

  BoardModel({
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
    this.isSynced = false,
  });

  /// Create from JSON (Supabase response)
  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      pinCount: json['pin_count'] as int? ?? 0,
      isPrivate: json['is_private'] as bool? ?? false,
      userId: json['user_id'] as String,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      collaboratorIds: (json['collaborator_ids'] as List?)?.cast<String>(),
      isSynced: true,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'pin_count': pinCount,
      'is_private': isPrivate,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'collaborator_ids': collaboratorIds,
    };
  }

  BoardModel copyWith({
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
    bool? isSynced,
  }) {
    return BoardModel(
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
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
