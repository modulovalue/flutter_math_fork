import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../ast/ast.dart';
import '../../utils/extensions.dart';
import 'line.dart';

class EditableLine extends MultiChildRenderObjectWidget {
  EditableLine({
    required final this.cursorColor,
    required final this.node,
    required final this.preferredLineHeight,
    final this.crossAxisAlignment = CrossAxisAlignment.baseline,
    final this.cursorBlinkOpacityController,
    final this.cursorOffset,
    final this.cursorOpacityAnimates = false,
    final this.cursorRadius,
    final this.cursorWidth = 1.0,
    final this.cursorHeight,
    final this.devicePixelRatio = 1.0,
    final this.hintingColor,
    final this.minDepth = 0.0,
    final this.minHeight = 0.0,
    final this.paintCursorAboveText = false,
    final this.selection = const TextSelection.collapsed(offset: -1),
    final this.selectionColor,
    final this.showCursor = false,
    final this.startHandleLayerLink,
    final this.endHandleLayerLink,
    final this.textBaseline = TextBaseline.alphabetic,
    final this.textDirection,
    final List<Widget> children = const [],
    final Key? key,
  }) : super(key: key, children: children);

  final CrossAxisAlignment crossAxisAlignment;

  final AnimationController? cursorBlinkOpacityController;

  final Color cursorColor;

  final Offset? cursorOffset;

  final bool cursorOpacityAnimates;

  final Radius? cursorRadius;

  final double cursorWidth;

  final double? cursorHeight;

  final double devicePixelRatio;

  final Color? hintingColor;

  final double minDepth;

  final double minHeight;

  final EquationRowNode node;

  final bool paintCursorAboveText;

  final double preferredLineHeight;

  final TextSelection selection;

  final Color? selectionColor;

  final bool showCursor;

  final LayerLink? startHandleLayerLink;

  final LayerLink? endHandleLayerLink;

  final TextBaseline textBaseline;

  final TextDirection? textDirection;

  bool get _needTextDirection => true;

  @protected
  TextDirection? getEffectiveTextDirection(final BuildContext context) =>
      textDirection ?? (_needTextDirection ? Directionality.of(context) : null);

  @override
  RenderEditableLine createRenderObject(final BuildContext context) => RenderEditableLine(
        crossAxisAlignment: crossAxisAlignment,
        cursorBlinkOpacityController: cursorBlinkOpacityController,
        cursorColor: cursorColor,
        cursorOffset: cursorOffset,
        cursorRadius: cursorRadius,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        devicePixelRatio: devicePixelRatio,
        hintingColor: hintingColor,
        minDepth: minDepth,
        minHeight: minHeight,
        node: node,
        paintCursorAboveText: paintCursorAboveText,
        preferredLineHeight: preferredLineHeight,
        selection: selection,
        selectionColor: selectionColor,
        showCursor: showCursor,
        startHandleLayerLink: startHandleLayerLink,
        endHandleLayerLink: endHandleLayerLink,
        textBaseline: textBaseline,
        textDirection: getEffectiveTextDirection(context),
      );

  @override
  void updateRenderObject(final BuildContext context, final RenderEditableLine renderObject) => renderObject
    ..crossAxisAlignment = crossAxisAlignment
    ..cursorBlinkOpacityController = cursorBlinkOpacityController
    ..cursorColor = cursorColor
    ..cursorOffset = cursorOffset
    ..cursorRadius = cursorRadius
    ..cursorWidth = cursorWidth
    ..cursorHeight = cursorHeight
    ..devicePixelRatio = devicePixelRatio
    ..hintingColor = hintingColor
    ..minDepth = minDepth
    ..minHeight = minHeight
    ..node = node
    ..paintCursorAboveText = paintCursorAboveText
    ..preferredLineHeight = preferredLineHeight
    ..selection = selection
    ..selectionColor = selectionColor
    ..showCursor = showCursor
    ..startHandleLayerLink = startHandleLayerLink
    ..endHandleLayerLink = endHandleLayerLink
    ..textBaseline = textBaseline
    ..textDirection = getEffectiveTextDirection(context);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}

class RenderEditableLine extends RenderLine {
  RenderEditableLine({
    required final this.node,
    required final this.preferredLineHeight,
    required final Color cursorColor,
    final List<RenderBox>? children,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.baseline,
    final AnimationController? cursorBlinkOpacityController,
    final Offset? cursorOffset,
    final Radius? cursorRadius,
    final double cursorWidth = 1.0,
    final double? cursorHeight,
    final double devicePixelRatio = 1.0,
    final Color? hintingColor,
    final double minDepth = 0,
    final double minHeight = 0,
    final bool paintCursorAboveText = false,
    final TextSelection selection = const TextSelection.collapsed(offset: -1),
    final Color? selectionColor,
    final bool showCursor = false,
    final LayerLink? startHandleLayerLink,
    final LayerLink? endHandleLayerLink,
    final TextBaseline textBaseline = TextBaseline.alphabetic,
    final TextDirection? textDirection = TextDirection.ltr,
  })  :
        // assert(!showCursor || cursorColor != null),
        _cursorBlinkOpacityController = cursorBlinkOpacityController,
        _cursorColor = cursorColor,
        _cursorOffset = cursorOffset,
        _cursorRadius = cursorRadius,
        _cursorWidth = cursorWidth,
        _cursorHeight = cursorHeight,
        _devicePixelRatio = devicePixelRatio,
        _hintingColor = hintingColor,
        _paintCursorAboveText = paintCursorAboveText,
        _selection = selection,
        _selectionColor = selectionColor,
        _showCursor = showCursor,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink,
        super(
          children: children,
          crossAxisAlignment: crossAxisAlignment,
          minDepth: minDepth,
          minHeight: minHeight,
          textBaseline: textBaseline,
          textDirection: textDirection,
        );

  AnimationController? get cursorBlinkOpacityController => _cursorBlinkOpacityController;
  AnimationController? _cursorBlinkOpacityController;

  set cursorBlinkOpacityController(final AnimationController? value) {
    if (_cursorBlinkOpacityController != value) {
      _cursorBlinkOpacityController?.removeListener(onCursorOpacityChanged);
      _cursorBlinkOpacityController = value;
      _cursorBlinkOpacityController?.addListener(onCursorOpacityChanged);
      markNeedsPaint();
    }
  }

  void onCursorOpacityChanged() {
    if (showCursor && selection.isCollapsed && isSelectionInRange) {
      markNeedsPaint();
    }
  }

  /// The color to use when painting the cursor.
  Color get cursorColor => _cursorColor;
  Color _cursorColor;

  set cursorColor(final Color value) {
    if (_cursorColor != value) {
      _cursorColor = value;
      markNeedsPaint();
    }
  }

  /// {@macro flutter.rendering.editable.cursorOffset}
  Offset? get cursorOffset => _cursorOffset;
  Offset? _cursorOffset;

  set cursorOffset(final Offset? value) {
    if (_cursorOffset != value) {
      _cursorOffset = value;
      markNeedsPaint();
    }
  }

  /// How rounded the corners of the cursor should be.
  ///
  /// A null value is the same as [Radius.zero].
  Radius? get cursorRadius => _cursorRadius;
  Radius? _cursorRadius;

  set cursorRadius(final Radius? value) {
    if (_cursorRadius != value) {
      _cursorRadius = value;
      markNeedsPaint();
    }
  }

  double get cursorWidth => _cursorWidth;
  double _cursorWidth;

  set cursorWidth(final double value) {
    if (_cursorWidth != value) {
      _cursorWidth = value;
      markNeedsPaint();
    }
  }

  /// How tall the cursor will be.
  ///
  /// This can be null, in which case the getter will actually return
  /// [preferredLineHeight].
  ///
  /// Setting this to itself fixes the value to the current
  /// [preferredLineHeight]. Setting
  /// this to null returns the behaviour of deferring to [preferredLineHeight].
  double get cursorHeight => _cursorHeight ?? preferredLineHeight;
  double? _cursorHeight;

  set cursorHeight(final double? value) {
    if (_cursorHeight != value) {
      _cursorHeight = value;
      markNeedsPaint();
    }
  }

  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;

  set devicePixelRatio(final double value) {
    if (_devicePixelRatio != value) {
      _devicePixelRatio = value;
      markNeedsPaint();
    }
  }

  Color? get hintingColor => _hintingColor;
  Color? _hintingColor;

  set hintingColor(final Color? value) {
    if (_hintingColor != value) {
      _hintingColor = value;
      markNeedsPaint();
    }
  }

  EquationRowNode node;

  /// {@template flutter.rendering.editable.paintCursorOnTop}
  bool get paintCursorAboveText => _paintCursorAboveText;
  bool _paintCursorAboveText;

  set paintCursorAboveText(final bool value) {
    if (_paintCursorAboveText != value) {
      _paintCursorAboveText = value;
      markNeedsPaint();
    }
  }

  double preferredLineHeight;

  TextSelection get selection => _selection;
  TextSelection _selection;

  set selection(final TextSelection value) {
    if (_selection != value) {
      _selection = value;
      markNeedsPaint();
    }
  }

  /// The color to use when painting the selection.
  Color? get selectionColor => _selectionColor;
  Color? _selectionColor;

  set selectionColor(final Color? value) {
    if (_selectionColor != value) {
      _selectionColor = value;
      markNeedsPaint();
    }
  }

  /// Whether to paint the cursor.
  bool get showCursor => _showCursor;
  bool _showCursor;

  set showCursor(final bool value) {
    if (_showCursor != value) {
      _showCursor = value;
      markNeedsPaint();
    }
  }

  LayerLink? get startHandleLayerLink => _startHandleLayerLink;
  LayerLink? _startHandleLayerLink;

  set startHandleLayerLink(final LayerLink? value) {
    if (_startHandleLayerLink != value) {
      _startHandleLayerLink = value;
      markNeedsPaint();
    }
  }

  LayerLink? get endHandleLayerLink => _endHandleLayerLink;
  LayerLink? _endHandleLayerLink;

  set endHandleLayerLink(final LayerLink? value) {
    if (_endHandleLayerLink != value) {
      _endHandleLayerLink = value;
      markNeedsPaint();
    }
  }

  bool get isSelectionInRange => _selection.end >= 0 && _selection.start <= childCount;

  int getCaretIndexForPoint(final Offset globalOffset) {
    final localOffset = globalToLocal(globalOffset);
    var minDist = double.infinity;
    var minPosition = 0;
    for (var i = 0; i < caretOffsets.length; i++) {
      final dist = (caretOffsets[i] - localOffset.dx).abs();
      if (dist <= minDist) {
        minDist = dist;
        minPosition = i;
      }
    }
    return minPosition;
  }

  // Will always attempt to get the nearest left caret
  int getNearestLeftCaretIndexForPoint(final Offset globalOffset) {
    final localOffset = globalToLocal(globalOffset);
    var index = 0;
    while (index < caretOffsets.length && caretOffsets[index] <= localOffset.dx) {
      index++;
    }
    return math.max(0, index - 1);
  }

  Offset getEndpointForCaretIndex(
    final int index,
  ) {
    final dx = caretOffsets[clampInteger(
      index,
      0,
      caretOffsets.length - 1,
    )];
    final dy = size.height;
    return localToGlobal(Offset(dx, dy));
  }

  @override
  bool hitTestSelf(final Offset position) => true;

  @override
  void paint(
    final PaintingContext context,
    final Offset offset,
  ) {
    // Only paint selection/hinting if the part of the selection is in range
    if (isSelectionInRange) {
      final startOffset = caretOffsets[math.max(0, selection.start)];
      final endOffset = caretOffsets[math.min(childCount, selection.end)];
      if (_selection.isCollapsed) {
        if (_hintingColor != null) {
          // Paint hinting background if selection is collapsed
          context.canvas.drawRect(
            offset & size,
            Paint()
              ..style = PaintingStyle.fill
              ..color = _hintingColor!,
          );
        }
      } else if (_selectionColor != null) {
        // Paint selection if not collapsed
        context.canvas.drawRect(
          Rect.fromLTRB(startOffset, 0, endOffset, size.height).shift(offset),
          Paint()
            ..style = PaintingStyle.fill
            ..color = _selectionColor!,
        );
      }

      // Whatever which case, we need to mark the layer link.
      if (startHandleLayerLink != null) {
        context.pushLayer(
          LeaderLayer(
            link: startHandleLayerLink!,
            offset: Offset(startOffset, size.height) + offset,
          ),
          emptyPaintFunction,
          Offset.zero,
        );
      }
      if (endHandleLayerLink != null) {
        context.pushLayer(
          LeaderLayer(
            link: endHandleLayerLink!,
            offset: Offset(endOffset, size.height) + offset,
          ),
          emptyPaintFunction,
          Offset.zero,
        );
      }
    }

    if (_paintCursorAboveText) {
      super.paint(context, offset);
    }

    if (showCursor && _selection.isCollapsed && isSelectionInRange) {
      final cursorOffset = caretOffsets[selection.baseOffset];
      _paintCaret(context.canvas, Offset(cursorOffset, size.height) + offset);
    }

    if (!_paintCursorAboveText) {
      super.paint(context, offset);
    }

    return;
  }

  // static const _kCaretHeightOffset = 2.0;

  void _paintCaret(final Canvas canvas, final Offset baselineOffset) {
    final paint = Paint()..color = _cursorColor.withOpacity(_cursorBlinkOpacityController?.value ?? 0);

    Rect _caretPrototype;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _caretPrototype = Rect.fromLTWH(
          0.0,
          0.0,
          _cursorWidth,
          cursorHeight + 2,
        );
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _caretPrototype = Rect.fromLTWH(
          0.0,
          0.0, // _kCaretHeightOffset,
          _cursorWidth,
          cursorHeight, // - 2.0 * _kCaretHeightOffset,
        );
        break;
    }

    var caretRect =
        _caretPrototype.shift(baselineOffset).shift(Offset(0, -0.9 * cursorHeight)); // 0.9 is eyeballed

    if (_cursorOffset != null) {
      caretRect = caretRect.shift(_cursorOffset!);
    }

    // final double caretHeight =
    //     _textPainter.getFullHeightForCaret(textPosition, _caretPrototype);
    // if (caretHeight != null) {
    //   switch (defaultTargetPlatform) {
    //     case TargetPlatform.iOS:
    //     case TargetPlatform.macOS:
    //       final heightDiff = caretHeight - caretRect.height;
    //       // Center the caret vertically along the text.
    //       caretRect = Rect.fromLTWH(
    //         caretRect.left,
    //         caretRect.top + heightDiff / 2,
    //         caretRect.width,
    //         caretRect.height,
    //       );
    //       break;
    //     case TargetPlatform.android:
    //     case TargetPlatform.fuchsia:
    //     case TargetPlatform.linux:
    //     case TargetPlatform.windows:
    //       // Override the height to take the full height of the glyph at the TextPosition
    //       // when not on iOS. iOS has special handling that creates a taller caret.
    //       caretRect = Rect.fromLTWH(
    //         caretRect.left,
    //         caretRect.top - _kCaretHeightOffset,
    //         caretRect.width,
    //         caretHeight,
    //       );
    //       break;
    //   }
    // }

    caretRect = caretRect.shift(_getPixelPerfectCursorOffset(caretRect));

    if (_cursorRadius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final caretRRect = RRect.fromRectAndRadius(caretRect, _cursorRadius!);
      canvas.drawRRect(caretRRect, paint);
    }
  }

  /// Computes the offset to apply to the given [caretRect] so it perfectly
  /// snaps to physical pixels.
  Offset _getPixelPerfectCursorOffset(final Rect caretRect) {
    final caretPosition = localToGlobal(caretRect.topLeft);
    final pixelMultiple = 1.0 / _devicePixelRatio;
    final pixelPerfectOffsetX = caretPosition.dx.isFinite
        ? (caretPosition.dx / pixelMultiple).round() * pixelMultiple - caretPosition.dx
        : 0.0;
    final pixelPerfectOffsetY = caretPosition.dy.isFinite
        ? (caretPosition.dy / pixelMultiple).round() * pixelMultiple - caretPosition.dy
        : 0.0;
    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }
}

void emptyPaintFunction(final PaintingContext context, final Offset offset) {}
