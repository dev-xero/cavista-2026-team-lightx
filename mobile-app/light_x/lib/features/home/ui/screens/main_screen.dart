import 'package:flutter/material.dart';
import 'package:light_x/features/home/ui/screens/home.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(appBar: const SizedBox(), appBarPadding: (_) => EdgeInsets.zero, body: Home());
  }
}
