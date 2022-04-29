import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../ast/ast_plus.dart';
import 'gesture_detector_builder.dart';
import 'gesture_detector_builder_selectable.dart';
import 'overlay.dart';
import 'selection_manager.dart';

mixin SelectionOverlayManagerMixin<T extends StatefulWidget> on SelectionManagerMixin<T>
    implements MathSelectionGestureDetectorBuilderDelegate {
  @override
  FocusNode get focusNode;

  @override
  bool get hasFocus => focusNode.hasFocus;

  double get preferredLineHeight;

  TextSelectionControls get textSelectionControls;

  DragStartBehavior get dragStartBehavior;

  MathSelectionOverlay? get selectionOverlay => _selectionOverlay;
  MathSelectionOverlay? _selectionOverlay;

  final toolbarLayerLink = LayerLink();

  final startHandleLayerLink = LayerLink();

  final endHandleLayerLink = LayerLink();

  bool toolbarVisible = false;

  late SelectableMathSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  SelectableMathSelectionGestureDetectorBuilder get selectionGestureDetectorBuilder =>
      _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder = SelectableMathSelectionGestureDetectorBuilder(
      delegate: this,
    );
  }

  @override
  void didUpdateWidget(
    final T oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _selectionOverlay?.update();
  }

  @override
  void dispose() {
    _selectionOverlay?.dispose();
    super.dispose();
  }

  /// Shows the selection toolbar at the location of the current cursor.
  ///
  /// Returns `false` if a toolbar couldn't be shown, such as when the toolbar
  /// is already shown, or when no text selection currently exists.
  bool showToolbar() {
    // Web is using native dom elements to enable clipboard functionality of the
    // toolbar: copy, paste, select, cut. It might also provide additional
    // functionality depending on the browser (such as translate). Due to this
    // we should not show a Flutter toolbar for the editable text elements.
    if (kIsWeb) {
      return false;
    } else if (_selectionOverlay == null || _selectionOverlay!.toolbarIsVisible) {
      return false;
    } else if (controller.selection.isCollapsed) {
      return false;
    }
    _selectionOverlay!.showToolbar();
    toolbarVisible = true;
    return true;
  }

  @override
  void hideToolbar([
    final bool hideHandles = true,
  ]) {
    toolbarVisible = false;
    _selectionOverlay?.hideToolbar();
  }

  void hide() {
    toolbarVisible = false;
    _selectionOverlay?.hide();
  }

  bool _shouldShowSelectionHandles(
    final SelectionChangedCause? cause,
  ) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    } else if (controller.selection.isCollapsed) {
      return false;
    } else if (cause == SelectionChangedCause.keyboard) {
      return false;
    } else if (cause == SelectionChangedCause.longPress) {
      return true;
    } else if (texCapturedCursor(controller.ast.greenValue) > 1) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void handleSelectionChanged(
    final TextSelection selection,
    final SelectionChangedCause? cause, [
    final ExtraSelectionChangedCause? extraCause,
  ]) {
    super.handleSelectionChanged(selection, cause, extraCause);
    if (extraCause != ExtraSelectionChangedCause.handle) {
      _selectionOverlay?.hide();
      _selectionOverlay = null;
      // if (textSelectionControls != null) {
      _selectionOverlay = MathSelectionOverlay(
        clipboardStatus: () {
          if (kIsWeb) {
            return null;
          } else {
            return ClipboardStatusNotifier();
          }
        }(),
        manager: this,
        toolbarLayerLink: toolbarLayerLink,
        startHandleLayerLink: startHandleLayerLink,
        endHandleLayerLink: endHandleLayerLink,
        onSelectionHandleTapped: () {
          if (!controller.selection.isCollapsed) {
            if (toolbarVisible) {
              hideToolbar();
            } else {
              showToolbar();
            }
          }
        },
        selectionControls: textSelectionControls,
        dragStartBehavior: dragStartBehavior,
        debugRequiredFor: widget,
      );
      _selectionOverlay!.handlesVisible = _shouldShowSelectionHandles(cause);
      if (SchedulerBinding.instance!.schedulerPhase == SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance!.addPostFrameCallback((final _) => _selectionOverlay!.showHandles());
      } else {
        _selectionOverlay!.showHandles();
      }
      // _selectionOverlay.showHandles();
      // }
    } else {
      _selectionOverlay?.update();
    }
  }
}
