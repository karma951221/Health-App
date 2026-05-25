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
    this.heightFactor,
  });

  final String title;
  final Widget child;

  /// Typically an [AppPrimaryButton]. Pinned above the safe-area bottom.
  final Widget? action;

  /// Fraction (0–1) of the screen height the sheet should occupy. When null
  /// the sheet sizes to its content; when set, [child] expands to fill the
  /// space and [action] stays pinned to the bottom.
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomPadding =
        (viewInsets.bottom > 0 ? viewInsets.bottom : MediaQuery.paddingOf(context).bottom) + 16;
    final expand = heightFactor != null;

    final padded = Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          if (expand)
            Expanded(child: SingleChildScrollView(child: child))
          else
            child,
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );

    if (!expand) return padded;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * heightFactor!,
      child: padded,
    );
  }
}
