import 'package:email_validator/email_validator.dart';

class FormData {
  FormData({this.text, this.error});

  final String? text, error;

  FormData copyWith({
    String? Function()? text,
    String? Function()? error,
  }) {
    return FormData(
      text: text != null ? text() : this.text,
      error: error != null ? error() : this.error,
    );
  }

  bool get isValid => text != null && text!.isNotEmpty && error == null && EmailValidator.validate(text!);
}
