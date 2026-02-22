class Formatter {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool isValidEmail(String email) => emailRegex.hasMatch(email);

  static ({String greeting, String date}) getGreetingAndDate() {
    final now = DateTime.now();

    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final dayName = days[now.weekday - 1];
    final month = months[now.month - 1];
    final date = '$dayName, $month ${now.day}';

    return (greeting: greeting, date: date);
  }
}
