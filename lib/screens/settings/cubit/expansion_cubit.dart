import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'expansion_state.dart';

class ExpansionCubit extends Cubit<ExpansionState> {
  ExpansionCubit() : super(ExpansionInitial());

  //unfo expansionTileController.collapse(); ignores animation
  //await Future.delayed(const Duration(milliseconds: 200));
  //is added to preserve animations

  void expandCustomization() async {
    await Future.delayed(const Duration(milliseconds: 200));
    emit(CustomizationExpanded());
  }

  void expandConnection() async {
    await Future.delayed(const Duration(milliseconds: 200));

    emit(ConnectionExpanded());
  }

  void expandPrinting() async {
    await Future.delayed(const Duration(milliseconds: 200));
    emit(PrintingExpanded());
  }

  void expandScanning() async {
    await Future.delayed(const Duration(milliseconds: 200));
    emit(ScaningExpanded());
  }
}
