/// health/health_parser.dart
/// Pure parse functions — no state, no side-effects.
/// Each function returns null when the data is absent, invalid, or out of range.

library;

import 'dart:developer';
import 'package:light_x/features/scan/logic/models/health_data_snapshot.dart';

const _tag = 'HealthParser';

// ── Validation bounds ─────────────────────────────────────────────────────────

bool validHr(int v) => v >= 30 && v <= 220;
bool validSpo2(int v) => v >= 70 && v <= 100;
bool validBattery(int v) => v >= 0 && v <= 100;
bool validSystolic(int v) => v >= 60 && v <= 250;
bool validDiastolic(int v) => v >= 40 && v <= 150;

// ── Standard GATT: Heart Rate 0x2A37 ─────────────────────────────────────────

int? parseHeartRate(List<int> data) {
  if (data.isEmpty) return null;
  final isUint16 = (data[0] & 0x01) != 0;
  if (data.length < (isUint16 ? 3 : 2)) return null;
  final bpm = isUint16 ? ((data[2] << 8) | data[1]) : data[1];
  return validHr(bpm) ? bpm : null;
}

// ── Standard GATT: PLX SpO2 0x2A5F / 0x2A5E ──────────────────────────────────

double? parsePlxSpo2(List<int> data) {
  if (data.length < 3) return null;
  final v = _sfloat(data[1], data[2]);
  return (v != null && v > 50 && v <= 100) ? v : null;
}

// ── Standard GATT: Blood Pressure 0x2A35 ─────────────────────────────────────
// Flags byte layout (bit 0): 0 = mmHg, 1 = kPa
// Bytes 1-2: Systolic  (SFLOAT)
// Bytes 3-4: Diastolic (SFLOAT)
// Bytes 5-6: Mean arterial pressure (SFLOAT) — optional, check flags bit 2

BloodPressure? parseBloodPressure(List<int> data) {
  if (data.length < 7) return null;

  final flags = data[0];
  final isKpa = (flags & 0x01) != 0; // true = kPa, we only handle mmHg for now

  double? sys = _sfloat(data[1], data[2]);
  double? dia = _sfloat(data[3], data[4]);

  if (sys == null || dia == null) return null;

  // Convert kPa → mmHg if needed (1 kPa ≈ 7.5006 mmHg)
  if (isKpa) {
    sys = sys * 7.5006;
    dia = dia * 7.5006;
  }

  final systolic = sys.round();
  final diastolic = dia.round();

  if (!validSystolic(systolic) || !validDiastolic(diastolic)) return null;

  // Mean arterial pressure — present only if flags bit 2 is set
  int? map;
  if ((flags & 0x04) != 0 && data.length >= 9) {
    final mapVal = _sfloat(data[5], data[6]);
    if (mapVal != null) map = mapVal.round();
  }

  return BloodPressure(systolic: systolic, diastolic: diastolic, meanArterial: map);
}

// ── Standard GATT: Battery 0x2A19 ────────────────────────────────────────────

int? parseBattery(List<int> data) {
  if (data.isEmpty) return null;
  return validBattery(data[0]) ? data[0] : null;
}

// ── Proprietary packet parser ─────────────────────────────────────────────────
// Many cheap watches pack HR, SpO2, and sometimes BP into a single notification.
// We try common layouts in order and return the first plausible match.

class ProprietaryResult {
  final int? heartRate;
  final double? spo2;
  final BloodPressure? bloodPressure;

  const ProprietaryResult({this.heartRate, this.spo2, this.bloodPressure});

  bool get hasData => heartRate != null || spo2 != null || bloodPressure != null;
}

ProprietaryResult parseProprietary(List<int> data, {required String label}) {
  if (data.length < 2) return const ProprietaryResult();

  // ── BP layouts (checked first — more specific, less likely to false-positive)

  // BP Layout A: [type=0x01, sys, dia, ...]  — sys/dia as plain bytes
  if (data.length >= 3 && data[0] == 0x01 && validSystolic(data[1]) && validDiastolic(data[2])) {
    log('$label BP layout-A sys=${data[1]} dia=${data[2]}', name: _tag);
    return ProprietaryResult(
      bloodPressure: BloodPressure(systolic: data[1], diastolic: data[2]),
    );
  }

  // BP Layout B: [type, sys_hi, sys_lo, dia_hi, dia_lo]  — 16-bit each
  if (data.length >= 5) {
    final sys = (data[1] << 8) | data[2];
    final dia = (data[3] << 8) | data[4];
    if (validSystolic(sys) && validDiastolic(dia)) {
      log('$label BP layout-B sys=$sys dia=$dia', name: _tag);
      return ProprietaryResult(
        bloodPressure: BloodPressure(systolic: sys, diastolic: dia),
      );
    }
  }

  // ── HR + SpO2 layouts

  // Layout A: [type, hr, spo2, ...]
  if (data.length >= 3 && validHr(data[1]) && validSpo2(data[2])) {
    log('$label HR+SpO2 layout-A HR=${data[1]} SpO2=${data[2]}', name: _tag);
    return ProprietaryResult(heartRate: data[1], spo2: data[2].toDouble());
  }

  // Layout B: [seq, 0x00, hr, 0x00, spo2]
  if (data.length >= 5 && validHr(data[2]) && validSpo2(data[4])) {
    log('$label HR+SpO2 layout-B HR=${data[2]} SpO2=${data[4]}', name: _tag);
    return ProprietaryResult(heartRate: data[2], spo2: data[4].toDouble());
  }

  // Layout C: 16-bit HR at [1..2], SpO2 at [3]
  if (data.length >= 4) {
    final hr16 = (data[1] << 8) | data[2];
    if (validHr(hr16) && validSpo2(data[3])) {
      log('$label HR+SpO2 layout-C HR=$hr16 SpO2=${data[3]}', name: _tag);
      return ProprietaryResult(heartRate: hr16, spo2: data[3].toDouble());
    }
  }

  // Layout D: scan all adjacent pairs — catch-all
  for (int i = 0; i < data.length - 1; i++) {
    if (validHr(data[i]) && validSpo2(data[i + 1])) {
      log('$label HR+SpO2 layout-D[+$i] HR=${data[i]} SpO2=${data[i + 1]}', name: _tag);
      return ProprietaryResult(heartRate: data[i], spo2: data[i + 1].toDouble());
    }
  }

  return const ProprietaryResult();
}

// ── IEEE-11073 SFLOAT ─────────────────────────────────────────────────────────

double? _sfloat(int lsb, int msb) {
  final raw = (msb << 8) | lsb;
  int mantissa = raw & 0x0FFF;
  int exponent = raw >> 12;
  if (mantissa >= 0x0800) mantissa -= 0x1000;
  if (exponent >= 0x08) exponent -= 0x10;
  if (mantissa == 0x07FF || mantissa == 0x0800 || mantissa == 0x07FE) {
    return null;
  }
  double result = 1.0;
  if (exponent >= 0) {
    for (int i = 0; i < exponent; i++) result *= 10;
  } else {
    for (int i = 0; i < -exponent; i++) result /= 10;
  }
  return mantissa * result;
}
