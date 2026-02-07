import 'package:equatable/equatable.dart';

class Pin extends Equatable {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final String? link;
  final int width;
  final int height;
  final String? photographer;
  final String? photographerUrl;
  final String? avgColor;
  final bool isSaved;
  final String? boardId;
  final DateTime? createdAt;

  const Pin({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.title,
    this.description,
    this.link,
    required this.width,
    required this.height,
    this.photographer,
    this.photographerUrl,
    this.avgColor,
    this.isSaved = false,
    this.boardId,
    this.createdAt,
  });

  double get aspectRatio => width / height;

  Pin copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? link,
    int? width,
    int? height,
    String? photographer,
    String? photographerUrl,
    String? avgColor,
    bool? isSaved,
    String? boardId,
    DateTime? createdAt,
  }) {
    return Pin(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      width: width ?? this.width,
      height: height ?? this.height,
      photographer: photographer ?? this.photographer,
      photographerUrl: photographerUrl ?? this.photographerUrl,
      avgColor: avgColor ?? this.avgColor,
      isSaved: isSaved ?? this.isSaved,
      boardId: boardId ?? this.boardId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    thumbnailUrl,
    title,
    description,
    link,
    width,
    height,
    photographer,
    photographerUrl,
    avgColor,
    isSaved,
    boardId,
    createdAt,
  ];
}
