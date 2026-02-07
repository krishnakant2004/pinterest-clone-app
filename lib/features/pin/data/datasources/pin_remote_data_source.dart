import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/pin_model.dart';

final pinRemoteDataSourceProvider = Provider<PinRemoteDataSource>((ref) {
  return PinRemoteDataSourceImpl(DioClient());
});

abstract class PinRemoteDataSource {
  Future<List<PinModel>> getCuratedPhotos({int page = 1, int perPage = 20});
  Future<List<PinModel>> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 20,
  });
  Future<PinModel> getPhotoById(String id);
}

class PinRemoteDataSourceImpl implements PinRemoteDataSource {
  final DioClient _dioClient;

  PinRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PinModel>> getCuratedPhotos({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dioClient.get(
      '/v1/curated',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    final List<dynamic> photos = response.data['photos'];
    return photos.map((json) => PinModel.fromPexelsJson(json)).toList();
  }

  @override
  Future<List<PinModel>> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dioClient.get(
      '/v1/search',
      queryParameters: {'query': query, 'page': page, 'per_page': perPage},
    );

    final List<dynamic> photos = response.data['photos'];
    print(photos);
    return photos.map((json) => PinModel.fromPexelsJson(json)).toList();
  }

  @override
  Future<PinModel> getPhotoById(String id) async {
    final response = await _dioClient.get('/v1/photos/$id');
    if (kDebugMode) {
      print(response.data);
    }
    return PinModel.fromPexelsJson(response.data);
  }
}
