import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../render/layout/vlist.dart';
import '../../render/svg/stretchy.dart';
import '../accents.dart';
import '../options.dart';
import '../size.dart';
import '../syntax_tree.dart';

/// AccentUnder Nodes.
///
/// Examples: `\utilde`
class AccentUnderNode extends SlotableNode<EquationRowNode> {
  /// Base where the accentUnder is applied upon.
  final EquationRowNode base;

  /// Unicode symbol of the accent character.
  final String label;

  AccentUnderNode({
    required final this.base,
    required final this.label,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
    final baseResult = childBuildResults[0]!;
    return BuildResult(
      options: options,
      italic: baseResult.italic,
      skew: baseResult.skew,
      widget: VList(
        baselineReferenceWidgetIndex: 0,
        children: <Widget>[
          VListElement(
            trailingMargin: label == '\u007e' ? 0.12.cssEm.toLpUnder(options) : 0.0,
            // Special case for \utilde
            child: baseResult.widget,
          ),
          VListElement(
            customCrossSize: (final width) => BoxConstraints(minWidth: width),
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                if (label == '\u00AF') {
                  final defaultRuleThickness =
                      options.fontMetrics.defaultRuleThickness.cssEm.toLpUnder(options);
                  return Padding(
                    padding: EdgeInsets.only(top: 3 * defaultRuleThickness),
                    child: Container(
                      width: constraints.minWidth,
                      height: defaultRuleThickness, // TODO minRuleThickness
                      color: options.color,
                    ),
                  );
                } else {
                  final accentRenderConfig = accentRenderConfigs[label];
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
  }

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [options.havingCrampedStyle()];

  @override
  List<EquationRowNode> computeChildren() => [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  AccentUnderNode updateChildren(
    final List<EquationRowNode> newChildren,
  ) =>
      copyWith(base: newChildren[0]);

  AccentUnderNode copyWith({
    final EquationRowNode? base,
    final String? label,
  }) =>
      AccentUnderNode(
        base: base ?? this.base,
        label: label ?? this.label,
      );
}
