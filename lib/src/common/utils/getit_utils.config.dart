// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:social_app/src/common/utils/register_module.dart' as _i414;
import 'package:social_app/src/modules/app/app_router.dart' as _i886;
import 'package:social_app/src/modules/auth/data/datasources/auth_remote_datasource.dart'
    as _i758;
import 'package:social_app/src/modules/auth/data/repositories/auth_repository_impl.dart'
    as _i791;
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart'
    as _i491;
import 'package:social_app/src/modules/auth/domain/usecases/reset_password_usecase.dart'
    as _i190;
import 'package:social_app/src/modules/auth/domain/usecases/sign_in_withGG_usecase.dart'
    as _i279;
import 'package:social_app/src/modules/auth/domain/usecases/signin_usecase.dart'
    as _i118;
import 'package:social_app/src/modules/auth/domain/usecases/signout_usecase.dart'
    as _i263;
import 'package:social_app/src/modules/auth/domain/usecases/signup_usecase.dart'
    as _i657;
import 'package:social_app/src/modules/auth/domain/usecases/update_password_usecase.dart'
    as _i214;
import 'package:social_app/src/modules/auth/presentation/cubit/auth_cubit.dart'
    as _i950;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i886.AppRouter>(() => _i886.AppRouter());
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i758.AuthRemoteDataSource>(
        () => _i758.AuthRemoteDatasourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i491.AuthRepository>(() => _i791.AuthRepositoryImpl(
          gh<_i758.AuthRemoteDataSource>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.lazySingleton<_i190.ResetPasswordUsecase>(
        () => _i190.ResetPasswordUsecase(gh<_i491.AuthRepository>()));
    gh.lazySingleton<_i118.SigninUsecase>(
        () => _i118.SigninUsecase(gh<_i491.AuthRepository>()));
    gh.lazySingleton<_i263.SignOutUsecase>(
        () => _i263.SignOutUsecase(gh<_i491.AuthRepository>()));
    gh.lazySingleton<_i657.SignupUsecase>(
        () => _i657.SignupUsecase(gh<_i491.AuthRepository>()));
    gh.lazySingleton<_i279.SignInWithggUsecase>(
        () => _i279.SignInWithggUsecase(gh<_i491.AuthRepository>()));
    gh.lazySingleton<_i214.UpdatePasswordUsecase>(
        () => _i214.UpdatePasswordUsecase(gh<_i491.AuthRepository>()));
    gh.factory<_i950.AuthCubit>(() => _i950.AuthCubit(
          signOutUsecase: gh<_i263.SignOutUsecase>(),
          signinUsecase: gh<_i118.SigninUsecase>(),
          signInWithggUsecase: gh<_i279.SignInWithggUsecase>(),
          signupUsecase: gh<_i657.SignupUsecase>(),
          resetPasswordUsecase: gh<_i190.ResetPasswordUsecase>(),
          updatePasswordUsecase: gh<_i214.UpdatePasswordUsecase>(),
          supabaseClient: gh<_i454.SupabaseClient>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i414.RegisterModule {}
