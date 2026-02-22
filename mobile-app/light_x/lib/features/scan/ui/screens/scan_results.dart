import 'package:flutter/material.dart';
import 'package:light_x/features/scan/providers/face_scanner_provider.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:provider/provider.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceScannerProvider>();

    return AppScaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: switch (provider.state) {
          FaceScanState.success => _SuccessBody(provider: provider),
          FaceScanState.backendError => _ErrorBody(provider: provider),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

// ─── Success ───────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.provider});
  final FaceScannerProvider provider;

  @override
  Widget build(BuildContext context) {
    final response = provider.successResponse!;

    // Split the markdown-ish analysis into numbered sections for display
    final sections = _parseSections(response.analysis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF22C55E), size: 40),
                  ),
                ),

                const SizedBox(height: 24),

                // Heading
                Text(response.message, textAlign: TextAlign.center, style: AppTextStyles.scannerHeading),

                const SizedBox(height: 8),

                // Timestamp
                Text(
                  _formatTimestamp(response.timestamp),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.scannerSubtitle,
                ),

                const SizedBox(height: 32),

                // Snapshot thumbnail
                if (provider.snapshot != null)
                  Center(
                    child: ClipOval(
                      child: Image.memory(provider.snapshot!, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),

                if (provider.snapshot != null) const SizedBox(height: 32),

                // Analysis sections
                ...sections.map((s) => _AnalysisCard(section: s)),

                const SizedBox(height: 24),

                // Privacy pill
                _PrivacyPill(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Footer actions
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Scan again',
                  color: AppColors.lightGray,
                  borderRadius: 24,
                  onPressed: () {
                    context.read<FaceScannerProvider>().retry();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: 'Done',
                  color: AppColors.primary,
                  borderRadius: 24,
                  onPressed: () => Routes.home.go(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }

  /// Splits the raw analysis string into titled sections.
  /// Handles lines like "1. **Title:** body text"
  List<_Section> _parseSections(String raw) {
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final sections = <_Section>[];

    for (final line in lines) {
      final trimmed = line.trim();

      // Match "1.  **Title:** rest" or "1. **Title:** rest"
      final numberedMatch = RegExp(r'^\d+\.\s+\*\*(.+?)\*\*[:\s]*(.*)$').firstMatch(trimmed);

      if (numberedMatch != null) {
        sections.add(_Section(title: numberedMatch.group(1)!.trim(), body: numberedMatch.group(2)!.trim()));
      } else if (sections.isNotEmpty) {
        // Continuation line — append to last section
        sections.last.body += ' $trimmed';
      } else {
        // Fallback — plain text section
        sections.add(_Section(title: '', body: trimmed));
      }
    }

    return sections;
  }
}

class _Section {
  final String title;
  String body;
  _Section({required this.title, required this.body});
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.section});
  final _Section section;

  // Color per section title keyword
  Color get _accentColor {
    final t = section.title.toLowerCase();
    if (t.contains('disclaimer')) return const Color(0xFFF59E0B);
    if (t.contains('risk')) return const Color(0xFF3B82F6);
    return AppColors.primary;
  }

  Color get _bgColor {
    final t = section.title.toLowerCase();
    if (t.contains('disclaimer')) return const Color(0xFFFFFBEB);
    if (t.contains('risk')) return const Color(0xFFEFF6FF);
    return const Color(0xFFF0FDF4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty) ...[
            // Title pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(9999)),
              child: Text(
                section.title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _accentColor),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            section.body,
            style: AppTextStyles.statusIndicatorValue.copyWith(color: const Color(0xFF334155), height: 1.55),
          ),
        ],
      ),
    );
  }
}

// ─── Error ─────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.provider});
  final FaceScannerProvider provider;

  @override
  Widget build(BuildContext context) {
    final response = provider.backendError!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                    child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 40),
                  ),
                ),

                const SizedBox(height: 24),

                Text('Verification Failed', textAlign: TextAlign.center, style: AppTextStyles.scannerHeading),

                const SizedBox(height: 8),

                Text(
                  'We found ${response.details.length} '
                  'issue${response.details.length == 1 ? '' : 's'} '
                  'with your submission. Please review and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.scannerSubtitle,
                ),

                const SizedBox(height: 32),

                ...response.details.indexed.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ErrorCard(detail: e.$2, index: e.$1),
                  ),
                ),

                const SizedBox(height: 12),
                _PrivacyPill(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  color: AppColors.lightGray,
                  borderRadius: 24,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: 'Try again',
                  color: AppColors.primary,
                  borderRadius: 24,
                  onPressed: () {
                    context.read<FaceScannerProvider>().retry();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.detail, required this.index});
  final ScanErrorDetail detail;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.locationLabel.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      detail.locationLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(detail.msg, style: AppTextStyles.statusIndicatorValue.copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(detail.type, style: AppTextStyles.statusIndicatorLabel.copyWith(color: const Color(0xFF94A3B8))),
                if (detail.input != null && detail.input!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      'Input: ${detail.input}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared ────────────────────────────────────────────────────────────────

class _PrivacyPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(9999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 12),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                'Your data is encrypted and never shared',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
