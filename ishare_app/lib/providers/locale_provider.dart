import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the current Locale. Defaults to English.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));