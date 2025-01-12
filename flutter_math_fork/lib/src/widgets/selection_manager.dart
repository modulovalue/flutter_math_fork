import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../encoder/tex_encoder.dart';
import '../render/layout.dart';
import '../utils/render_box_extensions.dart';
import 'tex.dart';

enum ExtraSelectionChangedCause {
  // Selection handle dragged,
  handle,

  // Unfocused
  unfocus,

  // Changed by other code directly manipulating controller.
  exterior,
}

mixin SelectionManagerMixin<T extends StatefulWidget> on State<T> implements TextSelectionDelegate {
  MathController get controller;

  FocusNode get focusNode;

  bool get hasFocus;

  late FocusNode _oldFocusNode;

  late MathController _oldController;

  @override
  void initState() {
    super.initState();
    _oldFocusNode = focusNode..addListener(_handleFocusChange);
    _oldController = controller..addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(final T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (focusNode != _oldFocusNode) {
      _oldFocusNode.removeListener(_handleFocusChange);
      _oldFocusNode = focusNode..addListener(_handleFocusChange);
      _handleFocusChange();
    }
    if (controller != _oldController) {
      _oldController.removeListener(_onControllerChanged);
      _oldController = controller..addListener(_onControllerChanged);
      _onControllerChanged();
    }
  }

  @override
  void dispose() {
    _oldController.removeListener(_onControllerChanged);
    _oldFocusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (!hasFocus) {
      handleSelectionChanged(
        const TextSelection.collapsed(offset: -1),
        null,
        ExtraSelectionChangedCause.unfocus,
      );
    }
  }

  TexRed? _oldAst;
  TextSelection? _oldSelection;

  void _onControllerChanged() {
    if (_oldAst != controller.ast || _oldSelection != controller.selection) {
      handleSelectionChanged(
        controller.selection,
        null,
        ExtraSelectionChangedCause.exterior,
      );
    }
  }

  void onSelectionChanged(
    final TextSelection selection,
    final SelectionChangedCause? cause,
  );

  @mustCallSuper
  void handleSelectionChanged(
    final TextSelection selection,
    final SelectionChangedCause? cause, [
    final ExtraSelectionChangedCause? extraCause,
  ]) {
    if (extraCause != ExtraSelectionChangedCause.unfocus &&
        extraCause != ExtraSelectionChangedCause.exterior &&
        !hasFocus) {
      focusNode.requestFocus();
    }
    _oldAst = controller.ast;
    _oldSelection = selection;
    controller.selection = selection;
    onSelectionChanged(selection, cause);
  }

  void selectPositionAt({
    required final Offset from,
    required final SelectionChangedCause cause,
    final Offset? to,
  }) {
    final fromPosition = getPositionForOffset(from);
    final toPosition = () {
      if (to == null) {
        return fromPosition;
      } else {
        return getPositionForOffset(to);
      }
    }();
    handleSelectionChanged(
      TextSelection(
        baseOffset: fromPosition,
        extentOffset: toPosition,
      ),
      cause,
    );
  }

  void selectWordAt({
    required final Offset offset,
    required final SelectionChangedCause cause,
  }) {
    handleSelectionChanged(
      getWordRangeAtPoint(offset),
      cause,
    );
  }

  RenderEditableLine getRenderLineAtOffset(
    final Offset globalOffset,
  ) {
    final rootRenderBox = this.rootRenderBox;
    final rootOffset = rootRenderBox.globalToLocal(globalOffset);
    final constrainedOffset = Offset(
      rootOffset.dx.clamp(0.0, rootRenderBox.size.width),
      rootOffset.dy.clamp(0.0, rootRenderBox.size.height),
    );
    return renderBoxHittestFindLowest<RenderEditableLine>(
          (controller.ast.greenValue.key!.currentContext!.findRenderObject() as RenderEditableLine?)!,
          constrainedOffset,
        ) ??
        (controller.ast.greenValue.key!.currentContext!.findRenderObject() as RenderEditableLine?)!;
  }

  RenderBox get rootRenderBox => (context.findRenderObject() as RenderBox?)!;

  int getPositionForOffset(
    final Offset globalOffset,
  ) {
    final target = getRenderLineAtOffset(globalOffset);
    final caretIndex = target.getCaretIndexForPoint(globalOffset);
    return target.node.pos + target.node.caretPositions[caretIndex];
  }

  Offset getLocalEndpointForPosition(
    final int position,
  ) {
    final node = findNodeManagesPosition(
      controller.ast,
      position,
    );
    int caretIndex = node.caretPositions.indexWhere(
      (final caretPosition) => caretPosition >= position,
    );
    if (caretIndex == -1) {
      caretIndex = node.caretPositions.length - 1;
    }
    final renderLine = (node.key!.currentContext!.findRenderObject() as RenderEditableLine?)!;
    final globalOffset = renderLine.getEndpointForCaretIndex(caretIndex);
    return rootRenderBox.globalToLocal(globalOffset);
  }

  TextSelection getWordRangeAtPoint(
    final Offset globalOffset,
  ) {
    final target = getRenderLineAtOffset(globalOffset);
    final caretIndex = target.getNearestLeftCaretIndexForPoint(globalOffset);
    final node = target.node;
    final extentCaretIndex = max(
      0,
      () {
        if (caretIndex + 1 >= node.caretPositions.length) {
          return caretIndex - 1;
        } else {
          return caretIndex + 1;
        }
      }(),
    );
    final base = node.pos + node.caretPositions[caretIndex];
    final extent = node.pos + node.caretPositions[extentCaretIndex];
    return TextSelection(
      baseOffset: min(base, extent),
      extentOffset: max(base, extent),
    );
  }

  TextSelection getWordsRangeInRange({
    required final Offset from,
    required final Offset to,
  }) {
    final range1 = getWordRangeAtPoint(from);
    final range2 = getWordRangeAtPoint(to);

    if (range1.start <= range2.start) {
      return TextSelection(baseOffset: range1.start, extentOffset: range2.end);
    } else {
      return TextSelection(baseOffset: range1.end, extentOffset: range2.start);
    }
  }

  Rect getLocalEditingRegion() {
    final root = (controller.ast.greenValue.key!.currentContext!.findRenderObject() as RenderEditableLine?)!;
    return Rect.fromPoints(
      Offset.zero,
      root.size.bottomRight(Offset.zero),
    );
  }

  @override
  TextEditingValue get textEditingValue {
    final encodeResult = listEncodeTex(
      controller.selectedNodes,
    );
    return TextEditingValue(
      text: () {
        if (controller.selection.start == 0 &&
            controller.selection.end == texCapturedCursor(controller.ast.greenValue) - 1) {
          return encodeResult;
        } else {
          return '$encodeResult$_selectAllReservedTag';
        }
      }(),
      selection: TextSelection(
        baseOffset: 0,
        extentOffset: encodeResult.length,
      ),
    );
  }

  static const _selectAllReservedTag = 'THIS MARKUP SHOULD NOT APPEAR!';

  @override
  set textEditingValue(
    final TextEditingValue value,
  ) {
    // Select All ?
    if (value.selection.start == 0 &&
        value.selection.end == value.text.length &&
        value.text.length > texCapturedCursor(controller.ast.greenValue) - 1) {
      handleSelectionChanged(
        TextSelection(
          baseOffset: 0,
          extentOffset: texCapturedCursor(controller.ast.greenValue) - 1,
        ),
        null,
        ExtraSelectionChangedCause.handle,
      );
    }
  }
}
