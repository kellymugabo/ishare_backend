import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user verification state
final userVerifiedProvider = StateProvider<bool>((ref) => false);
