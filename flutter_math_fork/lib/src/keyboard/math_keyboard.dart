import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../flutter_math.dart';

import '../../math_keyboard.dart';
import 'custom_key_icons.dart';
import 'keyboard_button.dart';

/// Enumeration for the types of keyboard that a math keyboard can adopt.
///
/// This way we allow different button configurations. The user may only need to
/// input a number.
enum MathKeyboardType {
  /// Keyboard for entering complete math expressions.
  ///
  /// This shows numbers + operators and a toggle button to switch to another
  /// page with extended functions.
  expression,

  /// Keyboard for number input only.
  numberOnly,
}

/// Widget displaying the math keyboard.
class MathKeyboard extends StatelessWidget {
  /// Constructs a [MathKeyboard].
  const MathKeyboard({
    required final this.controller,
    final Key? key,
    final this.type = MathKeyboardType.expression,
    final this.variables = const [],
    final this.onSubmit,
    final this.insetsState,
    this.slideAnimation,
  }) : super(key: key);

  /// The controller for editing the math field.
  ///
  /// Must not be `null`.
  final MathFieldEditingController controller;

  /// The state for reporting the keyboard insets.
  ///
  /// If `null`, the math keyboard will not report about its bottom inset.
  final MathKeyboardViewInsetsState? insetsState;

  /// Animation that indicates the current slide progress of the keyboard.
  ///
  /// If `null`, the keyboard is always fully slided out.
  final Animation<double>? slideAnimation;

  /// The Variables a user can use.
  final List<String> variables;

  /// The Type of the Keyboard.
  final MathKeyboardType type;

  /// Function that is called when the enter / submit button is tapped.
  ///
  /// Can be `null`.
  final VoidCallback? onSubmit;

  @override
  Widget build(final BuildContext context) {
    final curvedSlideAnimation = CurvedAnimation(
      parent: slideAnimation ?? const AlwaysStoppedAnimation(1),
      curve: Curves.ease,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: const Offset(0, 0),
      ).animate(curvedSlideAnimation),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              type: MaterialType.transparency,
              child: ColoredBox(
                color: Colors.black,
                child: SafeArea(
                  top: false,
                  child: _KeyboardBody(
                    insetsState: insetsState,
                    slideAnimation: () {
                      if (slideAnimation == null) {
                        return null;
                      } else {
                        return curvedSlideAnimation;
                      }
                    }(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                        left: 4,
                        right: 4,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 5e2,
                          ),
                          child: Column(
                            children: [
                              if (type != MathKeyboardType.numberOnly)
                                _Variables(
                                  controller: controller,
                                  variables: variables,
                                ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: _Buttons(
                                  controller: controller,
                                  page1: () {
                                    if (type == MathKeyboardType.numberOnly) {
                                      return numberKeyboard;
                                    } else {
                                      return standardKeyboard;
                                    }
                                  }(),
                                  page2: () {
                                    if (type == MathKeyboardType.numberOnly) {
                                      return null;
                                    } else {
                                      return functionKeyboard;
                                    }
                                  }(),
                                  onSubmit: onSubmit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that reports about the math keyboard body's bottom inset.
class _KeyboardBody extends StatefulWidget {
  const _KeyboardBody({
    required final this.child,
    final Key? key,
    final this.insetsState,
    final this.slideAnimation,
  }) : super(key: key);

  final MathKeyboardViewInsetsState? insetsState;

  /// The animation for sliding the keyboard.
  ///
  /// This is used in the body for reporting fractional sliding progress, i.e.
  /// reporting a smaller size while sliding.
  final Animation<double>? slideAnimation;

  final Widget child;

  @override
  _KeyboardBodyState createState() => _KeyboardBodyState();
}

class _KeyboardBodyState extends State<_KeyboardBody> {
  @override
  void initState() {
    super.initState();
    widget.slideAnimation?.addListener(_handleAnimation);
  }

  @override
  void didUpdateWidget(final _KeyboardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insetsState != widget.insetsState) {
      _removeInsets(oldWidget.insetsState);
      _reportInsets(widget.insetsState);
    }
    if (oldWidget.slideAnimation != widget.slideAnimation) {
      oldWidget.slideAnimation?.removeListener(_handleAnimation);
      widget.slideAnimation?.addListener(_handleAnimation);
    }
  }

  @override
  void dispose() {
    _removeInsets(widget.insetsState);
    widget.slideAnimation?.removeListener(_handleAnimation);
    super.dispose();
  }

  void _handleAnimation() {
    _reportInsets(widget.insetsState);
  }

  void _removeInsets(final MathKeyboardViewInsetsState? insetsState) {
    if (insetsState == null) return;
    SchedulerBinding.instance!.addPostFrameCallback((final _) {
      widget.insetsState![ObjectKey(this)] = null;
    });
  }

  void _reportInsets(final MathKeyboardViewInsetsState? insetsState) {
    if (insetsState == null) return;
    SchedulerBinding.instance!.addPostFrameCallback((final _) {
      if (!mounted) return;
      final renderBox = (context.findRenderObject() as RenderBox?)!;
      insetsState[ObjectKey(this)] = renderBox.size.height * (widget.slideAnimation?.value ?? 1);
    });
  }

  @override
  Widget build(final BuildContext context) {
    _reportInsets(widget.insetsState);
    return widget.child;
  }
}

/// Widget showing the variables a user can use.
class _Variables extends StatelessWidget {
  /// Constructs a [_Variables] Widget.
  const _Variables({
    required final this.controller,
    required final this.variables,
    final Key? key,
  }) : super(key: key);

  /// The editing controller for the math field that the variables are connected
  /// to.
  final MathFieldEditingController controller;

  /// The variables to show.
  final List<String> variables;

  @override
  Widget build(final BuildContext context) {
    return Container(
      height: 54,
      color: Colors.grey[900],
      child: AnimatedBuilder(
        animation: controller,
        builder: (final context, final child) {
          return ListView.separated(
            itemCount: variables.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (final context, final index) {
              return Center(
                child: Container(
                  height: 24,
                  width: 1,
                  color: Colors.white,
                ),
              );
            },
            itemBuilder: (final context, final index) {
              return SizedBox(
                width: 56,
                child: _VariableButton(
                  name: variables[index],
                  onTap: () => controller.addLeaf('{${variables[index]}}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget displaying the buttons.
class _Buttons extends StatelessWidget {
  /// Constructs a [_Buttons] Widget.
  const _Buttons({
    required final this.controller,
    final Key? key,
    final this.page1,
    final this.page2,
    final this.onSubmit,
  }) : super(key: key);

  /// The editing controller for the math field that the variables are connected
  /// to.
  final MathFieldEditingController controller;

  /// The buttons to display.
  final List<List<KeyboardButtonConfig>>? page1;

  /// The buttons to display.
  final List<List<KeyboardButtonConfig>>? page2;

  /// Function that is called when the enter / submit button is tapped.
  ///
  /// Can be `null`.
  final VoidCallback? onSubmit;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      height: 230,
      child: AnimatedBuilder(
        animation: controller,
        builder: (final context, final child) {
          final layout = (){
            if (controller.secondPage) {
              return page2!;
            } else {
              return page1 ?? numberKeyboard;
            }
          }();
          return Column(
            children: [
              for (final row in layout)
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      for (final config in row)
                        if (config is BasicKeyboardButtonConfig)
                          _BasicButton(
                            flex: config.flex,
                            label: config.label,
                            onTap: (){
                              if (config.args != null) {
                                return () => controller.addFunction(
                                config.value,
                                config.args!,
                              );
                              } else {
                                return () => controller.addLeaf(config.value);
                              }
                            }(),
                            asTex: config.asTex,
                            highlightLevel: (){
                              if (config.highlighted) {
                                return 1;
                              } else {
                                return 0;
                              }
                            }(),
                          )
                        else if (config is DeleteButtonConfig)
                          _NavigationButton(
                            flex: config.flex,
                            icon: Icons.backspace,
                            iconSize: 22,
                            onTap: () => controller.goBack(deleteMode: true),
                          )
                        else if (config is PageButtonConfig)
                          _BasicButton(
                            flex: config.flex,
                            icon: (){
                              if (controller.secondPage) {
                                return null;
                              } else {
                                return CustomKeyIcons.key_symbols;
                              }
                            }(),
                            label: (){
                              if (controller.secondPage) {
                                return '123';
                              } else {
                                return null;
                              }
                            }(),
                            onTap: controller.togglePage,
                            highlightLevel: 1,
                          )
                        else if (config is PreviousButtonConfig)
                          _NavigationButton(
                            flex: config.flex,
                            icon: Icons.chevron_left_rounded,
                            onTap: controller.goBack,
                          )
                        else if (config is NextButtonConfig)
                          _NavigationButton(
                            flex: config.flex,
                            icon: Icons.chevron_right_rounded,
                            onTap: controller.goNext,
                          )
                        else if (config is SubmitButtonConfig)
                          _BasicButton(
                            flex: config.flex,
                            icon: Icons.keyboard_return,
                            onTap: onSubmit,
                            highlightLevel: 2,
                          ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget displaying a single keyboard button.
class _BasicButton extends StatelessWidget {
  /// Constructs a [_BasicButton].
  const _BasicButton({
    required final this.flex,
    final Key? key,
    final this.label,
    final this.icon,
    final this.onTap,
    final this.asTex = false,
    final this.highlightLevel = 0,
  })  : assert(label != null || icon != null, ""),
        super(key: key);

  /// The flexible flex value.
  final int? flex;

  /// The label for this button.
  final String? label;

  /// Icon for this button.
  final IconData? icon;

  /// Function to be called on tap.
  final VoidCallback? onTap;

  /// Show label as tex.
  final bool asTex;

  /// Whether this button should be highlighted.
  final int highlightLevel;

  @override
  Widget build(final BuildContext context) {
    Widget result;
    if (label == null) {
      result = Icon(
        icon,
        color: Colors.white,
      );
    } else if (asTex) {
      result = Math.tex(
        label!,
        options: defaultTexMathOptions(
          fontSize: 22,
          color: TexColorImpl(
            argb: Colors.white.value,
          ),
        ),
      );
    } else {
      String? symbol = label;
      if (label == '.') {
        // We want to display the decimal separator differently depending
        // on the current locale.
        symbol = decimalSeparator(context);
      }
      result = Text(
        symbol!,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      );
    }
    result = KeyboardButton(
      onTap: onTap,
      color: (){
        if (highlightLevel > 1) {
          return Theme.of(context).colorScheme.secondary;
        } else {
          if (highlightLevel == 1) {
            return Colors.grey[900];
          } else {
            return null;
          }
        }
      }(),
      child: result,
    );
    return Expanded(
      flex: flex ?? 2,
      child: result,
    );
  }
}

/// Keyboard button for navigation actions.
class _NavigationButton extends StatelessWidget {
  /// Constructs a [_NavigationButton].
  const _NavigationButton({
    required final this.flex,
    final Key? key,
    final this.icon,
    final this.iconSize = 36,
    final this.onTap,
  }) : super(key: key);

  /// The flexible flex value.
  final int? flex;

  /// Icon to be shown.
  final IconData? icon;

  /// The size for the icon.
  final double iconSize;

  /// Function used when user holds the button down.
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    return Expanded(
      flex: flex ?? 2,
      child: KeyboardButton(
        onTap: onTap,
        onHold: onTap,
        color: Colors.grey[900],
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Widget for variable keyboard buttons.
class _VariableButton extends StatelessWidget {
  /// Constructs a [_VariableButton] widget.
  const _VariableButton({
    required final this.name,
    final Key? key,
    final this.onTap,
  }) : super(key: key);

  /// The variable name.
  final String name;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    return KeyboardButton(
      onTap: onTap,
      child: Math.tex(
        name,
        options: defaultTexMathOptions(
          fontSize: 22,
          color: TexColorImpl(
            argb: Colors.white.value,
          ),
        ),
      ),
    );
  }
}
