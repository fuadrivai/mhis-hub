import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/gradient_button_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child, this.onBack});

  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 165 + MediaQuery.paddingOf(context).top,
                  child: IgnorePointer(
                    child: CustomPaint(
                      key: const ValueKey('auth-top-wave'),
                      painter: _TopWavePainter(),
                    ),
                  ),
                ),
                if (!keyboardVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 155,
                    child: IgnorePointer(
                      child: CustomPaint(painter: _BottomWavePainter()),
                    ),
                  ),
                SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight -
                                MediaQuery.paddingOf(context).vertical)
                            .clamp(0, double.infinity),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 165,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                if (onBack != null)
                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    child: IconButton(
                                      tooltip: 'Back',
                                      onPressed: onBack,
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                Positioned(
                                  right: 32,
                                  top: 16,
                                  child: Container(
                                    width: 94,
                                    height: 94,
                                    // Logo artwork sits ~3.5% left of its canvas center
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 13, 10, 13),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.danger
                                              .withValues(alpha: 0.1),
                                          blurRadius: 16,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo-hub.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 12, 28, 170),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.danger,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      );
}

InputDecoration authFieldDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.blackshade),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide:
            BorderSide(color: Color.fromARGB(255, 158, 106, 119), width: 1.5),
      ),
    );

class AuthAction extends StatelessWidget {
  const AuthAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: GradientButtonBackground(
            enabled: onPressed != null && !isLoading,
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
                onPressed: isLoading ? null : onPressed,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(label),
              ),
            ),
          ),
        ),
      );
}

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pale = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..cubicTo(size.width * 0.68, size.height * 0.8, size.width * 0.72,
          size.height * 0.18, size.width * 0.25, 0)
      ..close();
    canvas.drawPath(pale, Paint()..color = const Color(0xFFF9E5EB));
    final accent = Path()
      ..moveTo(size.width * 0.48, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.72)
      ..cubicTo(size.width * 0.82, size.height * 0.57, size.width * 0.78,
          size.height * 0.12, size.width * 0.48, 0)
      ..close();
    canvas.drawPath(
      accent,
      Paint()
        ..shader = Common.redGradient.createShader(Offset.zero & size)
        ..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pale = Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(size.width * 0.3, size.height * 0.58, size.width * 0.35,
          size.height * 1.12, size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pale, Paint()..color = const Color(0xFFF9E5EB));
    final accent = Path()
      ..moveTo(0, 0)
      ..cubicTo(size.width * 0.34, size.height * 0.08, size.width * 0.2,
          size.height * 0.96, size.width * 0.74, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      accent,
      Paint()
        ..shader = Common.redGradient.createShader(Offset.zero & size)
        ..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
