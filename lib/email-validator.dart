import 'package:email_validator/email_validator.dart';

class EmailFieldValidator {

  static String validate(String value) {
    {
      if (value.isEmpty) {
        return 'Laukas tuščias';
      }
      if ((EmailValidator.validate(value))) {
        return null;
      }
      return 'El. laiškas negalimas';
    }
  }

}