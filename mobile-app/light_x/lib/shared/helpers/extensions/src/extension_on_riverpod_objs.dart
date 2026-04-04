part of '../extensions.dart';

extension ProviderExtension<StateT> on ProviderListenable<StateT> {
  StateT read(WidgetRef ref) => ref.read<StateT>(this);
  StateT watch(WidgetRef ref) => ref.watch<StateT>(this);
}

extension NotifierProviderExtension<NotifierT extends Notifier<StateT>, StateT> on NotifierProvider<NotifierT, StateT> {
  NotifierT self(WidgetRef ref) => ref.read<NotifierT>(notifier);
  NotifierT me(WidgetRef ref) => ref.read<NotifierT>(notifier);
}

extension RefLockX on Ref {
  /// Listens to multiple providers with empty callbacks
  /// just to keep them alive (locked in memory).
  void keepAliveMany(List<ProviderListenable> providers) {
    for (final p in providers) {
      listen(p, (_, __) {});
    }
  }
}
