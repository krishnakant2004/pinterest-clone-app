import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration - Replace with your own project credentials
/// Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
class SupabaseConfig {
  static const String supabaseUrl = 'https://ydvfzychvpezjwjwfjzx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkdmZ6eWNodnBlemp3andmanp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAxNzQ3NTUsImV4cCI6MjA4NTc1MDc1NX0.QTYI7I36eUjGVYYnHfH5Pe4bVSEtBpZwUUJSVPZdsbU';
}

/// Supabase service for cloud database operations
/// Note: Board, SavedPin, and Like operations are in their respective feature datasources
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Get current user ID (from Clerk, stored in user metadata)
  static String? get currentUserId {
    // Since we're using Clerk for auth, we'll pass the Clerk user ID
    // when making database operations
    return null;
  }

  // ============ USER PROFILE OPERATIONS ============

  /// Create or update user profile
  static Future<Map<String, dynamic>> upsertUserProfile({
    required String clerkUserId,
    required String email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
  }) async {
    final response =
        await client
            .from('profiles')
            .upsert({
              'clerk_user_id': clerkUserId,
              'email': email,
              'username': username,
              'full_name': fullName,
              'avatar_url': avatarUrl,
              'bio': bio,
              'website': website,
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'clerk_user_id')
            .select()
            .single();

    return response;
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(
    String clerkUserId,
  ) async {
    final response =
        await client
            .from('profiles')
            .select()
            .eq('clerk_user_id', clerkUserId)
            .maybeSingle();

    return response;
  }

  // ============ FOLLOWS TABLE OPERATIONS ============

  /// Follow a user
  static Future<void> followUser({
    required String followerId,
    required String followingId,
  }) async {
    await client.from('follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Unfollow a user
  static Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    await client
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }

  /// Get followers count
  static Future<int> getFollowersCount(String userId) async {
    final response = await client
        .from('follows')
        .select()
        .eq('following_id', userId);

    return (response as List).length;
  }

  /// Get following count
  static Future<int> getFollowingCount(String userId) async {
    final response = await client
        .from('follows')
        .select()
        .eq('follower_id', userId);

    return (response as List).length;
  }

  // ============ STORAGE OPERATIONS ============

  /// Upload image to Supabase Storage
  static Future<String> uploadImage({
    required String bucket,
    required String path,
    required List<int> bytes,
    String contentType = 'image/jpeg',
  }) async {
    await client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes as dynamic,
          fileOptions: FileOptions(contentType: contentType),
        );

    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete image from storage
  static Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }
}
