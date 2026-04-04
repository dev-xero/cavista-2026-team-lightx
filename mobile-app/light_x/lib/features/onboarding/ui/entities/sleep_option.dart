class SleepOption {
  final String title;
  final String subtitle;
  final int sleepHours;

  const SleepOption({required this.title, required this.subtitle, required this.sleepHours});

  static List<SleepOption> get options => const [
    SleepOption(title: 'Very Little', subtitle: '3hrs - 4hrs', sleepHours: 3),
    SleepOption(title: 'A Little', subtitle: '5hrs - 6hrs', sleepHours: 5),
    SleepOption(title: 'Good', subtitle: '7hrs - 8hrs', sleepHours: 7),
    SleepOption(title: 'Excellent', subtitle: '8hrs - 10hrs', sleepHours: 8),
  ];
}
