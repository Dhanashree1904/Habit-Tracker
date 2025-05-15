class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email can't be empty";
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password can't be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) return "Confirm your password";
    if (password != confirmPassword) return "Passwords do not match";
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Please enter a name";
    return null;
  }
}
