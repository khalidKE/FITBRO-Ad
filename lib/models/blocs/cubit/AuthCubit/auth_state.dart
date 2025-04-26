part of 'auth_cubit.dart';



@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}

class GetUserInfoLoading extends AuthState {}

class GetUserInfoSuccess extends AuthState {}

class GetUserInfoError extends AuthState {
  final String error;
  GetUserInfoError(this.error);
}

class SignOutLoading extends AuthState {}

class SignOutSuccess extends AuthState {}