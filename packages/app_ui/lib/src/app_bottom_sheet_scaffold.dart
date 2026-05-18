import 'package:flutter/material.dart';

/// Standard bottom sheet layout used for entry and edit sheets.
///
/// Handles padding, keyboard avoidance, and a consistent title row.
/// Wrap the sheet's body in [child] and place a submit button in [action].
class AppBottomSheetScaffold extends StatelessWidget {
  const AppBottomSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;

  /// Typically an [AppPrimaryButton]. Pinned above the safe-area bottom.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomPadding =
        (viewInsets.bottom > 0 ? viewInsets.bottom : MediaQuery.paddingOf(context).bottom) + 16;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          child,
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
