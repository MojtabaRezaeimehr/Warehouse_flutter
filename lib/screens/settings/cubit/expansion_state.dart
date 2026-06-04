part of 'expansion_cubit.dart';

sealed class ExpansionState extends Equatable {
  const ExpansionState();

  @override
  List<Object> get props => [];
}

final class ExpansionInitial extends ExpansionState {}
final class CustomizationExpanded extends ExpansionState {}
final class ConnectionExpanded extends ExpansionState {}
final class PrintingExpanded extends ExpansionState {}
final class ScaningExpanded extends ExpansionState {}

