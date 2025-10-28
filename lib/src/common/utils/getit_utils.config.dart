// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:jupyternotebook/src/modules/app/app_router.dart' as _i311;
import 'package:jupyternotebook/src/modules/notebook/data/remote/notebook_client.dart'
    as _i377;
import 'package:jupyternotebook/src/modules/notebook/data/remote/socket_module.dart'
    as _i550;
import 'package:jupyternotebook/src/modules/notebook/domain/repository/notebook_repo.dart'
    as _i233;

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
    final webSocketModule = _$WebSocketModule();
    gh.singleton<_i311.AppRouter>(() => _i311.AppRouter());
    gh.factory<String>(
      () => webSocketModule.webSocketUrl,
      instanceName: 'webSocketUrl',
    );
    gh.factory<_i377.Client>(
        () => _i377.Client(gh<String>(instanceName: 'webSocketUrl')));
    gh.singleton<_i233.NotebookRepo>(
        () => _i233.NotebookRepo(gh<_i377.Client>()));
    return this;
  }
}

class _$WebSocketModule extends _i550.WebSocketModule {}
