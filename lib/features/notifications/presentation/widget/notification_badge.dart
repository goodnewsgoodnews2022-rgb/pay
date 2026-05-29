import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double? size;

  const NotificationBadge({
    required this.count,
    required this.child,
    this.size = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: BoxConstraints(
                minWidth: size!,
                minHeight: size!,
              ),
              decoration: const BoxDecoration(
                color: AppColors.dev2Green,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
