part of 'user_auth_cubit.dart';

sealed class UserAuthState extends Equatable {
  const UserAuthState();

  @override
  List<Object?> get props => [];
}

final class UserStateInitial extends UserAuthState {}

final class UserUnAuthorized extends UserAuthState {
  final String message;
  final int? code;
  final DateTime date;

  const UserUnAuthorized({
    required this.message,
    required this.code,
    required this.date,
  });
  @override
  List<Object?> get props => [message, code,date];
}

final class UserAuthorized extends UserAuthState {
  final User user;

  const UserAuthorized({required this.user});
  @override
  List<Object?> get props => [user];
}
