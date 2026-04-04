part of '../base.dart';

class CustomValueNotifier<T> extends ValueNotifier<T> {
  final T defaultValue;

  CustomValueNotifier(this.defaultValue) : super(defaultValue);

  void reset() {
    value = defaultValue;
  }
}

mixin ValueNotifierFactoryMixin {
  final Map<int, ValueNotifier> _notifiers = <int, ValueNotifier>{};
  int _counter = 0;
  bool _disposed = false;

  @protected
  CustomValueNotifier<T> useValueNotifier<T>(T initialValue) {
    assert(!_disposed, 'Cannot create notifier after disposal');

    final notifierKey = _counter++;
    final notifier = CustomValueNotifier<T>(initialValue);
    _notifiers[notifierKey] = notifier;
    return notifier;
  }

  @protected
  void resetNotifiers() {
    for (final notifier in _notifiers.values) {
      if (notifier is CustomValueNotifier) {
        notifier.reset();
      }
    }
  }

  @protected
  void disposeNotifiers() {
    if (_disposed) return;
    _disposed = true;

    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    log("disposed notifiers");
  }
}
