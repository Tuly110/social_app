import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/auth/domain/usecases/reset_password_usecase.dart';
import 'package:social_app/src/modules/auth/domain/usecases/sign_in_withGG_usecase.dart';
import 'package:social_app/src/modules/auth/domain/usecases/update_password_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../domain/usecases/signin_usecase.dart';
import '../../domain/usecases/signout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignOutUsecase _signOutUsecase;
  final SigninUsecase _signinUsecase;
  final SignInWithggUsecase _signInWithggUsecase;
  final SignupUsecase _signupUsecase;
  final ResetPasswordUsecase _resetPasswordUsecase;
  final UpdatePasswordUsecase _updatePasswordUsecase;
  final SupabaseClient supabaseClient;
  StreamSubscription? _authSubscription;
  

  AuthCubit({
    required SignOutUsecase signOutUsecase,
    required SigninUsecase signinUsecase,
    required SignInWithggUsecase signInWithggUsecase,
    required SignupUsecase signupUsecase,
    required ResetPasswordUsecase resetPasswordUsecase,
    required UpdatePasswordUsecase updatePasswordUsecase,
    required SupabaseClient supabaseClient,
  }) :  _signinUsecase = signinUsecase,
        _signInWithggUsecase = signInWithggUsecase,  
        _signupUsecase = signupUsecase,
        _signOutUsecase = signOutUsecase,
        _resetPasswordUsecase = resetPasswordUsecase,
        _updatePasswordUsecase =  updatePasswordUsecase,
        supabaseClient = supabaseClient,
        super(const AuthState.loading()) 
        {
            _authSubscription = supabaseClient.auth.onAuthStateChange.listen((response) {
            if (isClosed) return;
            final event = response.event;
            final session = response.session;
            final user = response.session?.user;

             if (event == AuthChangeEvent.passwordRecovery) {
              emit(const AuthState.passwordRecovery());
              return;
            } 
            
            if (user != null) {
                emit(AuthState.authenticated(user.id)); 
            } else {
                emit(const AuthState.unauthenticated());
            }
        });
    }
    bool validateEmail(String email){
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        return emailRegex.hasMatch(email);
    }

    bool validatePassword(String password){
        final specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
        if(password.length < 8){
            return false;
        }
        if (!specialCharRegex.hasMatch(password)) {
            return false;
        }
        
        return true;
    }

    void onChangedEmail(String email){
        final isValid = validateEmail(email);
        final currentState = state.maybeWhen(
            unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => (passErr, msg, isPasswordValid), 
            orElse: () => ('', null, false),
        );
        
        if (!isClosed) {
          emit(AuthState.unauthenticated(
            emailError: isValid ? '' : 'Invalid email format',
            passwordError: currentState.$1,
            errorMessage: currentState.$2,
            isPasswordValid: currentState.$3,
            isEmailValid: isValid,
          ));
        }
    }
    void onChangedPassword(String password) {
        final isValid = validatePassword(password);
        String errorMsg = '';
        if (password.length < 8) {
            errorMsg = 'Password must be at least 8 characters.';
        } else if (!validatePassword(password)) {
            errorMsg = 'Password must contain at least one special character.';
        }

        final currentState = state.maybeWhen(
          unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) 
              => (emailErr, msg, isEmailValid),
          orElse: () => ('', null, false),
        );

        if (!isClosed) {
          emit(AuthState.unauthenticated(
            passwordError: isValid ? '' : errorMsg,
            emailError: currentState.$1,
            errorMessage: currentState.$2,
            isEmailValid: currentState.$3,
            isPasswordValid: isValid, 
          ));
        }
    }

    Future<void> signIn({required String email, required String password}) async {

        final emailValid = validateEmail(email);
        final passwordValid = validatePassword(password);

        if(!emailValid || !passwordValid) {
          if (!isClosed) {
            emit(AuthState.unauthenticated(
              emailError: emailValid ? '' : 'Invalid email format',
              passwordError: passwordValid ? '' : 'Invalid password',
              isEmailValid: emailValid,
              isPasswordValid: passwordValid,
            ));
          }
          return;
        }

        if (!isClosed) {
          emit(const AuthState.loading());
        }
        
        final result = await _signinUsecase(email: email, password: password);
        if (isClosed) return;
        result.fold(
        
        (failure) {
          emit(AuthState.unauthenticated(
            emailError: '',
            passwordError: '',
            errorMessage: failure.message,
            isEmailValid: true, 
            isPasswordValid: true, 
          ));
        },
        (user) {
          emit(AuthState.authenticated(user.id));
        },
        );
    }

    Future<void> signInWithGoogle() async{
      try{
        emit(const AuthState.googleLoading());
        final result = await _signInWithggUsecase();
        if (isClosed) return;

        result.fold(
          (failure){
              emit(AuthState.unauthenticated(
              emailError: '',
              passwordError: '',
              errorMessage: failure.message,
              isEmailValid: true, 
              isPasswordValid: true, 
            ));
          },
          (user){
            // *****************************
            emit(const AuthState.unauthenticated(
              errorMessage:null,
            ));
          }
        );

      }catch(e){
        if (!isClosed) {
        emit(AuthState.unauthenticated(
          emailError: '',
          passwordError: '',
          errorMessage: e.toString(),
          isEmailValid: true,
          isPasswordValid: true,
        ));
      }
      }
    }

    Future<void> signUp({required String email, required String password}) async {
      final emailValid = validateEmail(email);
      final passwordValid = validatePassword(password);
      
      if(!emailValid || !passwordValid) {
        emit(AuthState.unauthenticated(
          emailError: emailValid ? '' : 'Invalid email format',
          passwordError: passwordValid ? '' : 'Invalid password',
          isEmailValid: emailValid,
          isPasswordValid: passwordValid,
        ));
      return;
      }

      emit(const AuthState.loading());
      final result = await _signupUsecase(email: email, password: password);
      
      result.fold(
        (failure) {
          emit(AuthState.unauthenticated(
            emailError: '',
            passwordError: '',
            errorMessage: failure.message,
            isEmailValid: true, 
            isPasswordValid: true, 
          ));
        },
        (_) {
          emit(AuthState.pendingVerification(email: email));
        },
      );
    }

    Future<void> signOut() async {
        emit(const AuthState.loading());
        
        final result = await _signOutUsecase.call();
        
        result.fold(
        (failure) {
            emit(AuthState.failure(failure.message));
        },
        
        (_) => null,
        );
    }
    
    Future<void> resetPassword({required String email}) async{
      try {
        
        // Validate email
        if (!validateEmail(email)) {
          throw "Please enter a valid email address";
        }

        emit(const AuthState.loading());

        final result = await _resetPasswordUsecase(email: email);
        
        if (isClosed) return;
        
        result.fold(
          (failure) {
            emit(AuthState.unauthenticated(
              emailError: '',
              passwordError: '',
              errorMessage: failure.message,
              isEmailValid: true,
              isPasswordValid: true,
            ));
          },
          (_) {
            // Success - emit success state
            emit(AuthState.passwordResetSent(email: email));
            print('✅ Password reset email sent to: $email');
          },
        );

      } catch (e) {
        if (!isClosed) {
          emit(AuthState.unauthenticated(
            emailError: '',
            passwordError: '',
            errorMessage: e.toString(),
            isEmailValid: true,
            isPasswordValid: true,
          ));
        }
        rethrow;
      }
    }

    Future<void> updatePassword({required String newPassword}) async {
      try{
        if(newPassword.isEmpty) {
          emit(AuthState.failure('Password cannot be empty'));
          return;
        }

        if (!validatePassword(newPassword)) {
          emit(AuthState.failure('Password must be at least 8 characters with special characters'));
          return;
        }

        emit(const AuthState.loading());
        final result = await _updatePasswordUsecase.call(newPassword: newPassword);

        result.fold(
          (failure) {
              emit(AuthState.failure(failure.message));
          },
          (_) => null
        );
      }catch(e){
          emit(AuthState.failure(e.toString()));
        }
    }
      

    @override
    Future<void> close() {
        _authSubscription?.cancel();
        return super.close();
    }
  
    
}