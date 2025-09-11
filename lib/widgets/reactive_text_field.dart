import 'package:flutter/material.dart';

class ReactiveTextField extends StatefulWidget {
  const ReactiveTextField({
    super.key,
    required this.hintText,
    required String? text,
    this.errorText,
    required this.onChanged,
    this.trailing,
    this.enabled = true,
    this.onTap,
    this.leading,
    this.textInputType,
    this.obscureText = false,
  }) : text = text ?? '';

  final String hintText;

  final String text;

  final String? errorText;
  final Widget? trailing;
  final Widget? leading;

  final void Function(String) onChanged;
  final bool enabled;
  final void Function()? onTap;

  final TextInputType? textInputType;
  final bool obscureText;

  @override
  State<ReactiveTextField> createState() => _ReactiveTextFieldState();
}

class _ReactiveTextFieldState extends State<ReactiveTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
  }

  @override
  void didUpdateWidget(covariant ReactiveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is an important part!
    // Without this check, there will be an infinite loop!
    if (widget.text != _controller.text) {
      _controller.text = widget.text;
      // We remove focus, because the value has been set
      // from a different source.

      unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void unfocus() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        width: 1,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
      borderRadius: BorderRadius.circular(24),
    );
    return TextSelectionTheme(
      data: const TextSelectionThemeData(
          // selectionHandleColor: PHColors.grey5,
          // cursorColor: PHColors.grey5,
          // selectionColor: PHColors.myGreen1,
          ),
      child: TextField(
          // groupId: widget.hashCode,
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          keyboardType: widget.textInputType,
          onTapOutside: (event) {
            unfocus();
          },
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            suffixIcon: widget.trailing ??
                (widget.errorText != null ? const Icon(Icons.error) : null),
            // suffixIconColor: widget.errorText != null ? PHColors.red : null,
            prefixIcon: (widget.leading != null)
                ? SizedBox.square(
                    dimension: 24,
                    child: Center(child: widget.leading),
                  )
                : null,
            contentPadding: const EdgeInsets.all(16),
            errorText: widget.errorText,
            errorMaxLines: 3,
            // errorStyle: PHTextStyles.errorTextStyle,
            // hintStyle: PHTextStyles.bodySmallRegular.copyWith(
            //   color: PHColors.grey4,
            // ),
            hintText: widget.hintText,
            filled: true,
            focusedBorder: outlineInputBorder.copyWith(
              borderSide: const BorderSide(
                  // color: PHColors.myGreen5,
                  ),
            ),
            focusedErrorBorder: outlineInputBorder.copyWith(
                borderSide: const BorderSide(
                    // color: PHColors.red,
                    )),
            enabledBorder: outlineInputBorder,
            border: outlineInputBorder,
            errorBorder: outlineInputBorder.copyWith(
                borderSide: const BorderSide(
                    // color: PHColors.red,
                    )),
            disabledBorder: outlineInputBorder,
          )),
    );
  }
}
