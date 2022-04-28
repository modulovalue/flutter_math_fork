import 'dart:convert';

import '../ast/ast.dart';
import '../ast/ast_impl.dart';
import '../ast/ast_plus.dart';
import '../parser/font.dart';
import '../parser/functions.dart';
import '../parser/parser.dart';
import '../utils/alpha_numeric.dart';
import '../utils/extensions.dart';
import 'encoder.dart';
import 'matcher.dart';
import 'optimization.dart';
import 'tex_functions.dart';

final texEncodingCache = Expando<EncodeResult>(
  'Tex encoding results',
);

/// Encodes [TexGreen] into TeX
class TexEncoder extends Converter<TexGreen, String> {
  @override
  String convert(
    final TexGreen input,
  ) =>
      nodeEncodeTeX(
        node: input,
      );
}

/// Encodes the node into TeX
String nodeEncodeTeX({
  required final TexGreen node,
  final TexEncodeConf conf = const TexEncodeConf(),
}) =>
    encodeTex(node).stringify(conf);

/// Encode the list of nodes into TeX
String listEncodeTex(
  final List<TexGreen> nodes,
) =>
    nodeEncodeTeX(
      node: greenNodesWrapWithEquationRow(
        nodes,
      ),
      conf: const TexEncodeConf().mathParam(),
    );

EncodeResult encodeTex(
  final TexGreen node,
) {
  final cachedRes = texEncodingCache[node];
  if (cachedRes != null) {
    return cachedRes;
  } else {
    final res = node.match(
      nonleaf: (final a) {
        a.matchNonleaf(
          nullable: (final a) => a.matchNonleafNullable(
            matrix: (final a) {},
            multiscripts: (final a) {},
            naryoperator: (final a) {},
            sqrt: (final a) {},
            stretchyop: (final a) {},
          ),
          nonnullable: (final a) => a.matchNonleafNonnullable(
            equationarray: (final a) {},
            over: (final a) {},
            under: (final a) {},
            accent: (final a) {},
            accentunder: (final a) {},
            enclosure: (final a) {},
            frac: (final a) {},
            raisebox: (final a) {},
            equationrow: (final a) {},
            function: OptimizationEntryCollection<TexGreenFunction>(
              entries: [
                OptimizationEntry<TexGreenFunction>(
                  matcher: NodeMatcher<TexGreenFunction>(
                    firstChild: NodeMatcher<TexGreenEquationrow>(
                      child: NodeMatcher<TexGreenStyle>(
                        matchSelf: (final node) =>
                            node.optionsDiff.mathFontOptions == texMathFontOptions['\\mathrm'],
                      ),
                    ),
                  ),
                  optimize: (final node) {
                    final functionNode = node;
                    texEncodingCache[node] = TransparentTexEncodeResult(
                      <dynamic>[
                        TexCommandEncodeResult(
                          command: '\\operatorname',
                          args: <dynamic>[
                            () {
                              final f = functionNode.functionName.children.first as TexGreenStyle;
                              return optionsDiffEncode(
                                f.optionsDiff.removeMathFont(),
                                f.children,
                              );
                            }(),
                          ],
                        ),
                        functionNode.argument,
                      ],
                    );
                  },
                ),
                // Optimization for plain invocations like \sin \lim
                OptimizationEntry<TexGreenFunction>(
                  matcher: const NodeMatcher<TexGreenFunction>(
                    firstChild: NodeMatcher<TexGreenEquationrow>(
                      everyChild: NodeMatcher<TexGreenSymbol>(),
                    ),
                  ),
                  optimize: (final node) {
                    final functionNode = node;
                    final name = '\\' +
                        functionNode.functionName.children
                            .map((final child) => (child as TexGreenSymbol).symbol)
                            .join();
                    if (mathFunctions.contains(name) || mathLimits.contains(name)) {
                      texEncodingCache[node] = TexCommandEncodeResult(
                        numArgs: 1,
                        command: name,
                        args: <dynamic>[functionNode.argument],
                      );
                    }
                  },
                ),
                // Optimization for non-limits-like functions with scripts
                OptimizationEntry<TexGreenFunction>(
                  matcher: NodeMatcher<TexGreenFunction>(
                    firstChild: NodeMatcher<TexGreenEquationrow>(
                      child: NodeMatcher<TexGreenMultiscripts>(
                        matchSelf: (final node) =>
                            node.presub == null &&
                            node.presup == null &&
                            const NodeMatcher<TexGreenEquationrow>(
                              everyChild: NodeMatcher<TexGreenSymbol>(),
                            ).match(node.base),
                        selfSpecificity: 500,
                      ),
                    ),
                  ),
                  optimize: (final node) {
                    final functionNode = node;
                    final scriptsNode = functionNode.functionName.children.first as TexGreenMultiscripts;
                    final name = '\\' +
                        scriptsNode.base.children
                            .map((final child) => (child as TexGreenSymbol).symbol)
                            .join();
                    final isFunction = mathFunctions.contains(name);
                    final isLimit = mathLimits.contains(name);
                    if (isFunction || isLimit) {
                      texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
                        TexMultiscriptEncodeResult(
                          base: name +
                              (() {
                                if (isLimit) {
                                  return '\\nolimits';
                                } else {
                                  return '';
                                }
                              }()),
                          sub: scriptsNode.sub,
                          sup: scriptsNode.sup,
                        ),
                        functionNode.argument,
                      ]);
                    }
                  },
                ),
                // Optimization for limits-like functions with scripts
                OptimizationEntry<TexGreenFunction>(
                  matcher: const NodeMatcher<TexGreenFunction>(
                    firstChild: NodeMatcher<TexGreenEquationrow>(
                      child: OrMatcher(
                        NodeMatcher<TexGreenOver>(
                          firstChild: OrMatcher(
                            NodeMatcher<TexGreenEquationrow>(
                              everyChild: NodeMatcher<TexGreenSymbol>(),
                            ),
                            NodeMatcher<TexGreenEquationrow>(
                              child: NodeMatcher<TexGreenUnder>(
                                firstChild: NodeMatcher<TexGreenEquationrow>(
                                  everyChild: NodeMatcher<TexGreenSymbol>(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        NodeMatcher<TexGreenUnder>(
                          firstChild: OrMatcher(
                            NodeMatcher<TexGreenEquationrow>(
                              everyChild: NodeMatcher<TexGreenSymbol>(),
                            ),
                            NodeMatcher<TexGreenEquationrow>(
                              child: NodeMatcher<TexGreenOver>(
                                firstChild: NodeMatcher<TexGreenEquationrow>(
                                  everyChild: NodeMatcher<TexGreenSymbol>(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  optimize: (final node) {
                    final functionNode = node;
                    TexGreen nameNode = functionNode.functionName.children.first;
                    TexGreen? sub;
                    TexGreen? sup;
                    final outer = nameNode;
                    if (outer is TexGreenOver) {
                      sup = outer.above;
                      nameNode = outer.base;
                      // If we detect an UnderNode in the children, combined with the design
                      // of the matcher, we can know that there must be a inner under/over.
                      final inner = nameNode.childrenl.firstOrNull;
                      if (inner is TexGreenUnder) {
                        sub = inner.below;
                        nameNode = inner.base;
                      }
                    } else if (outer is TexGreenUnder) {
                      sub = outer.below;
                      nameNode = outer.base;
                      final inner = nameNode.childrenl.firstOrNull;
                      if (inner is TexGreenOver) {
                        sup = inner.above;
                        nameNode = inner.base;
                      }
                    }
                    final name =
                        '\\${nameNode.childrenl.map((final child) => (child as TexGreenSymbol?)!.symbol).join()}';
                    final isFunction = mathFunctions.contains(name);
                    final isLimit = mathLimits.contains(name);
                    if (isFunction || isLimit) {
                      texEncodingCache[node] = TransparentTexEncodeResult(
                        <dynamic>[
                          TexMultiscriptEncodeResult(
                            base: name +
                                (() {
                                  if (isFunction) {
                                    return '\\limits';
                                  } else {
                                    return '';
                                  }
                                }()),
                            sub: sub,
                            sup: sup,
                          ),
                          functionNode.argument,
                        ],
                      );
                    }
                  },
                ),
              ],
            ).apply,
            leftright: OptimizationEntryCollection<TexGreenLeftright>(
              entries: [
                OptimizationEntry<TexGreenLeftright>(
                  matcher: NodeMatcher<TexGreenLeftright>(
                    matchSelf: (final node) => node.leftDelim == '(' && node.rightDelim == ')',
                    child: NodeMatcher<TexGreenEquationrow>(
                      child: NodeMatcher<TexGreenFrac>(
                        matchSelf: (final node) => node.continued == false && node.barSize?.value == 0,
                      ),
                    ),
                  ),
                  optimize: (final node) {
                    texEncodingCache[node] = TexCommandEncodeResult(
                      command: '\\binom',
                      args: node.childrenl.first!.childrenl.first!.childrenl,
                    );
                  },
                ),
              ],
            ).apply,
            style: OptimizationEntryCollection<TexGreenStyle>(
              entries: [
                OptimizationEntry<TexGreenStyle>(
                  matcher: NodeMatcher<TexGreenStyle>(
                    matchSelf: (final node) => node.optionsDiff.style != null,
                    child: NodeMatcher<TexGreenLeftright>(
                      child: NodeMatcher<TexGreenEquationrow>(
                        child: NodeMatcher<TexGreenFrac>(
                          matchSelf: (final node) => node.continued == false,
                        ),
                      ),
                    ),
                  ),
                  optimize: (final node) {
                    final leftRight = (node.children.first as TexGreenLeftright?)!;
                    final frac = leftRight.children.first.children.first as TexGreenFrac;
                    final res = TexCommandEncodeResult(
                      command: '\\genfrac',
                      args: <dynamic>[
                        // TODO
                        () {
                          if (leftRight.leftDelim == null) {
                            return null;
                          } else {
                            return TexGreenSymbolImpl(
                              symbol: leftRight.leftDelim!,
                            );
                          }
                        }(),
                        () {
                          if (leftRight.rightDelim == null) {
                            return null;
                          } else {
                            return TexGreenSymbolImpl(
                              symbol: leftRight.rightDelim!,
                            );
                          }
                        }(),
                        frac.barSize,
                        () {
                          final style = node.optionsDiff.style;
                          if (style == null) {
                            return null;
                          } else {
                            return mathStyleSize(style);
                          }
                        }(),
                        ...frac.children,
                      ],
                    );
                    final remainingOptions = node.optionsDiff.removeStyle();
                    texEncodingCache[node] = () {
                      if (remainingOptions.isEmpty) {
                        return res;
                      } else {
                        return optionsDiffEncode(remainingOptions, <dynamic>[res]);
                      }
                    }();
                  },
                ),
                OptimizationEntry<TexGreenStyle>(
                  matcher: NodeMatcher<TexGreenStyle>(
                    matchSelf: (final node) => node.optionsDiff.style != null,
                    child: NodeMatcher<TexGreenFrac>(
                      matchSelf: (final node) => node.continued == false,
                    ),
                  ),
                  optimize: (final node) {
                    final frac = (node.childrenl.first as TexGreenFrac?)!;
                    final res = TexCommandEncodeResult(
                      command: '\\genfrac',
                      args: <dynamic>[
                        null,
                        null,
                        frac.barSize,
                        () {
                          final style = node.optionsDiff.style;
                          if (style == null) {
                            return null;
                          } else {
                            return mathStyleSize(style);
                          }
                        }(),
                        ...frac.children,
                      ],
                    );
                    final remainingOptions = node.optionsDiff.removeStyle();
                    texEncodingCache[node] = () {
                      if (remainingOptions.isEmpty) {
                        return res;
                      } else {
                        return optionsDiffEncode(remainingOptions, <dynamic>[res]);
                      }
                    }();
                  },
                ),
                OptimizationEntry<TexGreenStyle>(
                  matcher: NodeMatcher<TexGreenStyle>(
                    matchSelf: (final node) {
                      final style = node.optionsDiff.style;
                      return style == TexMathStyle.display || style == TexMathStyle.text;
                    },
                    child: NodeMatcher<TexGreenFrac>(
                      matchSelf: (final node) => node.barSize == null,
                      selfSpecificity: 110,
                    ),
                  ),
                  optimize: (final node) {
                    final style = node.optionsDiff.style;
                    final continued = (node.children.first as TexGreenFrac).continued;
                    if (style == TexMathStyle.text && continued) {
                      return;
                    }
                    final res = TexCommandEncodeResult(
                      command: () {
                        if (style == TexMathStyle.display) {
                          if (continued) {
                            return '\\cfrac';
                          } else {
                            return '\\dfrac';
                          }
                        } else {
                          return '\\tfrac';
                        }
                      }(),
                      args: node.children.first.childrenl,
                    );
                    final remainingOptions = node.optionsDiff.removeStyle();
                    texEncodingCache[node] = () {
                      if (remainingOptions.isEmpty) {
                        return res;
                      } else {
                        return optionsDiffEncode(remainingOptions, <dynamic>[res]);
                      }
                    }();
                  },
                )
              ],
            ).apply,
          ),
        );
        final cachedRes = texEncodingCache[node];
        if (cachedRes != null) {
          return cachedRes;
        } else {
          return null;
        }
      },
      leaf: (final a) => null,
    );
    if (res != null) {
      return res;
    } else {
      final encodeResult = encoderFunctions(node);
      texEncodingCache[node] = encodeResult;
      return encodeResult;
    }
  }
}

class TexEncodeConf extends EncodeConf {
  final TexMode mode;
  final bool removeRowBracket;

  const TexEncodeConf({
    final this.mode = TexMode.math,
    final this.removeRowBracket = false,
    final Strict strict = Strict.warn,
    final StrictFun? strictFun,
  }) : super(
          strict: strict,
          strictFun: strictFun,
        );

  static const mathConf = TexEncodeConf();
  static const mathParamConf = TexEncodeConf(removeRowBracket: true);
  static const textConf = TexEncodeConf(mode: TexMode.text);
  static const textParamConf = TexEncodeConf(mode: TexMode.text, removeRowBracket: true);

  TexEncodeConf math() {
    if (mode == TexMode.math && !removeRowBracket) return this;
    return copyWith(mode: TexMode.math, removeRowBracket: false);
  }

  TexEncodeConf mathParam() {
    if (mode == TexMode.math && removeRowBracket) return this;
    return copyWith(mode: TexMode.math, removeRowBracket: true);
  }

  TexEncodeConf text() {
    if (mode == TexMode.text && !removeRowBracket) return this;
    return copyWith(mode: TexMode.text, removeRowBracket: false);
  }

  TexEncodeConf textParam() {
    if (mode == TexMode.text && removeRowBracket) return this;
    return copyWith(mode: TexMode.text, removeRowBracket: true);
  }

  TexEncodeConf param() {
    if (removeRowBracket) return this;
    return copyWith(removeRowBracket: true);
  }

  TexEncodeConf ord() {
    if (!removeRowBracket) return this;
    return copyWith(removeRowBracket: false);
  }

  TexEncodeConf copyWith({
    final TexMode? mode,
    final bool? removeRowBracket,
    final Strict? strict,
    final StrictFun? strictFun,
  }) =>
      TexEncodeConf(
        mode: mode ?? this.mode,
        removeRowBracket: removeRowBracket ?? this.removeRowBracket,
        strict: strict ?? this.strict,
        strictFun: strictFun ?? this.strictFun,
      );
}

String _handleArg(final dynamic arg, final EncodeConf conf) {
  if (arg == null) return '';
  if (arg is EncodeResult) {
    return arg.stringify(conf);
  }
  if (arg is TexGreen) {
    return encodeTex(arg).stringify(conf);
  }
  if (arg is String) return arg;
  return arg.toString();
}

String _handleAndWrapArg(
  final dynamic arg,
  final EncodeConf conf,
) {
  final string = _handleArg(arg, conf);
  if (string.length == 1 || _isSingleSymbol(arg)) {
    return string;
  } else {
    return '{$string}';
  }
}

bool _isSingleSymbol(dynamic arg) {
  for (;;) {
    if (arg is TransparentTexEncodeResult && arg.children.length == 1) {
      // ignore: parameter_assignments
      arg = arg.children.first;
    } else if (arg is EquationRowTexEncodeResult && arg.children.length == 1) {
      // ignore: parameter_assignments
      arg = arg.children.first;
    } else if (arg is TexGreenEquationrow && arg.children.length == 1) {
      // ignore: parameter_assignments
      arg = arg.children.first;
    } else {
      break;
    }
  }
  if (arg is String) return true;
  if (arg is StaticEncodeResult) return true;
  return false;
}

class TexCommandEncodeResult implements EncodeResult<TexEncodeConf> {
  final String command;

  /// Accepted type: [Null], [String], [EncodeResult], [TexGreen]
  final List<dynamic> args;

  late final FunctionSpec spec = functions[command]!;

  final int? _numArgs;
  late final int numArgs = _numArgs ?? spec.numArgs;

  final int? _numOptionalArgs;
  late final int numOptionalArgs = _numOptionalArgs ?? spec.numOptionalArgs;

  late final List<TexMode?> argModes =
      spec.argModes ?? List.filled(numArgs + numOptionalArgs, null, growable: false);

  TexCommandEncodeResult({
    required final this.command,
    required final this.args,
    final int? numArgs,
    final int? numOptionalArgs,
  })  : _numArgs = numArgs,
        _numOptionalArgs = numOptionalArgs;

  @override
  String stringify(final TexEncodeConf conf) {
    assert(this.numArgs >= this.numOptionalArgs, "");
    if (!spec.allowedInMath && conf.mode == TexMode.math) {
      conf.reportNonstrict(
          'command mode mismatch', 'Text-only command $command occured in math encoding enviroment');
    }
    if (!spec.allowedInText && conf.mode == TexMode.text) {
      conf.reportNonstrict(
          'command mode mismatch', 'Math-only command $command occured in text encoding environment');
    }
    final argString = Iterable.generate(
      numArgs + numOptionalArgs,
      (final index) {
        final mode = argModes[index] ?? conf.mode;
        final string = _handleArg(
          args[index],
          () {
            if (mode == TexMode.math) {
              return conf.mathParam();
            } else {
              return conf.textParam();
            }
          }(),
        );
        if (index < numOptionalArgs) {
          if (string.isEmpty) {
            return '';
          } else {
            return '[$string]';
          }
        } else {
          return '{$string}'; // TODO optimize
        }
      },
    ).join();

    if (argString.isNotEmpty && (argString[0] == '[' || argString[0] == '{')) {
      return '$command$argString';
    } else {
      return '$command $argString';
    }
  }
}

String listTexJoin(
  final Iterable<String> list,
) {
  final iterator = list.iterator..moveNext();
  final length = list.length;
  return Iterable.generate(
    length,
    (final index) {
      if (index == length - 1) return iterator.current;
      final current = iterator.current;
      final next = (iterator..moveNext()).current;
      if (current.length == 1 ||
          (next.isNotEmpty && !isAlphaNumericUnit(next[0]) && next[0] != '*') ||
          (current.isNotEmpty && current[current.length - 1] == '\}')) {
        return current;
      }
      return '$current ';
    },
  ).join();
}

class EquationRowTexEncodeResult implements EncodeResult<TexEncodeConf> {
  final List<dynamic> children;

  const EquationRowTexEncodeResult(
    final this.children,
  );

  @override
  String stringify(
    final TexEncodeConf conf,
  ) {
    final content = listTexJoin(
      Iterable.generate(
        children.length,
        (final index) {
          final dynamic child = children[index];
          if (index == children.length - 1 && child is TexModeCommandEncodeResult) {
            return _handleArg(child, conf.param());
          }
          return _handleArg(child, conf.ord());
        },
      ),
    );
    if (conf.removeRowBracket == true) {
      return content;
    } else {
      return '{' + content + '}';
    }
  }
}

class TransparentTexEncodeResult implements EncodeResult<TexEncodeConf> {
  final List<dynamic> children;

  const TransparentTexEncodeResult(
    final this.children,
  );

  @override
  String stringify(
    final TexEncodeConf conf,
  ) =>
      listTexJoin(
        children.map(
          (final dynamic child) => _handleArg(
            child,
            conf.ord(),
          ),
        ),
      );
}

class ModeDependentEncodeResult implements EncodeResult<TexEncodeConf> {
  final dynamic text;
  final dynamic math;

  const ModeDependentEncodeResult({
    final this.text,
    final this.math,
  });

  @override
  String stringify(
    final TexEncodeConf conf,
  ) =>
      _handleArg(
        () {
          if (conf.mode == TexMode.math) {
            return math;
          } else {
            return text;
          }
        }(),
        conf,
      );

  static String _handleArg(
    final dynamic arg,
    final TexEncodeConf conf,
  ) {
    if (arg == null) {
      return '';
    } else if (arg is TexGreen) {
      return nodeEncodeTeX(
        node: arg,
        conf: conf,
      );
    } else if (arg is EncodeResult) {
      return arg.stringify(conf);
    } else {
      return arg.toString();
    }
  }
}

class TexModeCommandEncodeResult implements EncodeResult<TexEncodeConf> {
  final String command;
  final List<dynamic> children;

  const TexModeCommandEncodeResult({
    required final this.command,
    required final this.children,
  });

  @override
  String stringify(
    final TexEncodeConf conf,
  ) {
    final content = listTexJoin(
      Iterable.generate(
        children.length,
        (final index) {
          final dynamic child = children[index];
          if (index == children.length - 1 && child is TexModeCommandEncodeResult) {
            return _handleArg(child, conf.param());
          } else {
            return _handleArg(child, conf.ord());
          }
        },
      ),
    );
    if (conf.removeRowBracket == true) {
      return command + ' ' + content;
    } else {
      return '{' + command + ' ' + content + '}';
    }
  }
}

class TexMultiscriptEncodeResult implements EncodeResult<TexEncodeConf> {
  final dynamic base;
  final dynamic sub;
  final dynamic sup;
  final dynamic presub;
  final dynamic presup;

  const TexMultiscriptEncodeResult({
    required final this.base,
    final this.sub,
    final this.sup,
    final this.presub,
    final this.presup,
  });

  @override
  String stringify(
    final TexEncodeConf conf,
  ) {
    if (conf.mode != TexMode.math) {
      conf.reportNonstrict('command mode mismatch', 'Sub/sup scripts occured in text encoding environment');
    }
    if (presub != null || presup != null) {
      conf.reportNonstrict(
        'imprecise encoding',
        'Prescripts are not supported in vanilla KaTeX',
      );
    }
    return listTexJoin(
      [
        if (presub != null || presup != null) '{}',
        if (presub != null) ...[
          '_',
          _handleAndWrapArg(presub, conf.param()),
        ],
        if (presup != null) ...[
          '^',
          _handleAndWrapArg(presup, conf.param()),
        ],
        _handleAndWrapArg(base, conf.param()),
        if (sub != null) ...[
          '_',
          _handleAndWrapArg(sub, conf.param()),
        ],
        if (sup != null) ...[
          '^',
          _handleAndWrapArg(sup, conf.param()),
        ],
      ],
    );
  }
}
