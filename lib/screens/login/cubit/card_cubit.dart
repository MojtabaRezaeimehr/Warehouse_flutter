import 'package:flutter_bloc/flutter_bloc.dart';

part 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  CardCubit() : super(LogInState());

  changeState() {
    emit(
      state is LogInState
          ? IpConfigState()
          : LogInState(),
    );
  }
}
