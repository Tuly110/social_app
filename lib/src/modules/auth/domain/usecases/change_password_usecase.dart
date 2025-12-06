import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';

@lazySingleton
class ChangePasswordUsecase{
  final AuthRepository authRepository;
  ChangePasswordUsecase(this.authRepository);

  Future<Either<Failure, void>> call({required String newPassword, required String currentPassword}){
    return authRepository.changePassword(
      newPassword: newPassword, 
      currentPassword: currentPassword
    );
  }
}