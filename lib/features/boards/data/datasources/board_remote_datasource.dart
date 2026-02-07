import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for boards using Supabase
abstract class BoardRemoteDataSource {
  /// Create a new board in cloud
  Future<Map<String, dynamic>> createBoard({
    required String userId,
    required String name,
    String? description,
    bool isPrivate,
  });

  /// Update a board in cloud
  Future<Map<String, dynamic>> updateBoard({
    required String boardId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isPrivate,
  });

  /// Delete a board from cloud
  Future<void> deleteBoard(String boardId);

  /// Get all boards for a user from cloud
  Future<List<Map<String, dynamic>>> getUserBoards(String userId);

  /// Get a single board by ID from cloud
  Future<Map<String, dynamic>?> getBoard(String boardId);

  /// Update board pin count in cloud
  Future<void> updatePinCount(String boardId, int delta);

  /// Update board cover image in cloud
  Future<void> updateCoverImage(String boardId, String imageUrl);
}

/// Implementation of BoardRemoteDataSource using Supabase
class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final SupabaseClient _client;

  BoardRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> createBoard({
    required String userId,
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    final response =
        await _client
            .from('boards')
            .insert({
              'user_id': userId,
              'name': name,
              'description': description,
              'is_private': isPrivate,
              'pin_count': 0,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> updateBoard({
    required String boardId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isPrivate,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;
    if (isPrivate != null) updates['is_private'] = isPrivate;

    final response =
        await _client
            .from('boards')
            .update(updates)
            .eq('id', boardId)
            .select()
            .single();

    return response;
  }

  @override
  Future<void> deleteBoard(String boardId) async {
    await _client.from('boards').delete().eq('id', boardId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserBoards(String userId) async {
    final response = await _client
        .from('boards')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>?> getBoard(String boardId) async {
    final response =
        await _client.from('boards').select().eq('id', boardId).maybeSingle();

    return response;
  }

  @override
  Future<void> updatePinCount(String boardId, int delta) async {
    // First get current count
    final board = await getBoard(boardId);
    if (board != null) {
      final currentCount = board['pin_count'] as int? ?? 0;
      final newCount = (currentCount + delta).clamp(0, 999999);
      await _client
          .from('boards')
          .update({'pin_count': newCount})
          .eq('id', boardId);
    }
  }

  @override
  Future<void> updateCoverImage(String boardId, String imageUrl) async {
    await _client
        .from('boards')
        .update({
          'cover_image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', boardId);
  }
}
