import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../parser/parse_error.dart';
import '../parser/parser.dart';
import '../parser/settings.dart';
import '../utils/wrapper.dart';
import 'controller.dart';
import 'exception.dart';
import 'math.dart';
import 'mode.dart';
import 'selection/cursor_timer_manager.dart';
import 'selection/focus_manager.dart';
import 'selection/overlay_manager.dart';
import 'selection/selection_manager.dart';
import 'selection/web_selection_manager.dart';

const defaultSelection = TextSelection.collapsed(offset: -1);

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
  final SyntaxTree? ast;

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
    SyntaxTree? ast;
    ParseException? parseError;
    try {
      ast = SyntaxTree(greenRoot: TexParser(expression, settings).parse());
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
  Widget build(final BuildContext context) {
    if (parseException != null) {
      return onErrorFallback(parseException!);
    }

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
      ast!.buildWidget(options);
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

  final SyntaxTree ast;

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
    final child = controller.ast.buildWidget(widget.options);
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
