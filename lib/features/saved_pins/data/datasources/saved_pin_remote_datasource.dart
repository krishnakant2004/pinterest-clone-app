import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for saved pins using Supabase
abstract class SavedPinRemoteDataSource {
  /// Save a pin in cloud
  Future<Map<String, dynamic>> savePin({
    required String userId,
    required String pinId,
    required String boardId,
    required String imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? link,
    required int width,
    required int height,
    String? photographer,
    String? avgColor,
  });

  /// Unsave a pin from cloud
  Future<void> unsavePin({
    required String userId,
    required String pinId,
    required String boardId,
  });

  /// Get saved pins for a board from cloud
  Future<List<Map<String, dynamic>>> getBoardPins(String boardId);

  /// Get all saved pins for a user from cloud
  Future<List<Map<String, dynamic>>> getUserSavedPins(String userId);

  /// Check if a pin is saved in cloud
  Future<bool> isPinSaved({required String userId, required String pinId});

  /// Update saved pin board in cloud
  Future<void> updateSavedPinBoard({
    required String savedPinId,
    required String toBoardId,
  });
}

/// Implementation of SavedPinRemoteDataSource using Supabase
class SavedPinRemoteDataSourceImpl implements SavedPinRemoteDataSource {
  final SupabaseClient _client;

  SavedPinRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> savePin({
    required String userId,
    required String pinId,
    required String boardId,
    required String imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? link,
    required int width,
    required int height,
    String? photographer,
    String? avgColor,
  }) async {
    final response =
        await _client
            .from('saved_pins')
            .insert({
              'user_id': userId,
              'pin_id': pinId,
              'board_id': boardId,
              'image_url': imageUrl,
              'thumbnail_url': thumbnailUrl,
              'title': title,
              'description': description,
              'link': link,
              'width': width,
              'height': height,
              'photographer': photographer,
              'avg_color': avgColor,
              'saved_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return response;
  }

  @override
  Future<void> unsavePin({
    required String userId,
    required String pinId,
    required String boardId,
  }) async {
    await _client
        .from('saved_pins')
        .delete()
        .eq('user_id', userId)
        .eq('pin_id', pinId)
        .eq('board_id', boardId);
  }

  @override
  Future<List<Map<String, dynamic>>> getBoardPins(String boardId) async {
    final response = await _client
        .from('saved_pins')
        .select()
        .eq('board_id', boardId)
        .order('saved_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserSavedPins(String userId) async {
    final response = await _client
        .from('saved_pins')
        .select()
        .eq('user_id', userId)
        .order('saved_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<bool> isPinSaved({
    required String userId,
    required String pinId,
  }) async {
    final response =
        await _client
            .from('saved_pins')
            .select('id')
            .eq('user_id', userId)
            .eq('pin_id', pinId)
            .maybeSingle();
    return response != null;
  }

  @override
  Future<void> updateSavedPinBoard({
    required String savedPinId,
    required String toBoardId,
  }) async {
    await _client
        .from('saved_pins')
        .update({'board_id': toBoardId})
        .eq('id', savedPinId);
  }
}
