part of 'android_scanner_cubit.dart';

sealed class AndroidScannerState extends Equatable {
  const AndroidScannerState();

  @override
  List<Object> get props => [];
}

final class AndroidScannerInitial extends AndroidScannerState {}

final class StartedListening extends AndroidScannerState {
  final StreamSubscription streamSubscription;

  const StartedListening({required this.streamSubscription});
  @override
  List<Object> get props => [streamSubscription];
}

final class StopedListening extends AndroidScannerState {}
