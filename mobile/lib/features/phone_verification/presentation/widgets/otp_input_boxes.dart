import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class OtpInputBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final String? prefillCode;

  const OtpInputBoxes({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.prefillCode,
  });

  @override
  State<OtpInputBoxes> createState() => OtpInputBoxesState();
}

class OtpInputBoxesState extends State<OtpInputBoxes>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticIn),
    );

    if (widget.prefillCode != null && widget.prefillCode!.length == widget.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefill(widget.prefillCode!);
      });
    }
  }

  @override
  void didUpdateWidget(OtpInputBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prefillCode != null &&
        widget.prefillCode != oldWidget.prefillCode &&
        widget.prefillCode!.length == widget.length) {
      _prefill(widget.prefillCode!);
    }
  }

  void _prefill(String code) {
    for (int i = 0; i < widget.length && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
    final fullCode = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(fullCode);
    if (fullCode.length == widget.length) {
      widget.onCompleted(fullCode);
    }
  }

  void clearAll() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
    if (_focusNodes.isNotEmpty && _focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }

  void shake() {
    _shakeController?.forward().then((_) {
      _shakeController?.reverse();
    });
  }

  void shakeAndClear() {
    shake();
    Future.delayed(const Duration(milliseconds: 300), () {
      clearAll();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _shakeController?.dispose();
    super.dispose();
  }

  String get currentCode => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      if (value.length == widget.length) {
        for (int i = 0; i < widget.length; i++) {
          _controllers[i].text = value[i];
        }
        setState(() {});
        final fullCode = _controllers.map((c) => c.text).join();
        widget.onChanged?.call(fullCode);
        widget.onCompleted(fullCode);
        return;
      }
      _controllers[index].text = value[value.length - 1];
    }

    final fullCode = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(fullCode);

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (fullCode.length == widget.length) {
      widget.onCompleted(fullCode);
    }

    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation!.value, 0),
          child: child,
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final hasValue = _controllers[index].text.isNotEmpty;
            final isFocused = _focusNodes[index].hasFocus;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 4,
                  right: index == widget.length - 1 ? 0 : 4,
                ),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(index, event),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: widget.hasError
                              ? AppColors.error
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: widget.hasError
                              ? AppColors.error
                              : hasValue
                                  ? AppColors.primary
                                  : AppColors.border,
                          width: hasValue ? 2 : 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: widget.hasError
                              ? AppColors.error
                              : AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
