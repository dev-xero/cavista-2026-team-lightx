import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/core/base/src/absorber.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/core/utils/nav_utils.dart';
import 'package:light_x/features/face_scan/providers/entities/face_scan_state.dart';
import 'package:light_x/features/face_scan/providers/face_scan_provider.dart';
import 'package:light_x/features/face_scan/ui/widgets/face_scanner_widgets.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class FaceScannerScreen extends ConsumerStatefulWidget {
  const FaceScannerScreen({super.key});

  @override
  ConsumerState<FaceScannerScreen> createState() => _FaceScannerScreenState();
}

class _FaceScannerScreenState extends ConsumerState<FaceScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FaceScanProvider.asPro.read(ref).state.self(ref).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final faceScanProvider = FaceScanProvider.asPro.read(ref);
    final faceScanStateProvider = faceScanProvider.state;

    return AppScaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBarPadding: (apply) => EdgeInsets.zero,
      extendBodyBehindAppBar: true,
      viewPadding: EdgeInsets.zero,
      appBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: ColoredBox(
            color: const Color(0xFFF6F6F8).withValues(alpha: 0.92),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CloseButton(),
                      12.inRow,
                      AppTexts.pageAppBarTitleText("Face Scan"),
                      12.inRow,
                      BuildIconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline, color: Colors.black, size: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: TopPadding(withHeight: 24)),

                // Instructional header
                const SliverToBoxAdapter(
                  child: ScannerHeader(
                    heading: 'Position your face in the frame',
                    subtitle: 'Keep your face centred and stay still while we capture your biometric data.',
                  ),
                ),

                40.inSliverColumn,

                // Animated viewfinder — fraction drives the arc
                SliverToBoxAdapter(
                  child: Center(
                    child: AbsorberWatch(
                      listenable: faceScanProvider.display,
                      builder: (_, display, _, _) {
                        return ScanningViewfinder(fraction: display.progress);
                      },
                    ),
                  ),
                ),

                40.inSliverColumn,

                // Real-time status indicators (live from provider)
                SliverToBoxAdapter(
                  child: AbsorberWatch(
                    listenable: faceScanProvider.display,
                    builder: (_, display, _, _) {
                      return StatusIndicatorsRow(
                        indicators: [
                          StatusIndicatorData(label: 'Lighting', value: display.lighting),
                          StatusIndicatorData(label: 'Distance', value: display.distance),
                        ],
                      );
                    },
                  ),
                ),

                32.inSliverColumn,

                32.inSliverColumn,
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 8,
            right: 8,
            child: TopPadding(
              withHeight: 56,
              child: AbsorberWatch(
                listenable: faceScanProvider.display,
                builder: (_, display, _, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutralBlack50, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ScanProgressBar(
                      data: ScanProgressData(
                        stepLabel: display.stepLabel,
                        percentLabel: display.percentLabel,
                        fraction: display.progress,
                        caption: display.caption,
                      ),
                    ),
                  ).animate(target: display.progress == 0 ? 0 : 1).scaleXY().fadeIn();
                },
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      footerPadding: EdgeInsets.zero,
      footer: AbsorberWatch(
        listenable: faceScanProvider.display,
        builder: (_, display, _, _) {
          return ScannerFooter(
            primaryLabel: display.primaryLabel,
            secondaryLabel: 'Cancel',
            onPrimary: () async {
              final notifier = faceScanStateProvider.self(ref);
              final phase = faceScanStateProvider.read(ref).phase;
              if (phase == FaceScanPhase.error) {
                await notifier.retry();
              } else if (phase == FaceScanPhase.complete) {
                CustomDialog.showLoadingDialog(context);
                final success = await notifier.submitCurrentSnapshot();
                if (context.mounted && success) {
                  Routes.faceScanResult.push(context);
                }
                NavUtils.popGlobal();
              }
            },
            onSecondary: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}
