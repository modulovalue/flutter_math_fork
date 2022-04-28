import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart' show HoldDetector;

import 'node.dart';

/// Widget for keyboard buttons of the math keyboard.
///
/// These buttons have a tap response that is defined in the following way:
///
/// * Brighten up the background using white with `1 / 3` opacity.
/// * With an ease in out curve.
/// * For a duration of 50ms in and 200ms out.
/// * And a rounded rectangle shape with a border radius of 8px and padding
///   of 4px.
class KeyboardButton extends StatefulWidget {
  /// Constructs a [KeyboardButton] widget.
  const KeyboardButton({
    required final this.child,
    final Key? key,
    final this.onTap,
    final this.onHold,
    final this.color,
  }) : super(key: key);

  /// Called when the keyboard button is tapped.
  final VoidCallback? onTap;

  /// Called periodically when the keyboard button is held down.
  final VoidCallback? onHold;

  /// The button base color.
  final Color? color;

  /// The child widget that the keyboard button interaction is wrapped about.
  final Widget child;

  @override
  _KeyboardButtonState createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<KeyboardButton>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    duration: const Duration(milliseconds: 50),
    reverseDuration: const Duration(milliseconds: 200),
    vsync: this,
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(final TapDownDetails details) {
    _animationController.forward();
  }

  Future<void> _handleTapUp([final TapUpDetails? details]) async {
    await _animationController.reverse(from: 1);
  }

  void _handleHold() {
    _animationController.value = 1;
    widget.onHold?.call();
  }

  void _handleTapCancel() {
    _animationController.value = 0;
  }

  @override
  Widget build(final BuildContext context) {
    Widget result = RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        _AlwaysWinningGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            _AlwaysWinningGestureRecognizer>(
              () => _AlwaysWinningGestureRecognizer(),
              (final _AlwaysWinningGestureRecognizer instance) {
            instance
              ..onTap = widget.onTap
              ..onTapUp = _handleTapUp
              ..onTapDown = _handleTapDown
              ..onTapCancel = _handleTapCancel;
          },
        ),
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.color,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (final context, final child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(
                    Curves.easeInOut.transform(_animationController.value) / 3,
                  ),
                ),
                child: Center(
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
    if (widget.onHold != null) {
      result = HoldDetector(
        onHold: _handleHold,
        onCancel: _handleTapUp,
        holdTimeout: const Duration(milliseconds: 100),
        child: result,
      );
    }
    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      child: result,
    );
  }
}

/// A gesture recognizer that wins in every arena.
///
/// This prevents buttons with sqrt's from not responding.
class _AlwaysWinningGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(final int pointer) {
    acceptGesture(pointer);
  }
}

/// Class representing a button configuration.
abstract class KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const KeyboardButtonConfig({
    this.flex,
    this.keyboardCharacters = const [],
  });

  /// Optional flex.
  final int? flex;

  /// The list of [RawKeyEvent.character] that should trigger this keyboard
  /// button on a physical keyboard.
  ///
  /// Note that the case of the characters is ignored.
  ///
  /// Special keyboard keys like backspace and arrow keys are specially handled
  /// and do *not* require this to be set.
  ///
  /// Must not be `null` but can be empty.
  final List<String> keyboardCharacters;
}

// ignore: comment_references
/// Class representing a button configuration for a [FunctionButton].
class BasicKeyboardButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const BasicKeyboardButtonConfig({
    required final this.label,
    required final this.value,
    final this.args,
    final this.asTex = false,
    final this.highlighted = false,
    final List<String> keyboardCharacters = const [],
    final int? flex,
  }) : super(
          flex: flex,
          keyboardCharacters: keyboardCharacters,
        );

  /// The label of the button.
  final String label;

  /// The value in tex.
  final String value;

  /// List defining the arguments for the function behind this button.
  final List<TeXArg>? args;

  /// Whether to display the label as TeX or as plain text.
  final bool asTex;

  /// The highlight level of this button.
  final bool highlighted;
}

/// Class representing a button configuration of the Delete Button.
class DeleteButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  DeleteButtonConfig({final int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Previous Button.
class PreviousButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  PreviousButtonConfig({final int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Next Button.
class NextButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  NextButtonConfig({final int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Submit Button.
class SubmitButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [SubmitButtonConfig].
  SubmitButtonConfig({final int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Page Toggle Button.
class PageButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [PageButtonConfig].
  const PageButtonConfig({final int? flex}) : super(flex: flex);
}

/// List of keyboard button configs for the digits from 0-9.
///
/// List access from 0 to 9 will return the appropriate digit button.
final _digitButtons = [
  for (var i = 0; i < 10; i++)
    BasicKeyboardButtonConfig(
      label: '$i',
      value: '$i',
      keyboardCharacters: ['$i'],
    ),
];

const _decimalButton = BasicKeyboardButtonConfig(
  label: '.',
  value: '.',
  keyboardCharacters: ['.', ','],
  highlighted: true,
);

const _subtractButton = BasicKeyboardButtonConfig(
  label: '−',
  value: '-',
  keyboardCharacters: ['-'],
  highlighted: true,
);

/// Keyboard showing extended functionality.
final functionKeyboard = [
  [
    const BasicKeyboardButtonConfig(
      label: r'\frac{\Box}{\Box}',
      value: r'\frac',
      args: [TeXArg.braces, TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Box^2',
      value: '^2',
      args: [TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Box^{\Box}',
      value: '^',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: [
        '^',
        // This is a workaround for keyboard layout that use ^ as a toggle key.
        // In that case, "Dead" is reported as the character (e.g. for German
        // keyboards).
        'Dead',
      ],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sin',
      value: r'\sin(',
      asTex: true,
      keyboardCharacters: ['s'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sin^{-1}',
      value: r'\sin^{-1}(',
      asTex: true,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\sqrt{\Box}',
      value: r'\sqrt',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: ['r'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sqrt[\Box]{\Box}',
      value: r'\sqrt',
      args: [TeXArg.brackets, TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\cos',
      value: r'\cos(',
      asTex: true,
      keyboardCharacters: ['c'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\cos^{-1}',
      value: r'\cos^{-1}(',
      asTex: true,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\log_{\Box}(\Box)',
      value: r'\log_',
      asTex: true,
      args: [TeXArg.braces, TeXArg.parentheses],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\ln(\Box)',
      value: r'\ln(',
      asTex: true,
      keyboardCharacters: ['l'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\tan',
      value: r'\tan(',
      asTex: true,
      keyboardCharacters: ['t'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\tan^{-1}',
      value: r'\tan^{-1}(',
      asTex: true,
    ),
  ],
  [
    const PageButtonConfig(flex: 3),
    const BasicKeyboardButtonConfig(
      label: '(',
      value: '(',
      highlighted: true,
      keyboardCharacters: ['('],
    ),
    const BasicKeyboardButtonConfig(
      label: ')',
      value: ')',
      highlighted: true,
      keyboardCharacters: [')'],
    ),
    PreviousButtonConfig(),
    NextButtonConfig(),
    DeleteButtonConfig(),
  ],
];

/// Standard keyboard for math expression input.
final standardKeyboard = [
  [
    _digitButtons[7],
    _digitButtons[8],
    _digitButtons[9],
    const BasicKeyboardButtonConfig(
      label: '×',
      value: r'\cdot',
      keyboardCharacters: ['*'],
      highlighted: true,
    ),
    const BasicKeyboardButtonConfig(
      label: '÷',
      value: r'\frac',
      keyboardCharacters: ['/'],
      args: [TeXArg.braces, TeXArg.braces],
      highlighted: true,
    ),
  ],
  [
    _digitButtons[4],
    _digitButtons[5],
    _digitButtons[6],
    const BasicKeyboardButtonConfig(
      label: '+',
      value: '+',
      keyboardCharacters: ['+'],
      highlighted: true,
    ),
    _subtractButton,
  ],
  [
    _digitButtons[1],
    _digitButtons[2],
    _digitButtons[3],
    _decimalButton,
    DeleteButtonConfig(),
  ],
  [
    const PageButtonConfig(),
    _digitButtons[0],
    PreviousButtonConfig(),
    NextButtonConfig(),
    SubmitButtonConfig(),
  ],
];

/// Keyboard getting shown for number input only.
final numberKeyboard = [
  [
    _digitButtons[7],
    _digitButtons[8],
    _digitButtons[9],
    _subtractButton,
  ],
  [
    _digitButtons[4],
    _digitButtons[5],
    _digitButtons[6],
    _decimalButton,
  ],
  [
    _digitButtons[1],
    _digitButtons[2],
    _digitButtons[3],
    DeleteButtonConfig(),
  ],
  [
    PreviousButtonConfig(),
    _digitButtons[0],
    NextButtonConfig(),
    SubmitButtonConfig(),
  ],
];
