import 'package:hive/hive.dart';

part 'like_model.g.dart';

@HiveType(typeId: 2)
class LikeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pinId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final DateTime? createdAt;

  @HiveField(4)
  final bool isSynced;

  LikeModel({
    required this.id,
    required this.pinId,
    required this.userId,
    this.createdAt,
    this.isSynced = false,
  });

  /// Create from JSON (Supabase response)
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String? ?? '${json['user_id']}_${json['pin_id']}',
      pinId: json['pin_id'] as String,
      userId: json['user_id'] as String,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      isSynced: true,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'pin_id': pinId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  LikeModel copyWith({
    String? id,
    String? pinId,
    String? userId,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return LikeModel(
      id: id ?? this.id,
      pinId: pinId ?? this.pinId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
