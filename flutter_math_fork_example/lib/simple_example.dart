import 'package:flutter/material.dart';
import 'package:flutter_math_fork/math_keyboard.dart';

/// Widget for a page demonstrating how to use the `math_keyboard` package.
class KeyboardSimpledPage extends StatefulWidget {
  /// Creates a [KeyboardSimpledPage] widget.
  const KeyboardSimpledPage({
    final Key? key,
  }) : super(key: key);

  @override
  _KeyboardSimpledPageState createState() => _KeyboardSimpledPageState();
}

class _KeyboardSimpledPageState extends State<KeyboardSimpledPage> {
  var _currentIndex = 0;

  @override
  Widget build(final BuildContext context) {
    Widget child;
    if (_currentIndex == 0) {
      child = const _MathFieldTextFieldExample();
    } else if (_currentIndex == 1) {
      child = const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'The math keyboard should be automatically dismissed when '
            'switching to this page.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      child = const _ClearableAutofocusExample();
    }
    return MathKeyboardViewInsets(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Math keyboard demo'),
        ),
        body: Column(
          children: [
            Expanded(
              child: child,
            ),
            // We insert the bottom navigation bar here instead of the
            // bottomNavigationBar parameter in order to make it stick on
            // top of the keyboard.
            BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (final index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  label: 'Fields',
                  icon: Icon(Icons.text_fields_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Empty',
                  icon: Icon(Icons.hourglass_empty_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Autofocus',
                  icon: Icon(Icons.auto_awesome),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays an example column with different math fields and a text
/// field for comparison.
class _MathFieldTextFieldExample extends StatelessWidget {
  /// Constructs a [_MathFieldTextFieldExample] widget.
  const _MathFieldTextFieldExample({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: MathField(
              variables: const ['a', 's', 'c'],
              onChanged: (final value) {
                String expression;
                try {
                  expression = '${TeXParser(value).parse()}';
                } on Object catch (_) {
                  expression = 'invalid input';
                }

                print('input expression: $value\n'
                    'converted expression: $expression');
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: MathField(
              keyboardType: MathKeyboardType.numberOnly,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for an example math field in a column that can be cleared from the
/// outside and automatically receives focus.
class _ClearableAutofocusExample extends StatefulWidget {
  /// Constructs a [_ClearableAutofocusExample] widget.
  const _ClearableAutofocusExample({final Key? key}) : super(key: key);

  @override
  _ClearableAutofocusExampleState createState() => _ClearableAutofocusExampleState();
}

class _ClearableAutofocusExampleState extends State<_ClearableAutofocusExample> {
  late final _controller = MathFieldEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: MathField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                suffix: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: GestureDetector(
                    onTap: _controller.clear,
                    child: const Icon(
                      Icons.highlight_remove_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'The math field on this tab should automatically receive focus.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
