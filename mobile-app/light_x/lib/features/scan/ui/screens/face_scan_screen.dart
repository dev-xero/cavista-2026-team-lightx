import 'package:flutter/material.dart';
import 'package:light_x/features/scan/ui/widgets/face_scanner_widgets.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';

class FaceScannerScreen extends StatelessWidget {
  const FaceScannerScreen({super.key});

  static const _indicators = [
    StatusIndicatorData(label: 'Lighting', value: 'Optimal'),
    StatusIndicatorData(label: 'Distance', value: 'Perfect..'),
  ];

  static const _progressData = ScanProgressData(
    stepLabel: 'Step 2 of 3',
    percentLabel: '65%',
    fraction: 0.65,
    caption: 'Hold still, almost done…',
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      leading: CloseButton(),
      title: Center(child: AppTexts.pageAppBarTitleText("Face Scan")),
      trailing: BuildIconButton(
        onPressed: () {},
        icon: Icon(Icons.info_outline, color: Colors.black, size: 24),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),

            // Instructional header
            const ScannerHeader(
              heading: 'Position your face in the frame',
              subtitle:
                  'Keep your face centred and stay still while we capture '
                  'your biometric data.',
            ),

            const SizedBox(height: 40),

            // Animated viewfinder
            const Center(child: ScanningViewfinder(fraction: 0.65)),

            const SizedBox(height: 40),

            // Real-time status indicators
            const StatusIndicatorsRow(indicators: _indicators),

            const SizedBox(height: 32),

            // Progress bar
            const ScanProgressBar(data: _progressData),

            const SizedBox(height: 32),

            ScannerFooter(primaryLabel: "Continue", secondaryLabel: "Cancel", onPrimary: () {}),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
