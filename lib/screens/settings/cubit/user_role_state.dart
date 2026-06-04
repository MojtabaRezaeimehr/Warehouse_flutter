part of 'user_role_cubit.dart';

sealed class UserRoleState extends Equatable {
  const UserRoleState();

  @override
  List<Object> get props => [];
}

final class UserRoleInitial extends UserRoleState {}

final class UserIsAdmin extends UserRoleState {}

final class UserHasWrongPassword extends UserRoleState {
  final DateTime date = DateTime.now();
  @override
  List<Object> get props => [date];
}

final class UserIsNotAdmin extends UserRoleState {}
