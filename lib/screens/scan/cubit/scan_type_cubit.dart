import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scan_type_state.dart';

class ScanTypeCubit extends Cubit<ScanTypeState> {
  ScanTypeCubit() : super(AddingState());

  void changeState() => emit(
        state is AddingState ? DeletingState() : AddingState(),
      );

  void reset() => emit(AddingState());
}
