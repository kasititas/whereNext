class PasswordValidator {

  static String validate(String value) {
    if (value.isEmpty) {
      return 'Šis laukas privalomas';
    }
    if (value.length < 8) {
      return 'Slaptažodis turi būti sudarytas iš 8 simbolių';
    }
    return null;
  }
}
