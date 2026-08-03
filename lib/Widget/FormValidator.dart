class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }

  static String? validatePakistaniPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final phoneRegExp = RegExp(r'^((\+92)|(0092)|(0))?3[0-9]{9}$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return "Enter a valid phone number (e.g., 03001234567)";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    //  one letter and one number
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$');
    if (!passwordRegExp.hasMatch(value)) {
      return "Password must contain both letters and numbers";
    }
    return null;
  }
}
