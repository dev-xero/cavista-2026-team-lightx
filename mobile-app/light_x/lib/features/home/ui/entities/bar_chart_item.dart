class BarChartItem {
  final String label;

  /// Fraction of the max bar height (0.0 – 1.0)
  final double value;
  final bool isActive;

  const BarChartItem({required this.label, required this.value, this.isActive = false});

  static List<BarChartItem> get samples => const [
    BarChartItem(label: 'Mo', value: 48 / 80),
    BarChartItem(label: 'Tu', value: 64 / 80),
    BarChartItem(label: 'We', value: 56 / 80),
    BarChartItem(label: 'Th', value: 40 / 80),
    BarChartItem(label: 'Fr', value: 48 / 80, isActive: true),
    BarChartItem(label: 'Sa', value: 32 / 80),
    BarChartItem(label: 'Su', value: 44 / 80),
  ];
}
