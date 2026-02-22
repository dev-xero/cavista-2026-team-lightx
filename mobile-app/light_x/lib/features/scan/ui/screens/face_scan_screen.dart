import 'package:flutter/material.dart';
import 'package:light_x/features/scan/logic/api_functions/face_analyzer_api_funtions.dart';
import 'package:light_x/features/scan/logic/face_scan_service.dart';
import 'package:light_x/features/scan/providers/face_scanner_provider.dart';
import 'package:light_x/features/scan/ui/widgets/face_scanner_widgets.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:provider/provider.dart';

class FaceScannerScreen extends StatefulWidget {
  const FaceScannerScreen({super.key});

  @override
  State<FaceScannerScreen> createState() => _FaceScannerScreenState();
}

class _FaceScannerScreenState extends State<FaceScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off camera init after the first frame so the provider is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceScannerProvider>().initialize();
    });
  }

  // ── Derived helpers ────────────────────────────────────────────────────────

  String _lightingValue(FaceScannerProvider p) {
    final result = p.lastResult;
    if (result == null) return 'Checking…';
    switch (result.lighting) {
      case LightingStatus.optimal:
        return 'Optimal';
      case LightingStatus.tooDark:
        return 'Too Dark';
      case LightingStatus.tooBright:
        return 'Too Bright';
      case LightingStatus.unknown:
        return 'Unknown';
    }
  }

  String _distanceValue(FaceScannerProvider p) {
    final result = p.lastResult;
    if (result == null) return 'Checking…';
    switch (result.distance) {
      case DistanceStatus.perfect:
        return 'Perfect';
      case DistanceStatus.okay:
        return 'Okay';
      case DistanceStatus.tooFar:
        return 'Too Far';
      case DistanceStatus.tooClose:
        return 'Too Close';
      case DistanceStatus.unknown:
        return 'Unknown';
    }
  }

  String _progressCaption(FaceScannerProvider p) {
    if (p.state == FaceScanState.initializing) return 'Starting camera…';
    if (p.state == FaceScanState.error) return p.errorMessage ?? 'An error occurred';
    if (p.state == FaceScanState.complete) return 'Scan complete!';

    final result = p.lastResult;
    if (result == null) return 'Align your face in the frame';

    // Show the most actionable guidance first.
    if (!result.isAcceptable) {
      if (result.lighting != LightingStatus.optimal) return result.lightingMessage;
      return result.distanceMessage;
    }
    return 'Hold still, almost done…';
  }

  String _stepLabel(FaceScannerProvider p) {
    switch (p.state) {
      case FaceScanState.idle:
      case FaceScanState.initializing:
        return 'Initialising';
      case FaceScanState.scanning:
        return 'Scanning Vitals';
      case FaceScanState.complete:
        return 'Scan Complete';
      case FaceScanState.error:
        return 'Error';
      case FaceScanState.backendError:
        return "Processing Error";
      case FaceScanState.success:
        return "success";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FaceScannerProvider>(
      builder: (context, provider, _) {
        final pct = (provider.progress * 100).toStringAsFixed(0);

        final indicators = [
          StatusIndicatorData(label: 'Lighting', value: _lightingValue(provider)),
          StatusIndicatorData(label: 'Distance', value: _distanceValue(provider)),
        ];

        final progressData = ScanProgressData(
          stepLabel: _stepLabel(provider),
          percentLabel: '$pct%',
          fraction: provider.progress,
          caption: _progressCaption(provider),
        );

        return AppScaffold(
          backgroundColor: const Color(0xFFF6F6F8),
          leading: CloseButton(),
          title: Center(child: AppTexts.pageAppBarTitleText("Face Scan")),
          trailing: BuildIconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline, color: Colors.black, size: 24),
          ),
          appBarPadding: (apply) => apply.copyWith(bottom: 8),
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

                // Animated viewfinder — fraction drives the arc
                Center(child: ScanningViewfinder(fraction: provider.progress)),

                const SizedBox(height: 40),

                // Real-time status indicators (live from provider)
                StatusIndicatorsRow(indicators: indicators),

                const SizedBox(height: 32),

                // Progress bar (live from provider)
                ScanProgressBar(data: progressData),

                const SizedBox(height: 32),

                // Footer buttons
                ScannerFooter(
                  primaryLabel: provider.state == FaceScanState.complete
                      ? 'Continue'
                      : provider.state == FaceScanState.error
                      ? 'Retry'
                      : 'Continue',
                  secondaryLabel: 'Cancel',
                  onPrimary: () async {
                    if (provider.state == FaceScanState.error) {
                      provider.retry();
                    } else if (provider.state == FaceScanState.complete) {
                      if (provider.snapshot != null) {
                        final result = await FaceAnalyzerApiFunctions.analyzeFacial(provider.snapshot!);
                        if (result.data == null || result.data!.isEmpty) {
                          provider.setBackendError({
                            'message': 'No face detected in the image.',
                            'details': ['Ensure your face is fully visible and well-lit, then try again.'],
                          });
                        } else {
                          if (context.mounted) Routes.faceScanResult.push(context);
                        }
                      }
                    }
                  },
                  onSecondary: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
