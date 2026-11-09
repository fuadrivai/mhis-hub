import 'package:fl_mhis_hr/library/common.dart';
import 'package:fl_mhis_hr/widget/auth_button.dart';
import 'package:fl_mhis_hr/widget/gradient_button_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth button uses red gradient and preserves custom colors',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          AuthButton(onTap: () {}, text: 'Default'),
          AuthButton(onTap: () {}, text: 'Custom', color: Colors.blue),
        ]),
      ),
    ));

    BoxDecoration decorationFor(String text) {
      final container = tester.widget<Container>(find
          .ancestor(
            of: find.text(text),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first);
      return container.decoration! as BoxDecoration;
    }

    expect(decorationFor('Default').gradient, Common.redGradient);
    expect(decorationFor('Custom').gradient, isNull);
    expect(decorationFor('Custom').color, Colors.blue);
  });

  testWidgets('disabled button background does not show active gradient',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GradientButtonBackground(enabled: false, child: SizedBox()),
    ));
    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(GradientButtonBackground),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    expect(decoration.gradient, isNull);
    expect(decoration.color, Colors.grey.shade400);
  });
}
