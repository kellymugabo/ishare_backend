import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final double size;
  final Color color;

  const VerificationBadge({
    super.key, 
    this.size = 16, 
    this.color = Colors.blue, // The classic "Blue Tick" color
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Verified Driver", // Shows when long-pressed
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        // White border makes it stand out on any background
        padding: const EdgeInsets.all(1), 
        child: Icon(
          Icons.verified_rounded,
          size: size,
          color: color,
        ),
      ),
    );
  }
}