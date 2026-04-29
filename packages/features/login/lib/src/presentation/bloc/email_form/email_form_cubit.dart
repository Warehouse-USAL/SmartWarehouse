import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/src/domain/entities/form_data.dart';

class EmailFormCubit extends Cubit<FormData> {
  EmailFormCubit() : super(FormData()) {
    textController.addListener(_onTextChanged);
  }

  final textController = TextEditingController();

  void _onTextChanged() {
    final email = textController.text;
    emit(state.copyWith(text: () => email, error: () => null));
  }

  void displayError() {
    emit(state.copyWith(error: () => 'Invalid email format.'));
  }
}
