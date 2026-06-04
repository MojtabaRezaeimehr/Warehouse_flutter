part of 'scan_cubit.dart';

sealed class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

final class ScanInitial extends ScanState {}

sealed class PostingBarcodeWrapper extends ScanState {
  final String barcode;
  final ScannerType scannerType;

  const PostingBarcodeWrapper(
      {required this.barcode, required this.scannerType});
  @override
  List<Object?> get props => [barcode, scannerType.name];
}

final class PostingBarcode extends PostingBarcodeWrapper {
  const PostingBarcode({required super.barcode, required super.scannerType});
}

sealed class PostingBarcodeDone extends PostingBarcodeWrapper {
  final String scanDuration;
  final DateTime scanDate;

  const PostingBarcodeDone({
    required super.barcode,
    required super.scannerType,
    required this.scanDuration,
    required this.scanDate,
  });
  @override
  List<Object?> get props => [...super.props, scanDuration,scanDate.hashCode];
}

final class PostingBarcodeError extends PostingBarcodeDone {
  final String error;

  const PostingBarcodeError(
      {required this.error,
      required super.barcode,
      required super.scannerType,
      required super.scanDate,
      required super.scanDuration});
  @override
  List<Object?> get props => [...super.props, error];
}

final class PostedBarcode extends PostingBarcodeDone {
  final ScanResponses scanResponse;

  const PostedBarcode({
    required this.scanResponse,
    required super.barcode,
    required super.scanDate,
    required super.scannerType,
    required super.scanDuration,
  });
  @override
  List<Object?> get props => [...super.props, scanResponse.name];
}
