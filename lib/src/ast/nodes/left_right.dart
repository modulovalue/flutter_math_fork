import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../font/metrics/font_metrics.dart';
import '../../render/constants.dart';
import '../../render/layout/custom_layout.dart';
import '../../render/layout/layout_builder_baseline.dart';
import '../../render/layout/line.dart';
import '../../render/layout/shift_baseline.dart';
import '../../render/svg/delimiter.dart';
import '../../render/symbols/make_atom.dart';
import '../../render/utils/render_box_offset.dart';
import '../../utils/iterable_extensions.dart';
import '../options.dart';
import '../size.dart';
import '../spacing.dart';
import '../syntax_tree.dart';
import '../types.dart';

class LeftRightNode extends SlotableNode {
  final String leftDelim;
  final String rightDelim;
  final List<EquationRowNode> body;
  final List<String> middle;
  LeftRightNode({
    @required this.leftDelim,
    @required this.rightDelim,
    @required this.body,
    this.middle = const [],
  })  : assert(body.isNotEmpty),
        assert(body.every((element) => element != null)),
        assert(middle.length == body.length - 1);

  @override
  List<BuildResult> buildSlotableWidget(
      Options options, List<BuildResult> childBuildResults) {
    final numElements = 2 + body.length + middle.length;
    final a = options.fontMetrics.axisHeight.cssEm.toLpUnder(options);

    final childWidgets = List.generate(numElements, (index) {
      if (index % 2 == 0) {
        // Delimiter
        return LineElement(
          customCrossSize: (height, depth) {
            final delta = math.max(height - a, depth + a);
            final delimeterFullHeight = math.max(delta / 500 * delimiterFactor,
                2 * delta - delimiterShorfall.toLpUnder(options));
            return BoxConstraints(minHeight: delimeterFullHeight);
          },
          trailingMargin: index == numElements - 1
              ? 0.0
              : getSpacingSize(index == 0 ? AtomType.open : AtomType.rel,
                      body[(index + 1) ~/ 2].leftType, options.style)
                  .toLpUnder(options),
          child: LayoutBuilderPreserveBaseline(
            builder: (context, constraints) => buildCustomSizedDelimWidget(
              index == 0
                  ? leftDelim
                  : index == numElements - 1
                      ? rightDelim
                      : middle[index ~/ 2 - 1],
              constraints.minHeight,
              options,
            ),
          ),
        );
      } else {
        // Content
        return LineElement(
          trailingMargin: getSpacingSize(
                  body[index ~/ 2].rightType,
                  index == numElements - 2 ? AtomType.close : AtomType.rel,
                  options.style)
              .toLpUnder(options),
          child: childBuildResults[index ~/ 2].widget,
        );
      }
    }, growable: false);
    return [
      BuildResult(
        italic: 0.0,
        options: options,
        widget: Line(
          children: childWidgets,
        ),
      )
    ];
  }

  @override
  List<Options> computeChildOptions(Options options) =>
      List.filled(body.length, options, growable: false);

  @override
  List<EquationRowNode> computeChildren() => body;

  @override
  AtomType get leftType => AtomType.open;

  @override
  AtomType get rightType => AtomType.close;

  @override
  bool shouldRebuildWidget(Options oldOptions, Options newOptions) => false;

  @override
  ParentableNode<EquationRowNode> updateChildren(
          List<EquationRowNode> newChildren) =>
      LeftRightNode(
        leftDelim: leftDelim,
        rightDelim: rightDelim,
        body: newChildren,
        middle: middle,
      );
}

class _LeftRightId {
  final bool isDelimiter;
  final int number;
  const _LeftRightId({
    @required this.isDelimiter,
    @required this.number,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is _LeftRightId &&
        o.isDelimiter == isDelimiter &&
        o.number == number;
  }

  @override
  int get hashCode => isDelimiter.hashCode ^ number.hashCode;
}

// TexBook Appendix B
const delimiterFactor = 901;
const delimiterShorfall = Measurement(value: 5.0, unit: Unit.pt);

// Delimiter layout is specified in TexBook Rule 19
class LeftRightLayoutDelegate extends CustomLayoutDelegate<_LeftRightId> {
  final Options options;
  // final bool fracLeftDelim;
  // final bool fracRightDelim;
  LeftRightLayoutDelegate({
    @required this.options,
    // this.fracLeftDelim = false,
    // this.fracRightDelim = false,
  });

  double height;

  @override
  double computeDistanceToActualBaseline(
          TextBaseline baseline, Map<_LeftRightId, RenderBox> childrenTable) =>
      height;

  @override
  double getIntrinsicSize({
    Axis sizingDirection,
    bool max,
    double extent,
    double Function(RenderBox child, double extent) childSize,
    Map<_LeftRightId, RenderBox> childrenTable,
  }) =>
      0.0;

  @override
  Size performLayout(BoxConstraints constraints,
      Map<_LeftRightId, RenderBox> childrenTable, RenderBox renderBox) {
    final bodyChildren = (childrenTable.entries
            .where((entry) => !entry.key.isDelimiter)
            .toList(growable: false)
              ..sortBy<num>((e) => e.key.number))
        .map((e) => e.value)
        .toList(growable: false);
    final delimiterChildren = (childrenTable.entries
            .where((entry) => entry.key.isDelimiter)
            .toList(growable: false)
              ..sortBy<num>((e) => e.key.number))
        .map((e) => e.value)
        .toList(growable: false);

    for (final bodyChild in bodyChildren) {
      bodyChild.layout(infiniteConstraint, parentUsesSize: true);
    }

    final a = options.fontMetrics.axisHeight.cssEm.toLpUnder(options);
    final deltas = bodyChildren.map((element) =>
        math.max(element.layoutHeight - a, element.layoutDepth + a));
    final delta = deltas.max();

    final delimiterFullHeight = math.max(delta / 500 * delimiterFactor,
        2 * delta - delimiterShorfall.toLpUnder(options));

    for (final delimiter in delimiterChildren) {
      delimiter.layout(BoxConstraints(minHeight: delimiterFullHeight),
          parentUsesSize: true);
    }

    final spacingLeft =
        getSpacingSize(AtomType.open, AtomType.ord, options.style)
            .toLpUnder(options);

    final spacingMidLeft =
        getSpacingSize(AtomType.ord, AtomType.rel, options.style)
            .toLpUnder(options);

    final spacingMidRight =
        getSpacingSize(AtomType.rel, AtomType.ord, options.style)
            .toLpUnder(options);

    final spacingRight =
        getSpacingSize(AtomType.ord, AtomType.close, options.style)
            .toLpUnder(options);

    final childHeights = childrenTable.entries
        .map((entry) => entry.key.isDelimiter
            ? entry.value.size.height / 2 + a
            : entry.value.layoutHeight)
        .toList(growable: false);

    // final bodyHeights = bodyChildren.map((e) => e.layoutHeight);

    // final delimiterHeights =
    //     delimiterChildren.map((e) => e.size.height / 2 + a);

    height = childHeights.max();

    final bodyDepth = bodyChildren.map((e) => e.layoutDepth);

    final delimiterDepths = delimiterChildren.map((e) => e.size.height / 2 - a);

    final depth = [...bodyDepth, ...delimiterDepths].max();

    var index = 0;
    var currPos = 0.0;
    for (final entry in childrenTable.entries) {
      final child = entry.value;
      if (index == childrenTable.length - 1) {
        currPos += spacingRight;
      } else if (index != 0 && entry.key.isDelimiter) {
        currPos += spacingMidLeft;
      }
      child.offset = Offset(currPos, height - childHeights[index]);
      currPos += child.size.width;
      if (index == 0) {
        currPos += spacingLeft;
      } else if (index != childrenTable.length - 1 && entry.key.isDelimiter) {
        currPos += spacingMidRight;
      }
      index++;
    }
    return Size(currPos, height + depth);
  }
}

const stackLargeDelimiters = {
  '(', ')',
  '[', ']',
  '{', '}',
  '\u230a', '\u230b', // '\\lfloor', '\\rfloor',
  '\u2308', '\u2309', // '\\lceil', '\\rceil',
  '\u221a', // '\\surd'
};

// delimiters that always stack
const stackAlwaysDelimiters = {
  '\u2191', // '\\uparrow',
  '\u2193', // '\\downarrow',
  '\u2195', // '\\updownarrow',
  '\u21d1', // '\\Uparrow',
  '\u21d3', // '\\Downarrow',
  '\u21d5', // '\\Updownarrow',
  '|',
  // '\\|',
  // '\\vert',
  '\u2016', // '\\Vert', '\u2225'
  '\u2223', // '\\lvert', '\\rvert', '\\mid'
  '\u2225', // '\\lVert', '\\rVert',
  '\u27ee', // '\\lgroup',
  '\u27ef', // '\\rgroup',
  '\u23b0', // '\\lmoustache',
  '\u23b1', // '\\rmoustache',
};

// and delimiters that never stack
const stackNeverDelimiters = {
  '<',
  '>',
  '/',
};

Widget buildCustomSizedDelimWidget(
    String delim, double minDelimiterHeight, Options options) {
  if (delim == null) {
    final axisHeight = options.fontMetrics.xHeight.cssEm.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.5,
      offset: axisHeight,
      child: Container(
        height: minDelimiterHeight,
        width: nullDelimiterSpace.toLpUnder(options),
      ),
    );
  }

  List<DelimiterConf> sequence;
  if (stackNeverDelimiters.contains(delim)) {
    sequence = stackNeverDelimiterSequence;
  } else if (stackLargeDelimiters.contains(delim)) {
    sequence = stackLargeDelimiterSequence;
  } else {
    sequence = stackAlwaysDelimiterSequence;
  }

  var delimConf = sequence.firstWhereOrNull((element) =>
      getHeightForDelim(
        delim: delim,
        fontName: element.font.fontName,
        style: element.style,
        options: options,
      ) >
      minDelimiterHeight);
  if (stackNeverDelimiters.contains(delim)) {
    delimConf ??= sequence.last;
  }

  if (delimConf != null) {
    final axisHeight = options.fontMetrics.xHeight.cssEm.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.0,
      offset: axisHeight,
      child: makeChar(delim, delimConf.font,
          lookupChar(delim, delimConf.font, Mode.math), options),
    );
  } else {
    return makeStakedDelim(delim, minDelimiterHeight, Mode.math, options);
  }
}

Widget makeStakedDelim(
    String delim, double minDelimiterHeight, Mode mode, Options options) {
  final conf = stackDelimiterConfs[delim];
  final topMetrics = lookupChar(conf.top, conf.font, Mode.math);
  final repeatMetrics = lookupChar(conf.repeat, conf.font, Mode.math);
  final bottomMetrics = lookupChar(conf.bottom, conf.font, Mode.math);

  final topHeight =
      (topMetrics.height + topMetrics.depth).cssEm.toLpUnder(options);
  final repeatHeight =
      (repeatMetrics.height + repeatMetrics.depth).cssEm.toLpUnder(options);
  final bottomHeight =
      (bottomMetrics.height + bottomMetrics.depth).cssEm.toLpUnder(options);

  var middleHeight = 0.0;
  var middleFactor = 1;
  CharacterMetrics middleMetrics;
  if (conf.middle != null) {
    middleMetrics = lookupChar(conf.middle, conf.font, Mode.math);
    middleHeight =
        (middleMetrics.height + middleMetrics.depth).cssEm.toLpUnder(options);
    middleFactor = 2;
  }

  final minHeight = topHeight + bottomHeight + middleHeight;
  final repeatCount = math
      .max(0, (minDelimiterHeight - minHeight) / (repeatHeight * middleFactor))
      .ceil();

  // final realHeight = minHeight + repeatCount * middleFactor * repeatHeight;

  final axisHeight = options.fontMetrics.axisHeight.cssEm.toLpUnder(options);

  return ShiftBaseline(
    relativePos: 0.5,
    offset: axisHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        makeChar(conf.top, conf.font, topMetrics, options),
        for (var i = 0; i < repeatCount; i++)
          makeChar(conf.repeat, conf.font, repeatMetrics, options),
        if (conf.middle != null)
          makeChar(conf.middle, conf.font, middleMetrics, options),
        if (conf.middle != null)
          for (var i = 0; i < repeatCount; i++)
            makeChar(conf.repeat, conf.font, repeatMetrics, options),
        makeChar(conf.bottom, conf.font, bottomMetrics, options),
      ],
    ),
  );
}

const size4Font = FontOptions(fontFamily: 'Size4');
const size1Font = FontOptions(fontFamily: 'Size1');

class StackDelimiterConf {
  final String top;
  final String middle;
  final String repeat;
  final String bottom;
  final FontOptions font;
  const StackDelimiterConf({
    this.top,
    this.middle,
    this.repeat,
    this.bottom,
    this.font = size4Font,
  });
}

const stackDelimiterConfs = {
  '\u2191': // '\\uparrow',
      StackDelimiterConf(
          top: '\u2191', repeat: '\u23d0', bottom: '\u23d0', font: size1Font),
  '\u2193': // '\\downarrow',
      StackDelimiterConf(
          top: '\u23d0', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u2195': // '\\updownarrow',
      StackDelimiterConf(
          top: '\u2191', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u21d1': // '\\Uparrow',
      StackDelimiterConf(
          top: '\u21d1', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u21d3': // '\\Downarrow',
      StackDelimiterConf(
          top: '\u2016', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '\u21d5': // '\\Updownarrow',
      StackDelimiterConf(
          top: '\u21d1', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '|': // '\\|' ,'\\vert',
      StackDelimiterConf(
          top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2016': // '\\Vert', '\u2225'
      StackDelimiterConf(
          top: '\u2016', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u2223': // '\\lvert', '\\rvert', '\\mid'
      StackDelimiterConf(
          top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2225': // '\\lVert', '\\rVert',
      StackDelimiterConf(
          top: '\u2225', repeat: '\u2225', bottom: '\u2225', font: size1Font),
  '(': StackDelimiterConf(top: '\u239b', repeat: '\u239c', bottom: '\u239d'),
  ')': StackDelimiterConf(top: '\u239e', repeat: '\u239f', bottom: '\u23a0'),
  '[': StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a3'),
  ']': StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a6'),
  '{': StackDelimiterConf(
      top: '\u23a7', middle: '\u23a8', bottom: '\u23a9', repeat: '\u23aa'),
  '}': StackDelimiterConf(
      top: '\u23ab', middle: '\u23ac', bottom: '\u23ad', repeat: '\u23aa'),
  '\u230a': // '\\lfloor',
      StackDelimiterConf(top: '\u23a2', repeat: '\u23a2', bottom: '\u23a3'),
  '\u230b': // '\\rfloor',
      StackDelimiterConf(top: '\u23a5', repeat: '\u23a5', bottom: '\u23a6'),
  '\u2308': // '\\lceil',
      StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a2'),
  '\u2309': // '\\rceil',
      StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a5'),
  '\u27ee': // '\\lgroup',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23a9'),
  '\u27ef': // '\\rgroup',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b0': // '\\lmoustache',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b1': // '\\rmoustache',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23a9'),
};