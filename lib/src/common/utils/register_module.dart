import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  // Đăng ký SupabaseClient dưới dạng LazySingleton
  // SupabaseClient được lấy từ instance đã khởi tạo trong main()
  @lazySingleton
  SupabaseClient get supabaseClient {
    // Đảm bảo Supabase.instance đã được khởi tạo
    return Supabase.instance.client;
  }
}
