class Formatter {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool isValidEmail(String email) => emailRegex.hasMatch(email);
}
