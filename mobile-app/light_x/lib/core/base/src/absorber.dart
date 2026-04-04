import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

typedef AbsorberBuilder<OutT> = Widget Function(BuildContext context, OutT value, WidgetRef ref, Widget? _);

class Absorber {
  /// A convenient method to watch a Provider and rebuild only the necessary widgets.
  static Widget watch<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? child,
  }) => AbsorberWatch(key: key, listenable: listenable, builder: builder, child: child);

  /// A convenient method to read a Provider without listening to its changes.
  static Widget read<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? child,
  }) => AbsorberRead(key: key, listenable: listenable, builder: builder, child: child);

  /// A convenient method to select and watch a specific part of a Provider, preventing unnecessary rebuilds.
  static Widget select<InT, OutT>(
    ProviderListenable<InT> listenable, {
    Key? key,
    required OutT Function(InT) selector,
    required AbsorberBuilder<OutT> builder,
    Widget? child,
  }) => AbsorberSelect<InT, OutT>(key: key, listenable: listenable, selector: selector, builder: builder, child: child);
}

/// Watches the Provider supplied
class AbsorberWatch<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorberBuilder<OutT> builder;
  final Widget? child;
  const AbsorberWatch({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(listenable);
    return builder(context, value, ref, child);
  }
}

/// Reads the Provider supplied
class AbsorberRead<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorberBuilder<OutT> builder;
  final Widget? child;
  const AbsorberRead({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.read(listenable);
    return builder(context, value, ref, child);
  }
}

/// Selects and watches a specific part of a Provider
class AbsorberSelect<InT, OutT> extends ConsumerWidget {
  final ProviderListenable<InT> listenable;
  final OutT Function(InT) selector;
  final AbsorberBuilder<OutT> builder;
  final Widget? child;

  const AbsorberSelect({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(listenable.select(selector));

    return builder(context, value, ref, child);
  }
}
