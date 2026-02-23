// import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1C58D9);

  // Neutral Black
  static const Color neutralBlack50 = Color(0xFFE9E9E9);
  static const Color neutralBlack100 = Color(0xFFB9B9B9);
  static const Color neutralBlack200 = Color(0xFF989898);
  static const Color neutralBlack300 = Color(0xFF686868);
  static const Color neutralBlack400 = Color(0xFF4B4B4B);
  static const Color neutralBlack500 = Color(0xFF1E1E1E);
  static const Color neutralBlack600 = Color(0xFF1B1B1B);
  static const Color neutralBlack700 = Color(0xFF151515);
  static const Color neutralBlack800 = Color(0xFF111111);
  static const Color neutralBlack900 = Color(0xFF0D0D0D);

  // Neutral White
  static const Color neutralWhite50 = Color(0xFFFEFEFE);
  static const Color neutralWhite100 = Color(0xFFFAFAFA);
  static const Color neutralWhite200 = Color(0xFFF8F8F8);
  static const Color neutralWhite300 = Color(0xFFF5F5F5);
  static const Color neutralWhite400 = Color(0xFFF3F3F3);
  static const Color neutralWhite500 = Color(0xFFF0F0F0);
  static const Color neutralWhite600 = Color(0xFFDADADA);
  static const Color neutralWhite700 = Color(0xFFAAAAAA);
  static const Color neutralWhite800 = Color(0xFF848484);
  static const Color neutralWhite900 = Color(0xFF656565);

  // Red
  static const Color red50 = Color(0xFFFAE6E6);
  static const Color red100 = Color(0xFFEFB0B0);
  static const Color red200 = Color(0xFFE88A8A);
  static const Color red300 = Color(0xFFDD5454);
  static const Color red400 = Color(0xFFD63333);
  static const Color red500 = Color(0xFFCC0000);
  static const Color red600 = Color(0xFFBA0000);
  static const Color red700 = Color(0xFF910000);
  static const Color red800 = Color(0xFF700000);
  static const Color red900 = Color(0xFF560000);

  // Green
  static const Color green50 = Color(0xFFE6FAE7);
  static const Color green100 = Color(0xFFB0EFB4);
  static const Color green200 = Color(0xFF8AE890);
  static const Color green300 = Color(0xFF54DD5E);
  static const Color green400 = Color(0xFF33D63E);
  static const Color green500 = Color(0xFF00CC0E);
  static const Color green600 = Color(0xFF00BA0D);
  static const Color green700 = Color(0xFF00910A);
  static const Color green800 = Color(0xFF007008);
  static const Color green900 = Color(0xFF005606);

  // ── Core palette ────────────────────────────────────────────────────────────

  static const white = Color(0xFFFFFFFF);
  static const navy = Color(0xFF09357C);

  // primary aliases
  static Color get blue => primary; // 0xFF1C58D9
  static Color get brandBlue => primary; // 0xFF1C58D9
  static Color get activeBarFill => primary; // 0xFF1C58D9
  static Color get activeBarBorder => primary;
  static Color get labelActive => primary;
  static Color get premiumBg => primary;

  // primary with opacity
  static const primaryLight = Color(0x1A1C58D9); // 10%
  static Color get blueBg => primaryLight; // same 10%
  static Color get chipBg => primaryLight; // same 10%
  static Color get progressTrack => primaryLight; // same 10%
  static const primaryShadowStrong = Color(0x331C58D9); // ~20%
  static Color get primaryShadowSoft => primaryShadowStrong; // identical hex
  static Color get sendBtnShadowStrong => primaryShadowStrong;
  static Color get scannerRingTrack => primaryShadowStrong; // same 20%
  static Color get barOverlay => primaryShadowStrong; // 0x333B82F6 ≈ kept below if distinction matters
  static const primaryShadow = Color(0x661C58D9); // 40%
  static Color get thinkingDot => primaryShadow; // same 40%
  static Color get dashedBorder => primaryShadow; // same 40%
  static Color get userAvatarBorder => primaryShadow; // 0x331C58D9 — see note*
  static const premiumBorder = Color(0x4D1C58D9); // 30%
  static Color get chipBorder => premiumBorder; // same 30%
  static Color get sendBtnBg => navy; // 0xFF09357C

  // ── Greys / neutrals ────────────────────────────────────────────────────────

  static const textPrimary = Color(0xFF0F172A);
  static Color get headingText => textPrimary; // same 0xFF0F172A

  static const textSecondary = Color(0xFF64748B);
  static Color get bodyText => textSecondary; // same 0xFF64748B
  static Color get blackGray => textSecondary; // same 0xFF64748B
  static Color get footerText => textSecondary; // same 0xFF64748B
  static Color get subtleText => textSecondary; // same 0xFF64748B

  static const textMuted = Color(0xFF94A3B8);
  static Color get lightGray => textMuted; // same 0xFF94A3B8
  static Color get labelDefault => textMuted; // same 0xFF94A3B8
  static Color get iconMuted => textMuted; // same 0xFF94A3B8

  static const textBodySecondary = Color(0xFF475569);
  static Color get textBody => textBodySecondary; // same 0xFF475569

  static const surface = Color(0xFFF8FAFC);
  static const inputBg = Color(0xFFF1F5F9);
  static Color get divider => inputBg; // same 0xFFF1F5F9
  static Color get surfaceBorder => inputBg; // same 0xFFF1F5F9

  static const pageBg = Color(0xFFF6F6F8);
  static Color get lightScaffoldBg => pageBg; // 0xFFF2F2F2 — close but distinct; kept as alias for intent

  static const border = Color(0xFFE2E8F0);
  static Color get cardBorder => border; // same 0xFFE2E8F0
  static Color get headerBorder => border; // same 0xFFE2E8F0
  static Color get gaugeTrack => border; // same 0xFFE2E8F0

  static const cardBackground = Color(0xFFFFFFFF); // same as white; alias if preferred:
  // static Color get cardBackground => white;

  // ── Opacity surfaces ────────────────────────────────────────────────────────

  static const headerBackground = Color(0xCCFFFFFF); // 80% white
  static Color get footerBg => headerBackground; // same 0xCCFFFFFF

  // ── Accent: blue bar ────────────────────────────────────────────────────────

  static const barFill = Color(0xFF3B82F6);
  // barOverlay (0x333B82F6) is a different base hue from primaryShadowStrong;
  // keep distinct if colour accuracy matters:
  static const barOverlayExact = Color(0x333B82F6);

  // ── Accent: orange ──────────────────────────────────────────────────────────

  static const orange = Color(0xFFF97316);
  static const orangeBg = Color(0x1AF97316); // 10% opacity

  // ── Accent: amber ───────────────────────────────────────────────────────────

  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0x1AF59E0B); // 10%
  static const amberBorder = Color(0x33F59E0B); // 20%
  static const amberText = Color(0xCCF59E0B); // 80%

  // ── Accent: green / status ──────────────────────────────────────────────────

  static const green = Color(0xFF22C55E);
  static const statusGreen = Color(0xFF10B981);
  static Color get connectedDot => statusGreen; // same 0xFF10B981

  static const connectedBg = Color(0xFFD1FAE5);
  static const connectedGlow = Color(0xBF34D399);
  static const connectedText = Color(0xFF059669);

  // ── Accent: red ─────────────────────────────────────────────────────────────

  static const red = Color(0xFFEF4444);

  // ── Heart ───────────────────────────────────────────────────────────────────

  static const heartBg = Color(0xFFFFF1F2);
  static const heartIcon = Color(0xFFF43F5E);
  static const heartBar1 = Color(0xFFFECDD3);
  static const heartBar2 = Color(0xFFFDA4AF);
  static const heartBar3 = Color(0xFFF43F5E);

  // ── Sleep ───────────────────────────────────────────────────────────────────

  static const sleepBg = Color(0xFFEEF2FF);
  static const sleepIcon = Color(0xFF6366F1);
  static const sleepBadgeTxt = Color(0xFF4F46E5);

  // ── Misc ────────────────────────────────────────────────────────────────────

  static const premiumBodyText = Color(0xFFEBEEF4);
  static const footerIconBg = Color(0x1A14B8A6);
  static const footerIcon = Color(0xFF14B8A6);
  static const userAvatarBg = Color(0xFF4281D6);
  static const syncBtn = Color(0xCF1C4D8D);
  static const featuredShadow = Color(0x4D4D1C8D);
}
