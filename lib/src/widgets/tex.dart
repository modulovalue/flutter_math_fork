// ignore_for_file: comment_references

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../font/font_metrics.dart';
import '../parser/parser.dart';
import '../render/layout.dart';
import '../render/svg.dart';
import '../render/symbol.dart';
import '../utils/extensions.dart';
import '../utils/text_extension.dart';
import '../utils/wrapper.dart';
import 'cursor_timer_manager.dart';
import 'focus_manager.dart';
import 'overlay_manager.dart';
import 'selection_manager.dart';
import 'web_selection_manager.dart';

/// Selectable math widget.
///
/// On top of non-selectable [Math], it adds selection functionality. Users can
/// select by long press gesture, drag gesture, moving selection handles or
/// pointer selection. The selected region can be encoded into TeX and copied
/// to clipboard.
///
/// See [SelectableText] as this widget aims to fully imitate its behavior.
class SelectableMath extends StatelessWidget {
  /// SelectableMath default constructor.
  ///
  /// Requires either a parsed [ast] or a [parseException].
  ///
  /// See [SelectableMath] for its member documentation.
  const SelectableMath({
    final Key? key,
    final this.ast,
    final this.autofocus = false,
    final this.cursorColor,
    final this.cursorRadius,
    final this.cursorWidth = 2.0,
    final this.cursorHeight,
    final this.dragStartBehavior = DragStartBehavior.start,
    final this.enableInteractiveSelection = true,
    final this.focusNode,
    final this.mathStyle = MathStyle.display,
    final this.logicalPpi,
    final this.onErrorFallback = defaultOnErrorFallback,
    final this.options,
    final this.parseException,
    final this.showCursor = false,
    final this.textScaleFactor,
    final this.textSelectionControls,
    final this.textStyle,
    final ToolbarOptions? toolbarOptions,
  })  : assert(ast != null || parseException != null, ""),
        toolbarOptions = toolbarOptions ??
            const ToolbarOptions(
              selectAll: true,
              copy: true,
            ),
        super(key: key);

  /// The equation to display.
  ///
  /// It can be null only when [parseException] is not null.
  final TexRedEquationrowImpl? ast;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the theme's `cursorColor` when null.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// Defines the focus for this widget.
  ///
  /// Math is only selectable when widget is focused.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// focusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  final FocusNode? focusNode;

  /// {@macro flutter_math_fork.widgets.math.mathStyle}
  final MathStyle mathStyle;

  /// {@macro flutter_math_fork.widgets.math.logicalPpi}
  final double? logicalPpi;

  /// {@macro flutter_math_fork.widgets.math.onErrorFallback}
  final OnErrorFallback onErrorFallback;

  /// {@macro flutter_math_fork.widgets.math.options}
  final MathOptions? options;

  /// {@macro flutter_math_fork.widgets.math.parseError}
  final ParseException? parseException;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool showCursor;

  /// {@macro flutter.widgets.editableText.textScaleFactor}
  final double? textScaleFactor;

  /// Optional delegate for building the text selection handles and toolbar.
  ///
  /// Just works like [EditableText.selectionControls]
  final TextSelectionControls? textSelectionControls;

  /// {@macro fluttermath.widgets.math.textStyle}
  final TextStyle? textStyle;

  /// Configuration of toolbar options.
  ///
  /// Paste and cut will be disabled regardless.
  ///
  /// If not set, select all and copy will be enabled by default.
  final ToolbarOptions toolbarOptions;

  /// SelectableMath builder using a TeX string
  ///
  /// {@macro flutter_math_fork.widgets.math.tex_builder}
  ///
  /// See alse:
  ///
  /// * [SelectableMath.mathStyle]
  /// * [SelectableMath.textStyle]
  static SelectableMath tex(
    final String expression, {
    final Key? key,
    final TexParserSettings settings = const TexParserSettings(),
    final MathOptions? options,
    final OnErrorFallback onErrorFallback = defaultOnErrorFallback,
    final bool autofocus = false,
    final Color? cursorColor,
    final Radius? cursorRadius,
    final double cursorWidth = 2.0,
    final double? cursorHeight,
    final DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    final bool enableInteractiveSelection = true,
    final FocusNode? focusNode,
    final MathStyle mathStyle = MathStyle.display,
    final double? logicalPpi,
    final bool showCursor = false,
    final double? textScaleFactor,
    final TextSelectionControls? textSelectionControls,
    final TextStyle? textStyle,
    final ToolbarOptions? toolbarOptions,
  }) {
    TexRedEquationrowImpl? ast;
    ParseException? parseError;
    try {
      ast = TexRedEquationrowImpl(
        greenValue: TexParser(
          content: expression,
          settings: settings,
        ).parse(),
      );
    } on ParseException catch (e) {
      parseError = e;
    } on Object catch (e) {
      parseError = ParseException('Unsanitized parse exception detected: $e.'
          'Please report this error with correponding input.');
    }
    return SelectableMath(
      key: key,
      ast: ast,
      autofocus: autofocus,
      cursorColor: cursorColor,
      cursorRadius: cursorRadius,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      focusNode: focusNode,
      mathStyle: mathStyle,
      logicalPpi: logicalPpi,
      onErrorFallback: onErrorFallback,
      options: options,
      parseException: parseError,
      showCursor: showCursor,
      textScaleFactor: textScaleFactor,
      textSelectionControls: textSelectionControls,
      textStyle: textStyle,
      toolbarOptions: toolbarOptions,
    );
  }

  @override
  Widget build(
    final BuildContext context,
  ) {
    if (parseException != null) {
      return onErrorFallback(parseException!);
    } else {
      var effectiveTextStyle = textStyle;
      if (effectiveTextStyle == null || effectiveTextStyle.inherit) {
        effectiveTextStyle = DefaultTextStyle.of(context).style.merge(textStyle);
      }
      if (MediaQuery.boldTextOverride(context)) {
        effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
      }
      final textScaleFactor = this.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
      final options = this.options ??
          MathOptions.deflt(
            style: mathStyle,
            fontSize: effectiveTextStyle.fontSize! * textScaleFactor,
            mathFontOptions: effectiveTextStyle.fontWeight != FontWeight.normal
                ? FontOptions(fontWeight: effectiveTextStyle.fontWeight!)
                : null,
            logicalPpi: logicalPpi,
            color: effectiveTextStyle.color!,
          );
      // A trial build to catch any potential build errors
      try {
        TexWidget(
          tex: ast!,
          options: options,
        );
      } on BuildException catch (e) {
        return onErrorFallback(e);
      } on Object catch (e) {
        return onErrorFallback(BuildException('Unsanitized build exception detected: $e.'
            'Please report this error with correponding input.'));
      }
      final theme = Theme.of(context);
      // The following code adapts for Flutter's new theme system (https://github.com/flutter/flutter/pull/62014/)
      final selectionTheme = TextSelectionTheme.of(context);
      var textSelectionControls = this.textSelectionControls;
      bool paintCursorAboveText;
      bool cursorOpacityAnimates;
      Offset? cursorOffset;
      var cursorColor = this.cursorColor;
      Color selectionColor;
      var cursorRadius = this.cursorRadius;
      bool forcePressEnabled;
      switch (theme.platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          forcePressEnabled = true;
          textSelectionControls ??= cupertinoTextSelectionControls;
          paintCursorAboveText = true;
          cursorOpacityAnimates = true;
          cursorColor ??= selectionTheme.cursorColor ?? CupertinoTheme.of(context).primaryColor;
          selectionColor = selectionTheme.selectionColor ?? CupertinoTheme.of(context).primaryColor;
          cursorRadius ??= const Radius.circular(2.0);
          cursorOffset = Offset(iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          forcePressEnabled = false;
          textSelectionControls ??= materialTextSelectionControls;
          paintCursorAboveText = false;
          cursorOpacityAnimates = false;
          cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
          selectionColor = selectionTheme.selectionColor ?? theme.colorScheme.primary;

          break;
      }
      return RepaintBoundary(
        child: InternalSelectableMath(
          ast: ast!,
          autofocus: autofocus,
          cursorColor: cursorColor,
          cursorOffset: cursorOffset,
          cursorOpacityAnimates: cursorOpacityAnimates,
          cursorRadius: cursorRadius,
          cursorWidth: cursorWidth,
          cursorHeight: cursorHeight,
          dragStartBehavior: dragStartBehavior,
          enableInteractiveSelection: enableInteractiveSelection,
          focusNode: focusNode,
          forcePressEnabled: forcePressEnabled,
          options: options,
          paintCursorAboveText: paintCursorAboveText,
          selectionColor: selectionColor,
          showCursor: showCursor,
          textSelectionControls: textSelectionControls,
          toolbarOptions: toolbarOptions,
        ),
      );
    }
  }

  /// Default fallback function for [Math], [SelectableMath]
  static Widget defaultOnErrorFallback(final FlutterMathException error) =>
      Math.defaultOnErrorFallback(error);
}

/// The internal widget for [SelectableMath] when no errors are encountered.
class InternalSelectableMath extends StatefulWidget {
  const InternalSelectableMath({
    required final this.ast,
    required final this.cursorColor,
    required final this.options,
    required final this.textSelectionControls,
    required final this.toolbarOptions,
    final this.autofocus = false,
    final this.cursorOffset,
    final this.cursorOpacityAnimates = false,
    final this.cursorRadius,
    final this.cursorWidth = 2.0,
    final this.cursorHeight,
    final this.dragStartBehavior = DragStartBehavior.start,
    final this.enableInteractiveSelection = true,
    final this.forcePressEnabled = false,
    final this.focusNode,
    final this.hintingColor,
    final this.paintCursorAboveText = false,
    final this.selectionColor,
    final this.showCursor = false,
    final Key? key,
  }) : super(
          key: key,
        );

  final TexRedEquationrowImpl ast;

  final bool autofocus;

  final Color cursorColor;

  final Offset? cursorOffset;

  final bool cursorOpacityAnimates;

  final Radius? cursorRadius;

  final double cursorWidth;

  final double? cursorHeight;

  final DragStartBehavior dragStartBehavior;

  final bool enableInteractiveSelection;

  final FocusNode? focusNode;

  final bool forcePressEnabled;

  final Color? hintingColor;

  final MathOptions options;

  final bool paintCursorAboveText;

  final Color? selectionColor;

  final bool showCursor;

  final TextSelectionControls textSelectionControls;

  final ToolbarOptions toolbarOptions;

  @override
  InternalSelectableMathState createState() => InternalSelectableMathState();
}

class InternalSelectableMathState extends State<InternalSelectableMath>
    with
        AutomaticKeepAliveClientMixin,
        FocusManagerMixin,
        SelectionManagerMixin,
        SelectionOverlayManagerMixin,
        WebSelectionControlsManagerMixin,
        SingleTickerProviderStateMixin,
        CursorTimerManagerMixin {
  @override
  TextSelectionControls get textSelectionControls => widget.textSelectionControls;

  FocusNode? _focusNode;

  @override
  FocusNode get focusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  @override
  bool get showCursor => widget.showCursor; //?? false;

  @override
  bool get cursorOpacityAnimates => widget.cursorOpacityAnimates;

  @override
  DragStartBehavior get dragStartBehavior => widget.dragStartBehavior;

  @override
  late MathController controller;

  late FocusNode _oldFocusNode;

  @override
  void initState() {
    controller = MathController(ast: widget.ast);
    _oldFocusNode = focusNode..addListener(updateKeepAlive);
    super.initState();
  }

  @override
  void didUpdateWidget(final InternalSelectableMath oldWidget) {
    if (widget.ast != controller.ast) {
      controller = MathController(ast: widget.ast);
    }
    if (_oldFocusNode != focusNode) {
      _oldFocusNode.removeListener(updateKeepAlive);
      _oldFocusNode = focusNode..addListener(updateKeepAlive);
    }
    super.didUpdateWidget(oldWidget);
  }

  bool _didAutoFocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutoFocus && widget.autofocus) {
      _didAutoFocus = true;
      SchedulerBinding.instance!.addPostFrameCallback((final _) {
        if (mounted) {
          FocusScope.of(context).autofocus(widget.focusNode!);
        }
      });
    }
  }

  @override
  void dispose() {
    _oldFocusNode.removeListener(updateKeepAlive);
    super.dispose();
    controller.dispose();
  }

  @override
  void onSelectionChanged(
    final TextSelection selection,
    final SelectionChangedCause? cause,
  ) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (cause == SelectionChangedCause.longPress) {
          bringIntoView(selection.base);
        }
        return;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      // Do nothing.
    }
  }

  @override
  Widget build(
    final BuildContext context,
  ) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    final child = TexWidget(
      tex: controller.ast,
      options: widget.options,
    );
    return selectionGestureDetectorBuilder.buildGestureDetector(
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: CompositedTransformTarget(
          link: toolbarLayerLink,
          child: MultiProvider(
            providers: [
              Provider.value(value: FlutterMathMode.select),
              ChangeNotifierProvider.value(value: controller),
              ProxyProvider<MathController, TextSelection>(
                create: (final context) => const TextSelection.collapsed(offset: -1),
                update: (final context, final value, final previous) => value.selection,
              ),
              Provider.value(
                value: SelectionStyle(
                  cursorColor: widget.cursorColor,
                  cursorOffset: widget.cursorOffset,
                  cursorRadius: widget.cursorRadius,
                  cursorWidth: widget.cursorWidth,
                  cursorHeight: widget.cursorHeight,
                  selectionColor: widget.selectionColor,
                  paintCursorAboveText: widget.paintCursorAboveText,
                ),
              ),
              Provider.value(
                value: LayerLinkTuple(
                  start: startHandleLayerLink,
                  end: endHandleLayerLink,
                ),
              ),
              // We can't just provide an AnimationController, otherwise
              // Provider will throw
              Provider.value(value: Wrapper(cursorBlinkOpacityController)),
            ],
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => hasFocus;

  @override
  bool get copyEnabled => widget.toolbarOptions.copy;

  @override
  bool get cutEnabled => false;

  @override
  bool get pasteEnabled => false;

  @override
  bool get selectAllEnabled => widget.toolbarOptions.selectAll;

  @override
  bool get forcePressEnabled => widget.forcePressEnabled;

  @override
  bool get selectionEnabled => widget.enableInteractiveSelection;

  @override
  double get preferredLineHeight => widget.options.fontSize;

  @override
  void bringIntoView(
    final TextPosition position,
  ) {
    // TODO: implement bringIntoView
  }

  @override
  void copySelection(
    final SelectionChangedCause cause,
  ) {
    // TODO: implement copySelection
  }

  @override
  void cutSelection(
    final SelectionChangedCause cause,
  ) {
    // TODO: implement cutSelection
  }

  @override
  Future<void> pasteText(
    final SelectionChangedCause cause,
  ) async {
    // TODO: implement pasteText
  }

  @override
  void selectAll(
    final SelectionChangedCause cause,
  ) {
    // TODO: implement selectAll
  }

  @override
  void userUpdateTextEditingValue(
    final TextEditingValue value,
    final SelectionChangedCause cause,
  ) {
    // TODO: implement userUpdateTextEditingValue
  }
}

class LayerLinkTuple {
  final LayerLink start;
  final LayerLink end;

  const LayerLinkTuple({
    required final this.start,
    required final this.end,
  });
}

class SelectionStyle {
  final Color cursorColor;
  final Offset? cursorOffset;
  final Radius? cursorRadius;
  final double cursorWidth;
  final double? cursorHeight;
  final Color? hintingColor;
  final bool paintCursorAboveText;
  final Color? selectionColor;
  final bool showCursor;

  const SelectionStyle({
    required final this.cursorColor,
    final this.cursorOffset,
    final this.cursorRadius,
    final this.cursorWidth = 1.0,
    final this.cursorHeight,
    final this.hintingColor,
    final this.paintCursorAboveText = false,
    final this.selectionColor,
    final this.showCursor = false,
  });

  @override
  bool operator ==(final Object o) {
    if (identical(this, o)) return true;

    return o is SelectionStyle &&
        o.cursorColor == cursorColor &&
        o.cursorOffset == cursorOffset &&
        o.cursorRadius == cursorRadius &&
        o.cursorWidth == cursorWidth &&
        o.cursorHeight == cursorHeight &&
        o.hintingColor == hintingColor &&
        o.paintCursorAboveText == paintCursorAboveText &&
        o.selectionColor == selectionColor &&
        o.showCursor == showCursor;
  }

  @override
  int get hashCode => hashValues(
        cursorColor,
        cursorOffset,
        cursorRadius,
        cursorWidth,
        cursorHeight,
        hintingColor,
        paintCursorAboveText,
        selectionColor,
        showCursor,
      );
}

const defaultSelection = TextSelection.collapsed(offset: -1);

/// Static, non-selectable widget for equations.
///
/// Sample usage:
///
/// ```dart
/// Math.tex(
///   r'\frac a b\sqrt[3]{n}',
///   mathStyle: MathStyle.display,
///   textStyle: TextStyle(fontSize: 42),
/// )
/// ```
///
/// Compared to [SelectableMath], [Math] will offer a significant performance
/// advantage. So if no selection capability is needed or the equation counts
/// on the same screen is huge, it's preferable to use [Math].
class Math extends StatelessWidget {
  /// Math widget default constructor
  ///
  /// Requires either a parsed [ast] or a [parseError].
  ///
  /// See [Math] for its member documentation
  const Math({
    final Key? key,
    final this.ast,
    final this.mathStyle = MathStyle.display,
    final this.logicalPpi,
    final this.onErrorFallback = defaultOnErrorFallback,
    final this.options,
    final this.parseError,
    final this.textScaleFactor,
    final this.textStyle,
  })  : assert(ast != null || parseError != null, ""),
        super(key: key);

  /// The equation to display.
  ///
  /// It can be null only when [parseError] is not null.
  final TexRedEquationrowImpl? ast;

  /// {@template flutter_math_fork.widgets.math.options}
  /// Equation style.
  ///
  /// Choose [MathStyle.display] for displayed equations and [MathStyle.text]
  /// for in-line equations.
  ///
  /// Will be overruled if [options] is present.
  /// {@endtemplate}
  final MathStyle mathStyle;

  /// {@template flutter_math_fork.widgets.math.logicalPpi}
  /// {@macro flutter_math_fork.math_options.logicalPpi}
  ///
  /// If set to null, the effective [logicalPpi] will scale with
  /// [TextStyle.fontSize]. You can obtain the default scaled value by
  /// [MathOptions.defaultLogicalPpiFor].
  ///
  /// Will be overruled if [options] is present.
  ///
  /// {@endtemplate}
  final double? logicalPpi;

  /// {@template flutter_math_fork.widgets.math.onErrorFallback}
  /// Fallback widget when there are uncaught errors during parsing or building.
  ///
  /// Will be invoked when:
  ///
  /// * [parseError] is not null.
  /// * [TexRoslyn.buildWidget] throw an error.
  ///
  /// Either case, this fallback function is invoked in build functions. So use
  /// with care.
  /// {@endtemplate}
  final OnErrorFallback onErrorFallback;

  /// {@template flutter_math_fork.widgets.math.options}
  /// Overriding [MathOptions] to build the AST.
  ///
  /// Will overrule [mathStyle] and [textStyle] if not null.
  /// {@endtemplate}
  final MathOptions? options;

  /// {@template flutter_math_fork.widgets.math.parseError}
  /// Errors generated during parsing.
  ///
  /// If not null, the [onErrorFallback] widget will be presented.
  /// {@endtemplate}
  final ParseException? parseError;

  /// {@macro flutter.widgets.editableText.textScaleFactor}
  final double? textScaleFactor;

  /// {@template fluttermath.widgets.math.textStyle}
  /// The style for rendered math analogous to [Text.style].
  ///
  /// Can controll the size of the equation via [TextStyle.fontSize]. It can
  /// also affect the font weight and font shape of the equation.
  ///
  /// If set to null, `DefaultTextStyle` from the context will be used.
  ///
  /// Will be overruled if [options] is present.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// Math builder using a TeX string
  ///
  /// {@template flutter_math_fork.widgets.math.tex_builder}
  /// [expression] will first be parsed under [settings]. Then the acquired
  /// [TexRoslyn] will be built under a specific options. If [ParseException]
  /// is thrown or a build error occurs, [onErrorFallback] will be displayed.
  ///
  /// You can control the options via [mathStyle] and [textStyle].
  /// {@endtemplate}
  ///
  /// See alse:
  ///
  /// * [Math.mathStyle]
  /// * [Math.textStyle]
  static Math tex(
    final String expression, {
    final Key? key,
    final MathStyle mathStyle = MathStyle.display,
    final TextStyle? textStyle,
    final OnErrorFallback onErrorFallback = defaultOnErrorFallback,
    final TexParserSettings settings = const TexParserSettings(),
    final double? textScaleFactor,
    final MathOptions? options,
  }) {
    TexRedEquationrowImpl? ast;
    ParseException? parseError;
    try {
      ast = TexRedEquationrowImpl(
        greenValue: TexParser(
          content: expression,
          settings: settings,
        ).parse(),
      );
    } on ParseException catch (e) {
      parseError = e;
    } on Object catch (e) {
      parseError = ParseException('Unsanitized parse exception detected: $e.'
          'Please report this error with correponding input.');
    }
    return Math(
      key: key,
      ast: ast,
      parseError: parseError,
      options: options,
      onErrorFallback: onErrorFallback,
      mathStyle: mathStyle,
      textScaleFactor: textScaleFactor,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (parseError != null) {
      return onErrorFallback(parseError!);
    }
    var options = this.options;
    if (options == null) {
      var effectiveTextStyle = textStyle;
      if (effectiveTextStyle == null || effectiveTextStyle.inherit) {
        effectiveTextStyle = DefaultTextStyle.of(context).style.merge(textStyle);
      }
      if (MediaQuery.boldTextOverride(context)) {
        effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
      }
      final textScaleFactor = this.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
      options = MathOptions.deflt(
        style: mathStyle,
        fontSize: effectiveTextStyle.fontSize! * textScaleFactor,
        mathFontOptions: effectiveTextStyle.fontWeight != FontWeight.normal
            ? FontOptions(fontWeight: effectiveTextStyle.fontWeight!)
            : null,
        logicalPpi: logicalPpi,
        color: effectiveTextStyle.color!,
      );
    }
    Widget child;
    try {
      child = TexWidget(
        tex: ast!,
        options: options,
      );
    } on BuildException catch (e) {
      return onErrorFallback(e);
    } on Object catch (e) {
      return onErrorFallback(BuildException('Unsanitized build exception detected: $e.'
          'Please report this error with correponding input.'));
    }
    return Provider.value(
      value: FlutterMathMode.view,
      child: child,
    );
  }

  /// Default fallback function for [Math], [SelectableMath]
  static Widget defaultOnErrorFallback(final FlutterMathException error) =>
      SelectableText(error.messageWithType);

  /// Line breaking results using standard TeX-style line breaking.
  ///
  /// This function will return a list of `Math` widget along with a list of
  /// line breaking penalties.
  ///
  /// {@template flutter_math_fork.widgets.math.tex_break}
  ///
  /// This function will break the equation into pieces according to TeX spec
  /// **as much as possible** (some exceptions exist when `enforceNoBreak: true`
  /// ). Then, you can assemble the pieces in whatever way you like. The most
  /// simple way is to put the parts inside a `Wrap`.
  ///
  /// If you wish to implement a custom line breaking policy to manage the
  /// penalties, you can access the penalties in `BreakResult.penalties`. The
  /// values in `BreakResult.penalties` represent the line-breaking penalty
  /// generated at the right end of each `BreakResult.parts`. Note that
  /// `\nobreak` or `\penalty<number>=10000>` are left unbroken by default, you
  /// need to supply `enforceNoBreak: false` into `Math.texBreak` to expose
  /// those break points and their penalties.
  ///
  /// {@endtemplate}
  BreakResult<Math> texBreak({
    final int relPenalty = 500,
    final int binOpPenalty = 700,
    final bool enforceNoBreak = true,
  }) {
    final ast = this.ast;
    if (ast == null || parseError != null) {
      return BreakResult(parts: [this], penalties: [10000]);
    }
    final astBreakResult = syntaxTreeTexBreak(
      tree: ast,
      relPenalty: relPenalty,
      binOpPenalty: binOpPenalty,
      enforceNoBreak: enforceNoBreak,
    );
    return BreakResult(
      parts: astBreakResult.parts
          .map((final part) => Math(
                ast: part,
                mathStyle: this.mathStyle,
                logicalPpi: this.logicalPpi,
                onErrorFallback: this.onErrorFallback,
                options: this.options,
                parseError: this.parseError,
                textScaleFactor: this.textScaleFactor,
                textStyle: this.textStyle,
              ))
          .toList(growable: false),
      penalties: astBreakResult.penalties,
    );
  }
}

typedef OnErrorFallback = Widget Function(FlutterMathException errmsg);

class TexWidget extends StatelessWidget {
  final TexRed tex;
  final MathOptions options;

  const TexWidget({
    required final this.tex,
    required final this.options,
  });

  @override
  Widget build(
    final BuildContext context,
  ) {
    final result = buildWidget(
      node: tex,
      newOptions: options,
    );
    return result.widget;
  }

  /// This is where the actual widget building process happens.
  ///
  /// This method tries to reduce widget rebuilds. Rebuild bypass is determined
  /// by the following process:
  /// - If oldOptions == newOptions, bypass
  /// - If [TexGreen.shouldRebuildWidget], force rebuild
  /// - Call [buildWidget] on [children]. If the results are identical to the
  /// results returned by [buildWidget] called last time, then bypass.
  // TODO(modulovalue) it would be nice to have a caching scheme that can maintain some history.
  static GreenBuildResult buildWidget({
    required final TexRed node,
    required final MathOptions newOptions,
  }) {
    // Compose Flutter widget with child widgets already built
    //
    // Subclasses should override this method. This method provides a general
    // description of the layout of this math node. The child nodes are built in
    // prior. This method is only responsible for the placement of those child
    // widgets according to the layout & other interactions.
    //
    // Please ensure [children] works in the same order as [updateChildren],
    // [computeChildOptions], and [buildWidget].
    GreenBuildResult _texWidget(
      final TexGreen node,
      final MathOptions options,
      final List<GreenBuildResult?> childBuildResults,
    ) {
      return node.match(
        nonleaf: (final a) => a.matchNonleaf(
          matrix: (final a) {
            assert(childBuildResults.length == a.rows * a.cols, "");
            // Flutter's Table does not provide fine-grained control of borders
            return GreenBuildResult(
              options: options,
              widget: ShiftBaseline(
                relativePos: 0.5,
                offset: options.fontMetrics.axisHeight2.toLpUnder(options),
                child: CustomLayout<int>(
                  delegate: MatrixLayoutDelegate(
                    rows: a.rows,
                    cols: a.cols,
                    ruleThickness:
                        Measurement.cssem(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
                    arrayskip: a.arrayStretch * Measurement.pt(12.0).toLpUnder(options),
                    rowSpacings: a.rowSpacings.map((final e) => e.toLpUnder(options)).toList(growable: false),
                    hLines: a.hLines,
                    hskipBeforeAndAfter: a.hskipBeforeAndAfter,
                    arraycolsep: () {
                      if (a.isSmall) {
                        return Measurement.cssem(5 / 18).toLpUnder(options.havingStyle(MathStyle.script));
                      } else {
                        return Measurement.pt(5.0).toLpUnder(options);
                      }
                    }(),
                    vLines: a.vLines,
                    columnAligns: a.columnAligns,
                  ),
                  children: childBuildResults
                      .mapIndexed(
                        (final index, final result) {
                          if (result == null) {
                            return null;
                          } else {
                            return CustomLayoutId(
                              id: index,
                              child: result.widget,
                            );
                          }
                        },
                      )
                      .whereNotNull()
                      .toList(growable: false),
                ),
              ),
            );
          },
          multiscripts: (final a) => GreenBuildResult(
            options: options,
            widget: Multiscripts(
              alignPostscripts: a.alignPostscripts,
              isBaseCharacterBox:
                  a.base.flattenedChildList.length == 1 && a.base.flattenedChildList[0] is TexGreenSymbol,
              baseResult: childBuildResults[0]!,
              subResult: childBuildResults[1],
              supResult: childBuildResults[2],
              presubResult: childBuildResults[3],
              presupResult: childBuildResults[4],
            ),
          ),
          naryoperator: (final a) {
            final large =
                a.allowLargeOp && (mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
            final font =
                large ? const FontOptions(fontFamily: 'Size2') : const FontOptions(fontFamily: 'Size1');
            Widget operatorWidget;
            CharacterMetrics symbolMetrics;
            if (!stashedOvalNaryOperator.containsKey(a.operator)) {
              final lookupResult = lookupChar(a.operator, font, Mode.math);
              if (lookupResult == null) {
                symbolMetrics = CharacterMetrics(0, 0, 0, 0, 0);
                operatorWidget = Container();
              } else {
                symbolMetrics = lookupResult;
                final symbolWidget = makeChar(a.operator, font, symbolMetrics, options, needItalic: true);
                operatorWidget = symbolWidget;
              }
            } else {
              final baseSymbol = stashedOvalNaryOperator[a.operator]!;
              symbolMetrics = lookupChar(baseSymbol, font, Mode.math)!;
              final baseSymbolWidget = makeChar(baseSymbol, font, symbolMetrics, options, needItalic: true);
              final oval = staticSvg(
                '${a.operator == '\u222F' ? 'oiint' : 'oiiint'}'
                'Size${large ? '2' : '1'}',
                options,
              );
              operatorWidget = Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ResetDimension(
                    horizontalAlignment: CrossAxisAlignment.start,
                    width: 0.0,
                    child: ShiftBaseline(
                      offset: large ? Measurement.cssem(0.08).toLpUnder(options) : 0.0,
                      child: oval,
                    ),
                  ),
                  baseSymbolWidget,
                ],
              );
            }
            // Attach limits to the base symbol
            if (a.lowerLimit != null || a.upperLimit != null) {
              // Should we place the limit as under/over or sub/sup
              final shouldLimits = a.limits ??
                  (naryDefaultLimit.contains(a.operator) &&
                      mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
              final italic = symbolMetrics.italic.toLpUnder(options);
              if (!shouldLimits) {
                operatorWidget = Multiscripts(
                  isBaseCharacterBox: false,
                  baseResult: GreenBuildResult(widget: operatorWidget, options: options, italic: italic),
                  subResult: childBuildResults[0],
                  supResult: childBuildResults[1],
                );
              } else {
                final spacing = Measurement.cssem(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
                operatorWidget = Padding(
                  padding: EdgeInsets.only(
                    top: a.upperLimit != null ? spacing : 0,
                    bottom: a.lowerLimit != null ? spacing : 0,
                  ),
                  child: VList(
                    baselineReferenceWidgetIndex: a.upperLimit != null ? 1 : 0,
                    children: [
                      if (a.upperLimit != null)
                        VListElement(
                          hShift: 0.5 * italic,
                          child: MinDimension(
                            minDepth: Measurement.cssem(options.fontMetrics.bigOpSpacing3).toLpUnder(options),
                            bottomPadding:
                                Measurement.cssem(options.fontMetrics.bigOpSpacing1).toLpUnder(options),
                            child: childBuildResults[1]!.widget,
                          ),
                        ),
                      operatorWidget,
                      if (a.lowerLimit != null)
                        VListElement(
                          hShift: -0.5 * italic,
                          child: MinDimension(
                            minHeight: Measurement.cssem(options.fontMetrics.bigOpSpacing4).toLpUnder(options),
                            topPadding:
                                Measurement.cssem(options.fontMetrics.bigOpSpacing2).toLpUnder(options),
                            child: childBuildResults[0]!.widget,
                          ),
                        ),
                    ],
                  ),
                );
              }
            }
            final widget = Line(
              children: [
                LineElement(
                  child: operatorWidget,
                  trailingMargin: getSpacingSize(
                    AtomType.op,
                    a.naryand.leftType,
                    options.style,
                  ).toLpUnder(options),
                ),
                LineElement(
                  child: childBuildResults[2]!.widget,
                  trailingMargin: 0.0,
                ),
              ],
            );
            return GreenBuildResult(
              widget: widget,
              options: options,
              italic: childBuildResults[2]!.italic,
            );
          },
          sqrt: (final a) {
            final baseResult = childBuildResults[1]!;
            final indexResult = childBuildResults[0];
            return GreenBuildResult(
              options: options,
              widget: CustomLayout<SqrtPos>(
                delegate: SqrtLayoutDelegate(
                  options: options,
                  baseOptions: baseResult.options,
                  // indexOptions: indexResult?.options,
                ),
                children: <Widget>[
                  CustomLayoutId(
                    id: SqrtPos.base,
                    child: MinDimension(
                      minHeight: options.fontMetrics.xHeight2.toLpUnder(options),
                      topPadding: 0,
                      child: baseResult.widget,
                    ),
                  ),
                  CustomLayoutId(
                    id: SqrtPos.surd,
                    child: LayoutBuilderPreserveBaseline(
                      builder: (final context, final constraints) => sqrtSvg(
                        minDelimiterHeight: constraints.minHeight,
                        baseWidth: constraints.minWidth,
                        options: options,
                      ),
                    ),
                  ),
                  if (a.index != null)
                    CustomLayoutId(
                      id: SqrtPos.ind,
                      child: indexResult!.widget,
                    ),
                ],
              ),
            );
          },
          stretchyop: (final a) {
            final verticalPadding = Measurement.mu(2.0).toLpUnder(options);
            return GreenBuildResult(
              options: options,
              italic: 0.0,
              widget: VList(
                baselineReferenceWidgetIndex: a.above != null ? 1 : 0,
                children: <Widget>[
                  if (a.above != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: verticalPadding,
                      ),
                      child: childBuildResults[0]!.widget,
                    ),
                  VListElement(
                    // From katex.less/x-arrow-pad
                    customCrossSize: (final width) =>
                        BoxConstraints(minWidth: width + Measurement.cssem(1.0).toLpUnder(options)),
                    child: LayoutBuilderPreserveBaseline(
                      builder: (final context, final constraints) => ShiftBaseline(
                        relativePos: 0.5,
                        offset: options.fontMetrics.xHeight2.toLpUnder(options),
                        child: strechySvgSpan(
                          stretchyOpMapping[a.symbol] ?? a.symbol,
                          constraints.minWidth,
                          options,
                        ),
                      ),
                    ),
                  ),
                  if (a.below != null)
                    Padding(
                      padding: EdgeInsets.only(top: verticalPadding),
                      child: childBuildResults[1]!.widget,
                    )
                ],
              ),
            );
          },
          equationarray: (final a) {
            return GreenBuildResult(
              options: options,
              widget: ShiftBaseline(
                relativePos: 0.5,
                offset: options.fontMetrics.axisHeight2.toLpUnder(options),
                child: EqnArray(
                  ruleThickness:
                      Measurement.cssem(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
                  jotSize: a.addJot ? Measurement.pt(3.0).toLpUnder(options) : 0.0,
                  arrayskip: Measurement.pt(12.0).toLpUnder(options) * a.arrayStretch,
                  hlines: a.hlines,
                  rowSpacings: a.rowSpacings.map((final e) => e.toLpUnder(options)).toList(growable: false),
                  children: childBuildResults.map((final e) => e!.widget).toList(growable: false),
                ),
              ),
            );
          },
          over: (final a) {
            // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
            final spacing = Measurement.cssem(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
            return GreenBuildResult(
              options: options,
              widget: Padding(
                padding: EdgeInsets.only(
                  top: spacing,
                ),
                child: VList(
                  baselineReferenceWidgetIndex: 1,
                  children: <Widget>[
                    // TexBook Rule 13a
                    MinDimension(
                      minDepth: Measurement.cssem(options.fontMetrics.bigOpSpacing3).toLpUnder(options),
                      bottomPadding: Measurement.cssem(options.fontMetrics.bigOpSpacing1).toLpUnder(options),
                      child: childBuildResults[1]!.widget,
                    ),
                    childBuildResults[0]!.widget,
                  ],
                ),
              ),
            );
          },
          under: (final a) {
            // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
            final spacing = Measurement.cssem(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
            return GreenBuildResult(
              italic: 0.0,
              options: options,
              widget: Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: VList(
                  baselineReferenceWidgetIndex: 0,
                  children: <Widget>[
                    childBuildResults[0]!.widget,
                    // TexBook Rule 13a
                    MinDimension(
                      minHeight: Measurement.cssem(options.fontMetrics.bigOpSpacing4).toLpUnder(options),
                      topPadding: Measurement.cssem(options.fontMetrics.bigOpSpacing2).toLpUnder(options),
                      child: childBuildResults[1]!.widget,
                    ),
                  ],
                ),
              ),
            );
          },
          accent: (final a) {
            // Checking of character box is done automatically by the passing of
            // BuildResult, so we don't need to check it here.
            final baseResult = childBuildResults[0]!;
            final skew = a.isShifty ? baseResult.skew : 0.0;
            Widget accentWidget;
            if (!a.isStretchy) {
              Widget accentSymbolWidget;
              // Following comment are selected from KaTeX:
              //
              // Before version 0.9, \vec used the combining font glyph U+20D7.
              // But browsers, especially Safari, are not consistent in how they
              // render combining characters when not preceded by a character.
              // So now we use an SVG.
              // If Safari reforms, we should consider reverting to the glyph.
              if (a.label == '\u2192') {
                // We need non-null baseline. Because ShiftBaseline cannot deal with a
                // baseline distance of null due to Flutter rendering pipeline design.
                accentSymbolWidget = staticSvg('vec', options, needBaseline: true);
              } else {
                final accentRenderConfig = accentRenderConfigs[a.label];
                if (accentRenderConfig == null || accentRenderConfig.overChar == null) {
                  accentSymbolWidget = Container();
                } else {
                  accentSymbolWidget = makeBaseSymbol(
                    symbol: accentRenderConfig.overChar!,
                    variantForm: false,
                    atomType: AtomType.ord,
                    mode: Mode.text,
                    options: options,
                  ).widget;
                }
              }
              // Non stretchy accent can not contribute to overall width, thus they must
              // fit exactly with the width even if it means overflow.
              accentWidget = LayoutBuilder(
                builder: (final context, final constraints) => ResetDimension(
                  depth: 0.0, // Cut off xHeight
                  width: constraints.minWidth, // Ensure width
                  child: ShiftBaseline(
                    // \tilde is submerged below baseline in KaTeX fonts
                    relativePos: 1.0,
                    // Shift baseline up by xHeight
                    offset: -options.fontMetrics.xHeight2.toLpUnder(options),
                    child: accentSymbolWidget,
                  ),
                ),
              );
            } else {
              // Strechy accent
              accentWidget = LayoutBuilder(
                builder: (final context, final constraints) {
                  // \overline needs a special case, as KaTeX does.
                  if (a.label == '\u00AF') {
                    final defaultRuleThickness =
                        Measurement.cssem(options.fontMetrics.defaultRuleThickness).toLpUnder(options);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 3 * defaultRuleThickness),
                      child: Container(
                        width: constraints.minWidth,
                        height: defaultRuleThickness, // TODO minRuleThickness
                        color: options.color,
                      ),
                    );
                  } else {
                    final accentRenderConfig = accentRenderConfigs[a.label];
                    if (accentRenderConfig == null || accentRenderConfig.overImageName == null) {
                      return Container();
                    }
                    final svgWidget = strechySvgSpan(
                      accentRenderConfig.overImageName!,
                      constraints.minWidth,
                      options,
                    );
                    // \horizBrace also needs a special case, as KaTeX does.
                    if (a.label == '\u23de') {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Measurement.cssem(0.1).toLpUnder(options)),
                        child: svgWidget,
                      );
                    } else {
                      return svgWidget;
                    }
                  }
                },
              );
            }
            return GreenBuildResult(
              options: options,
              italic: baseResult.italic,
              skew: baseResult.skew,
              widget: VList(
                baselineReferenceWidgetIndex: 1,
                children: <Widget>[
                  VListElement(
                    customCrossSize: (final width) => BoxConstraints(minWidth: width - 2 * skew),
                    hShift: skew,
                    child: accentWidget,
                  ),
                  // Set min height
                  MinDimension(
                    minHeight: options.fontMetrics.xHeight2.toLpUnder(options),
                    topPadding: 0,
                    child: baseResult.widget,
                  ),
                ],
              ),
            );
          },
          accentunder: (final a) {
            final baseResult = childBuildResults[0]!;
            return GreenBuildResult(
              options: options,
              italic: baseResult.italic,
              skew: baseResult.skew,
              widget: VList(
                baselineReferenceWidgetIndex: 0,
                children: <Widget>[
                  VListElement(
                    trailingMargin: a.label == '\u007e' ? Measurement.cssem(0.12).toLpUnder(options) : 0.0,
                    // Special case for \utilde
                    child: baseResult.widget,
                  ),
                  VListElement(
                    customCrossSize: (final width) => BoxConstraints(minWidth: width),
                    child: LayoutBuilder(
                      builder: (final context, final constraints) {
                        if (a.label == '\u00AF') {
                          final defaultRuleThickness =
                              Measurement.cssem(options.fontMetrics.defaultRuleThickness).toLpUnder(options);
                          return Padding(
                            padding: EdgeInsets.only(top: 3 * defaultRuleThickness),
                            child: Container(
                              width: constraints.minWidth,
                              height: defaultRuleThickness, // TODO minRuleThickness
                              color: options.color,
                            ),
                          );
                        } else {
                          final accentRenderConfig = accentRenderConfigs[a.label];
                          if (accentRenderConfig == null || accentRenderConfig.underImageName == null) {
                            return Container();
                          } else {
                            return strechySvgSpan(
                              accentRenderConfig.underImageName!,
                              constraints.minWidth,
                              options,
                            );
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          },
          enclosure: (final a) {
            final horizontalPadding = (a.horizontalPadding ?? Measurement.zeroPt).toLpUnder(options);
            final verticalPadding = (a.verticalPadding ?? Measurement.zeroPt).toLpUnder(options);
            Widget widget = Stack(
              children: <Widget>[
                Container(
                  // color: backgroundcolor,
                  decoration: a.hasBorder
                      ? BoxDecoration(
                          color: a.backgroundcolor,
                          border: Border.all(
                            // TODO minRuleThickness
                            width: Measurement.cssem(options.fontMetrics.fboxrule).toLpUnder(options),
                            color: a.bordercolor ?? options.color,
                          ),
                        )
                      : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                      horizontal: horizontalPadding,
                    ),
                    child: childBuildResults[0]!.widget,
                  ),
                ),
                if (a.notation.contains('updiagonalstrike'))
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: LayoutBuilder(
                      builder: (final context, final constraints) => CustomPaint(
                        size: constraints.biggest,
                        painter: LinePainter(
                          startRelativeX: 0,
                          startRelativeY: 1,
                          endRelativeX: 1,
                          endRelativeY: 0,
                          lineWidth: Measurement.cssem(0.046).toLpUnder(options),
                          color: a.bordercolor ?? options.color,
                        ),
                      ),
                    ),
                  ),
                if (a.notation.contains('downdiagnoalstrike'))
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: LayoutBuilder(
                      builder: (final context, final constraints) => CustomPaint(
                        size: constraints.biggest,
                        painter: LinePainter(
                          startRelativeX: 0,
                          startRelativeY: 0,
                          endRelativeX: 1,
                          endRelativeY: 1,
                          lineWidth: Measurement.cssem(0.046).toLpUnder(options),
                          color: a.bordercolor ?? options.color,
                        ),
                      ),
                    ),
                  ),
              ],
            );
            if (a.notation.contains('horizontalstrike')) {
              widget = CustomLayout<int>(
                delegate: HorizontalStrikeDelegate(
                  vShift: options.fontMetrics.xHeight2.toLpUnder(options) / 2,
                  ruleThickness:
                      Measurement.cssem(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
                  color: a.bordercolor ?? options.color,
                ),
                children: <Widget>[
                  CustomLayoutId(
                    id: 0,
                    child: widget,
                  ),
                ],
              );
            }
            return GreenBuildResult(
              options: options,
              widget: widget,
            );
          },
          frac: (final a) {
            return GreenBuildResult(
              options: options,
              widget: CustomLayout(
                delegate: FracLayoutDelegate(
                  barSize: a.barSize,
                  options: options,
                ),
                children: <Widget>[
                  CustomLayoutId(
                    id: FracPos.numer,
                    child: childBuildResults[0]!.widget,
                  ),
                  CustomLayoutId(
                    id: FracPos.denom,
                    child: childBuildResults[1]!.widget,
                  ),
                ],
              ),
            );
          },
          function: (final a) {
            return GreenBuildResult(
              options: options,
              widget: Line(
                children: [
                  LineElement(
                    trailingMargin:
                        getSpacingSize(AtomType.op, a.argument.leftType, options.style).toLpUnder(options),
                    child: childBuildResults[0]!.widget,
                  ),
                  LineElement(
                    trailingMargin: 0.0,
                    child: childBuildResults[1]!.widget,
                  ),
                ],
              ),
            );
          },
          leftright: (final b) {
            final numElements = 2 + b.body.length + b.middle.length;
            final a = options.fontMetrics.axisHeight2.toLpUnder(options);
            final childWidgets = List.generate(
              numElements,
              (final index) {
                if (index.isEven) {
                  // Delimiter
                  return LineElement(
                    customCrossSize: (final height, final depth) {
                      final delta = max(height - a, depth + a);
                      final delimeterFullHeight = max(
                          delta / 500 * delimiterFactor, 2 * delta - delimiterShorfall.toLpUnder(options));
                      return BoxConstraints(
                        minHeight: delimeterFullHeight,
                      );
                    },
                    trailingMargin: index == numElements - 1
                        ? 0.0
                        : getSpacingSize(index == 0 ? AtomType.open : AtomType.rel,
                                b.body[(index + 1) ~/ 2].leftType, options.style)
                            .toLpUnder(options),
                    child: LayoutBuilderPreserveBaseline(
                      builder: (final context, final constraints) => buildCustomSizedDelimWidget(
                        index == 0
                            ? b.leftDelim
                            : index == numElements - 1
                                ? b.rightDelim
                                : b.middle[index ~/ 2 - 1],
                        constraints.minHeight,
                        options,
                      ),
                    ),
                  );
                } else {
                  // Content
                  return LineElement(
                    trailingMargin: getSpacingSize(b.body[index ~/ 2].rightType,
                            index == numElements - 2 ? AtomType.close : AtomType.rel, options.style)
                        .toLpUnder(options),
                    child: childBuildResults[index ~/ 2]!.widget,
                  );
                }
              },
              growable: false,
            );
            return GreenBuildResult(
              options: options,
              widget: Line(
                children: childWidgets,
              ),
            );
          },
          raisebox: (final a) {
            return GreenBuildResult(
              options: options,
              widget: ShiftBaseline(
                offset: a.dy.toLpUnder(options),
                child: childBuildResults[0]!.widget,
              ),
            );
          },
          style: (final a) {
            return GreenBuildResult(
              widget: const Text('This widget should not appear. '
                  'It means one of FlutterMath\'s AST nodes '
                  'forgot to handle the case for StyleNodes'),
              options: options,
              results: childBuildResults
                  .expand(
                    (final result) => result!.results ?? [result],
                  )
                  .toList(
                    growable: false,
                  ),
            );
          },
          equationrow: (final a) {
            final flattenedBuildResults = childBuildResults
                .expand(
                  (final result) => result!.results ?? [result],
                )
                .toList(
                  growable: false,
                );
            final flattenedChildOptions = flattenedBuildResults
                .map(
                  (final e) => e.options,
                )
                .toList(
                  growable: false,
                );
            // assert(flattenedChildList.length == actualChildWidgets.length);
            // We need to calculate spacings between nodes
            // There are several caveats to consider
            // - bin can only be bin, if it satisfies some conditions. Otherwise it will
            //   be seen as an ord
            // - There could aligners and spacers. We need to calculate the spacing
            //   after filtering them out, hence the [traverseNonSpaceNodes]
            final childSpacingConfs = List.generate(
              a.flattenedChildList.length,
              (final index) {
                final e = a.flattenedChildList[index];
                return NodeSpacingConf(
                  e.leftType,
                  e.rightType,
                  flattenedChildOptions[index],
                  0.0,
                );
              },
              growable: false,
            );
            traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
              if (prev?.rightType == AtomType.bin &&
                  const {
                    AtomType.rel,
                    AtomType.close,
                    AtomType.punct,
                    null,
                  }.contains(curr?.leftType)) {
                prev!.rightType = AtomType.ord;
                if (prev.leftType == AtomType.bin) {
                  prev.leftType = AtomType.ord;
                }
              } else if (curr?.leftType == AtomType.bin &&
                  const {
                    AtomType.bin,
                    AtomType.open,
                    AtomType.rel,
                    AtomType.op,
                    AtomType.punct,
                    null,
                  }.contains(prev?.rightType)) {
                curr!.leftType = AtomType.ord;
                if (curr.rightType == AtomType.bin) {
                  curr.rightType = AtomType.ord;
                }
              }
            });
            traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
              if (prev != null && curr != null) {
                prev.spacingAfter = getSpacingSize(
                  prev.rightType,
                  curr.leftType,
                  curr.options.style,
                ).toLpUnder(curr.options);
              }
            });
            a.key = GlobalKey();
            final lineChildren = List.generate(
              flattenedBuildResults.length,
              (final index) => LineElement(
                child: flattenedBuildResults[index].widget,
                canBreakBefore: false, // TODO
                alignerOrSpacer: () {
                  final cur = a.flattenedChildList[index];
                  return cur is TexGreenSpace && cur.alignerOrSpacer;
                }(),
                trailingMargin: childSpacingConfs[index].spacingAfter,
              ),
              growable: false,
            );
            final widget = Consumer<FlutterMathMode>(
              builder: (final context, final mode, final child) {
                if (mode == FlutterMathMode.view) {
                  return Line(
                    key: a.key!,
                    children: lineChildren,
                  );
                } else {
                  // Each EquationRow will filter out unrelated selection changes (changes
                  // happen entirely outside the range of this EquationRow)
                  return ProxyProvider<MathController, TextSelection>(
                    create: (final _) => const TextSelection.collapsed(offset: -1),
                    update: (final context, final controller, final _) {
                      final selection = controller.selection;
                      return selection.copyWith(
                        baseOffset: clampInteger(
                          selection.baseOffset,
                          a.range.start - 1,
                          a.range.end + 1,
                        ),
                        extentOffset: clampInteger(
                          selection.extentOffset,
                          a.range.start - 1,
                          a.range.end + 1,
                        ),
                      );
                    },
                    // Selector translates global cursor position to local caret index
                    // Will only update Line when selection range actually changes
                    child: Selector2<TextSelection, LayerLinkTuple, LayerLinkSelectionTuple>(
                      selector: (final context, final selection, final handleLayerLinks) {
                        final start = selection.start - a.pos;
                        final end = selection.end - a.pos;
                        final caretStart = a.caretPositions.slotFor(start).ceil();
                        final caretEnd = a.caretPositions.slotFor(end).floor();
                        return LayerLinkSelectionTuple(
                          selection: () {
                            if (caretStart <= caretEnd) {
                              if (selection.baseOffset <= selection.extentOffset) {
                                return TextSelection(baseOffset: caretStart, extentOffset: caretEnd);
                              } else {
                                return TextSelection(baseOffset: caretEnd, extentOffset: caretStart);
                              }
                            } else {
                              return const TextSelection.collapsed(offset: -1);
                            }
                          }(),
                          start: a.caretPositions.contains(start) ? handleLayerLinks.start : null,
                          end: a.caretPositions.contains(end) ? handleLayerLinks.end : null,
                        );
                      },
                      builder: (final context, final conf, final _) {
                        final value = Provider.of<SelectionStyle>(context);
                        return EditableLine(
                          key: a.key,
                          children: lineChildren,
                          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                          node: a,
                          preferredLineHeight: options.fontSize,
                          cursorBlinkOpacityController:
                              Provider.of<Wrapper<AnimationController>>(context).value,
                          selection: conf.selection,
                          startHandleLayerLink: conf.start,
                          endHandleLayerLink: conf.end,
                          cursorColor: value.cursorColor,
                          cursorOffset: value.cursorOffset,
                          cursorRadius: value.cursorRadius,
                          cursorWidth: value.cursorWidth,
                          cursorHeight: value.cursorHeight,
                          hintingColor: value.hintingColor,
                          paintCursorAboveText: value.paintCursorAboveText,
                          selectionColor: value.selectionColor,
                          showCursor: value.showCursor,
                        );
                      },
                    ),
                  );
                }
              },
            );
            return GreenBuildResult(
              options: options,
              italic: flattenedBuildResults.lastOrNull?.italic ?? 0.0,
              skew: flattenedBuildResults.length == 1 ? flattenedBuildResults.first.italic : 0.0,
              widget: widget,
            );
          },
        ),
        leaf: (final a) => a.matchLeaf(
          temporary: (final a) => throw UnsupportedError('Temporary node ${a.runtimeType} encountered.'),
          cursor: (final a) {
            final baselinePart = 1 - options.fontMetrics.axisHeight2.value / 2;
            final height = options.fontSize * baselinePart * options.sizeMultiplier;
            final baselineDistance = height * baselinePart;
            final cursor = Container(height: height, width: 1.5, color: options.color);
            return GreenBuildResult(
              options: options,
              widget: BaselineDistance(
                baselineDistance: baselineDistance,
                child: cursor,
              ),
            );
          },
          phantom: (final a) {
            final phantomRedNode = TexRedImpl(
              redParent: null,
              greenValue: a.phantomChild,
              pos: 0,
            );
            final phantomResult = TexWidget.buildWidget(
              node: phantomRedNode,
              newOptions: options,
            );
            Widget widget = Opacity(
              opacity: 0.0,
              child: phantomResult.widget,
            );
            widget = ResetDimension(
              width: a.zeroWidth ? 0 : null,
              height: a.zeroHeight ? 0 : null,
              depth: a.zeroDepth ? 0 : null,
              child: widget,
            );
            return GreenBuildResult(
              options: options,
              italic: phantomResult.italic,
              widget: widget,
            );
          },
          space: (final a) {
            if (a.alignerOrSpacer == true) {
              return GreenBuildResult(
                options: options,
                widget: Container(height: 0.0),
              );
            }
            final height = a.height.toLpUnder(options);
            final depth = (a.depth ?? Measurement.zeroPt).toLpUnder(options);
            final width = a.width.toLpUnder(options);
            final shift = (a.shift ?? Measurement.zeroPt).toLpUnder(options);
            final topMost = max(height, -depth) + shift;
            final bottomMost = min(height, -depth) + shift;
            return GreenBuildResult(
              options: options,
              widget: ResetBaseline(
                height: topMost,
                child: Container(
                  color: a.fill ? options.color : null,
                  height: topMost - bottomMost,
                  width: max(0.0, width),
                ),
              ),
            );
          },
          symbol: (final a) {
            final expanded = a.symbol.runes.expand(
              (final code) {
                final ch = String.fromCharCode(code);
                return unicodeSymbols[ch]?.split('') ?? [ch];
              },
            ).toList(growable: false);
            // If symbol is single code
            if (expanded.length == 1) {
              return makeBaseSymbol(
                symbol: expanded[0],
                variantForm: a.variantForm,
                atomType: a.atomType,
                overrideFont: a.overrideFont,
                mode: a.mode,
                options: options,
              );
            } else if (expanded.length > 1) {
              if (isCombiningMark(expanded[1])) {
                if (expanded[0] == 'i') {
                  expanded[0] = '\u0131'; // dotless i, in math and text mode
                } else if (expanded[0] == 'j') {
                  expanded[0] = '\u0237'; // dotless j, in math and text mode
                }
              }
              TexGreen res = a.withSymbol(expanded[0]);
              for (final ch in expanded.skip(1)) {
                final accent = unicodeAccentsSymbols[ch];
                if (accent == null) {
                  break;
                } else {
                  res = TexGreenAccentImpl(
                    base: greenNodeWrapWithEquationRow(res),
                    label: accent,
                    isStretchy: false,
                    isShifty: true,
                  );
                }
              }
              return TexWidget.buildWidget(
                node: TexRedImpl(
                  redParent: null,
                  greenValue: res,
                  pos: 0,
                ),
                newOptions: options,
              );
            } else {
              // TODO: log a warning here.
              return GreenBuildResult(
                widget: const SizedBox(
                  height: 0,
                  width: 0,
                ),
                options: options,
                italic: 0,
              );
            }
          },
        ),
      );
    }

    final _greenValue = node.greenValue;
    if (_greenValue is TexGreenEquationrow) {
      _greenValue.updatePos(node.pos);
    }
    final makeNewChildBuildResults = () {
      return node.greenValue.match(
        nonleaf: (final a) {
          final childOptions = a.computeChildOptions(newOptions);
          assert(node.children.length == childOptions.length, "");
          if (node.children.isEmpty) {
            return const <GreenBuildResult>[];
          } else {
            return List.generate(
              node.children.length,
              (final index) {
                final child = node.children[index];
                if (child == null) {
                  return null;
                } else {
                  return buildWidget(
                    node: child,
                    newOptions: childOptions[index],
                  );
                }
              },
              growable: false,
            );
          }
        },
        leaf: (final a) => <GreenBuildResult>[],
      );
    };
    final previousOptions = node.greenValue.cache.oldOptions;
    final previousChildBuildResults = node.greenValue.cache.oldChildBuildResults;
    node.greenValue.cache.oldOptions = newOptions;
    if (previousOptions != null) {
      // Previous options are not null so this can't
      // be the first frame because data exists.
      if (newOptions == previousOptions) {
        // Previous options are the same as new
        // options so we can return the cached result.
        return node.greenValue.cache.oldBuildResult!;
      } else {
        // Not the first frame and the options are new.
        if (node.greenValue.shouldRebuildWidget(previousOptions, newOptions)) {
          final newWidget = _texWidget(
            node.greenValue,
            newOptions,
            () {
              final newChildBuildResults = makeNewChildBuildResults();
              // Store the new build results.
              node.greenValue.cache.oldChildBuildResults = newChildBuildResults;
              return newChildBuildResults;
            }(),
          );
          // We are forced to rebuild.
          node.greenValue.cache.oldBuildResult = newWidget;
          return newWidget;
        } else {
          final newChildBuildResults = makeNewChildBuildResults();
          if (listEquals(newChildBuildResults, previousChildBuildResults)) {
            // Do nothing and return the cached data because the
            // previous and new children build results are the same.
            return node.greenValue.cache.oldBuildResult!;
          } else {
            // Child results have changed. Rebuild results.
            final newWidget = _texWidget(
              node.greenValue,
              newOptions,
              newChildBuildResults,
            );
            // Store the new widget.
            node.greenValue.cache.oldBuildResult = newWidget;
            // Store the new results.
            node.greenValue.cache.oldChildBuildResults = newChildBuildResults;
            return newWidget;
          }
        }
      }
    } else {
      // The previous options were null which means
      // this is the first frame so we have to build.
      final newWidget = _texWidget(
        node.greenValue,
        newOptions,
        () {
          final newChildBuildResults = makeNewChildBuildResults();
          // Store the new build results.
          node.greenValue.cache.oldChildBuildResults = newChildBuildResults;
          return newChildBuildResults;
        }(),
      );
      node.greenValue.cache.oldBuildResult = newWidget;
      return newWidget;
    }
  }
}

class MathController extends ChangeNotifier {
  MathController({
    required final TexRedEquationrowImpl ast,
    final TextSelection selection = const TextSelection.collapsed(
      offset: -1,
    ),
  })  : _ast = ast,
        _selection = selection;

  TexRedEquationrowImpl _ast;

  TexRedEquationrowImpl get ast => _ast;

  set ast(
    final TexRedEquationrowImpl value,
  ) {
    if (_ast != value) {
      _ast = value;
      _selection = const TextSelection.collapsed(offset: -1);
      notifyListeners();
    }
  }

  TextSelection get selection => _selection;
  TextSelection _selection;

  set selection(
    final TextSelection value,
  ) {
    if (_selection != value) {
      _selection = sanitizeSelection(ast, value);
      notifyListeners();
    }
  }

  TextSelection sanitizeSelection(
    final TexRedEquationrowImpl ast,
    final TextSelection selection,
  ) {
    if (selection.end <= 0) {
      return selection;
    } else {
      return textSelectionConstrainedBy(
        selection,
        texGetRange(
          ast.greenValue,
          ast.pos,
        ),
      );
    }
  }

  List<TexGreen> get selectedNodes => ast.findSelectedNodes(
        selection.start,
        selection.end,
      );
}

/// Mode for widget
enum FlutterMathMode {
  /// Editable (Unimplemented)
  edit,

  /// Selectable
  select,

  /// Non-selectable
  view,
}

/// Exceptions occurred during build.
class BuildException implements FlutterMathException {
  @override
  final String message;
  final StackTrace? trace;

  const BuildException(
    final this.message, {
    final this.trace,
  });

  @override
  String get messageWithType => 'Build Exception: $message';
}
