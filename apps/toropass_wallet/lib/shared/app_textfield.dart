import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/themes/colors.dart';
import '../../core/config/themes/styles.dart';
import '../../core/utilities/animations.dart';
import '../../core/utilities/extensions/numbers.dart';

class AppTextfield extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final TextStyle? style;
  final bool enabled;
  final bool obscureText;
  final int minLines;
  final int maxLines;
  final String hint;
  final int? maxLength;
  final String? error;
  final Widget? prefix;
  final Widget? suffix;
  final double textHeight;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const AppTextfield({
    super.key,
    this.controller,
    required this.hint,
    this.style,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textHeight = 1.2,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    this.error,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.focusNode,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        maxLength: widget.maxLength,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        controller: widget.enabled ? widget.controller : null,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        inputFormatters: widget.inputFormatters,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style:
            widget.style ??
            context.appStyles.body.copyWith(height: widget.textHeight),
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: appColors.primary.withAlpha(12),
          hintText: widget.hint,
          errorText: widget.error,
          prefixIcon: widget.prefix != null
              ? AnimatedSwitcher(
                  duration: Animations.duration,
                  transitionBuilder: Animations.widgetTransition,
                  child: widget.prefix!,
                )
              : null,
          suffixIcon: widget.suffix != null
              ? AnimatedSwitcher(
                  duration: Animations.duration,
                  transitionBuilder: Animations.widgetTransition,
                  child: widget.suffix!,
                )
              : null,
          hintStyle: context.appStyles.body.copyWith(
            color: AppColors.of(context).text.withAlpha(70),
          ),
        ),
      ),
    );
  }
}

class TextfieldLabel extends StatelessWidget {
  final String label;
  final double spacing;
  final bool important;

  const TextfieldLabel({
    super.key,
    this.spacing = 7,
    this.important = false,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final appStyles = context.appStyles;
    final appColors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.height),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          5.horizontalSpacer,
          Text(
            label,
            style: appStyles.caption.copyWith(
              color: appColors.text.withAlpha(200),
            ),
          ),
          if (important) ...[
            5.horizontalSpacer,
            Text(
              "*",
              style: appStyles.caption.copyWith(color: appColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
