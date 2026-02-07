import '../../domain/entities/pin.dart';

class PinModel extends Pin {
  const PinModel({
    required super.id,
    required super.imageUrl,
    super.thumbnailUrl,
    super.title,
    super.description,
    super.link,
    required super.width,
    required super.height,
    super.photographer,
    super.photographerUrl,
    super.avgColor,
    super.isSaved,
    super.boardId,
    super.createdAt,
  });

  factory PinModel.fromPexelsJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>;
    return PinModel(
      id: json['id'].toString(),
      imageUrl: src['large2x'] ?? src['large'] ?? src['original'],
      thumbnailUrl: src['medium'] ?? src['small'],
      title: json['alt'] ?? '',
      description: json['alt'],
      link: json['url'],
      width: json['width'] ?? 1,
      height: json['height'] ?? 1,
      photographer: json['photographer'],
      photographerUrl: json['photographer_url'],
      avgColor: json['avg_color'],
      isSaved: false,
    );
  }

  factory PinModel.fromUnsplashJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>?;
    return PinModel(
      id: json['id'].toString(),
      imageUrl: urls['regular'] ?? urls['full'],
      thumbnailUrl: urls['small'] ?? urls['thumb'],
      title: json['description'] ?? json['alt_description'] ?? '',
      description: json['description'] ?? json['alt_description'],
      link: json['links']?['html'],
      width: json['width'] ?? 1,
      height: json['height'] ?? 1,
      photographer: user?['name'],
      photographerUrl: user?['links']?['html'],
      avgColor: json['color'],
      isSaved: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'link': link,
      'width': width,
      'height': height,
      'photographer': photographer,
      'photographerUrl': photographerUrl,
      'avgColor': avgColor,
      'isSaved': isSaved,
      'boardId': boardId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory PinModel.fromJson(Map<String, dynamic> json) {
    return PinModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      title: json['title'],
      description: json['description'],
      link: json['link'],
      width: json['width'],
      height: json['height'],
      photographer: json['photographer'],
      photographerUrl: json['photographerUrl'],
      avgColor: json['avgColor'],
      isSaved: json['isSaved'] ?? false,
      boardId: json['boardId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  factory PinModel.fromEntity(Pin pin) {
    return PinModel(
      id: pin.id,
      imageUrl: pin.imageUrl,
      thumbnailUrl: pin.thumbnailUrl,
      title: pin.title,
      description: pin.description,
      link: pin.link,
      width: pin.width,
      height: pin.height,
      photographer: pin.photographer,
      photographerUrl: pin.photographerUrl,
      avgColor: pin.avgColor,
      isSaved: pin.isSaved,
      boardId: pin.boardId,
      createdAt: pin.createdAt,
    );
  }
}
