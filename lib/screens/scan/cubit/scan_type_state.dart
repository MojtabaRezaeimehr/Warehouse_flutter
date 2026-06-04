part of 'scan_type_cubit.dart';

sealed class ScanTypeState extends Equatable {
  const ScanTypeState();

  @override
  List<Object?> get props => [];
}

final class AddingState extends ScanTypeState {}
final class DeletingState extends ScanTypeState {}
