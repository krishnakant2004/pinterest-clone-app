import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for likes using Supabase
abstract class LikeRemoteDataSource {
  /// Like a pin in cloud
  Future<void> likePin({required String userId, required String pinId});

  /// Unlike a pin in cloud
  Future<void> unlikePin({required String userId, required String pinId});

  /// Check if a pin is liked in cloud
  Future<bool> isPinLiked({required String userId, required String pinId});

  /// Get all liked pin IDs for a user from cloud
  Future<List<String>> getUserLikedPinIds(String userId);
}

/// Implementation of LikeRemoteDataSource using Supabase
class LikeRemoteDataSourceImpl implements LikeRemoteDataSource {
  final SupabaseClient _client;

  LikeRemoteDataSourceImpl(this._client);

  @override
  Future<void> likePin({required String userId, required String pinId}) async {
    await _client.from('likes').upsert({
      'user_id': userId,
      'pin_id': pinId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> unlikePin({
    required String userId,
    required String pinId,
  }) async {
    await _client
        .from('likes')
        .delete()
        .eq('user_id', userId)
        .eq('pin_id', pinId);
  }

  @override
  Future<bool> isPinLiked({
    required String userId,
    required String pinId,
  }) async {
    final response =
        await _client
            .from('likes')
            .select('id')
            .eq('user_id', userId)
            .eq('pin_id', pinId)
            .maybeSingle();
    return response != null;
  }

  @override
  Future<List<String>> getUserLikedPinIds(String userId) async {
    final response = await _client
        .from('likes')
        .select('pin_id')
        .eq('user_id', userId);
    return (response as List).map((e) => e['pin_id'] as String).toList();
  }
}
