part of 'connection_cubit.dart';

sealed class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object> get props => [];
}

final class ConnectionInitial extends ConnectionState {}

final class ConnectionSuccessfull extends ConnectionState {
  final DateTime date;

  const ConnectionSuccessfull(this.date);
  
  @override
  List<Object> get props => [date];
}

final class ConnectionFailed extends ConnectionState {
    final DateTime date;

  const ConnectionFailed(this.date);
  
  @override
  List<Object> get props => [date];
}
