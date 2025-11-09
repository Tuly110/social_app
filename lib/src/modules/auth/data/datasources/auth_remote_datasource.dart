

import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource{
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> updatePassword({required String newPassword});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDatasourceImpl implements AuthRemoteDataSource{
  final SupabaseClient supabaseClient;
  AuthRemoteDatasourceImpl(this.supabaseClient);

  Future<UserEntity> mapUserandCreateProfile(User user, String email) async {
    final defaultUsername = email.split('@')[0];
    final userId = user.id;

    try {
      final existingProfile = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (existingProfile == null) {
        // create new if not have acc
        await supabaseClient.from('profiles').insert({
          'id': userId,
          'username': defaultUsername,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        print('RLS violation, trying alternative approach...');
        await _createProfileAlternative(userId, defaultUsername, email);
      } else {
        rethrow;
      }
    }

    return UserEntity(
      id: userId, 
      email: email,
      username: defaultUsername,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  // Phương thức alternative để tạo profile
  Future<void> _createProfileAlternative(String userId, String username, String email) async {
    try {

      await supabaseClient.rpc('create_user_profile', params: {
        'user_id': userId,
        'user_email': email,
        'user_username': username,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    try{
      final AuthResponse response = await supabaseClient.auth.signInWithPassword(email: email, password: password);
      if(response.user == null){
        throw Exception("Sign in failed");

      }
      return mapUserandCreateProfile(response.user!, email);
    }on AuthException catch(e){
      throw Exception("Sign in failed: ${e.message}");
    }

  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try{
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'fau.socialapp://login-callback',
      );
      return UserEntity(
        id: 'pending-google-auth',
        email: '',
        username: '',
        avatarUrl: null,
        isEmailVerified: false,
      );
    } on AuthException catch (e) {
        throw "Google sign in failed. Please try again. ${e.message}";
    }
  }

  @override
  Future<UserEntity> signUp({required String email, required String password}) async {
    try {
      try {
        // Check email exist
        final authResponse = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: 'dummy_password', 
        );
        
        // No exception, email exist
        throw "Email already registered. Please sign in instead.";
      } on AuthException catch (e) {
        if (!e.message.toLowerCase().contains('invalid login credentials')) {
          if (e.message.toLowerCase().contains('email') || 
              e.message.toLowerCase().contains('user')) {
            throw "Email already registered. Please sign in instead.";
          }
          rethrow;
        }

      }
      
      final AuthResponse response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'email': email},
        emailRedirectTo: 'fau.socialapp://login-callback',
      );

      if (response.user?.identities != null && response.user!.identities!.isNotEmpty) {
        final providers = response.user!.identities!.map((i) => i.provider).toList();
        
        if (providers.contains('google')) {
          throw "Email already registered with Google. Please sign in with Google instead.";
        }
      }

      return UserEntity(
        id: response.user?.id ?? 'pending-verification',
        email: email,
        username: email.split('@')[0],
        avatarUrl: null,
        isEmailVerified: false,
      );
    } on AuthException catch (e) {
      if (e.message.contains('already registered') || e.message.contains('user_exists')) {
        throw "Email already registered. Please sign in instead or use forgot password.";
      }
      rethrow;
      
    }
  }

  @override
  Future<void> signOut() {
    return supabaseClient.auth.signOut();
  }


  @override
  Future<void> resetPassword({required String email}) async {
    try {

      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'fau.socialapp://reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> updatePassword({required String newPassword}) async {
    try{
      final res = await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword)
      );
      if(res.user == null){
         throw Exception('Failed to update password');
      }

    }catch(e){
      throw Exception(e.toString());
    }
  }

}