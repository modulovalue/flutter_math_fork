part of '../functions.dart';

EncodeResult _stretchyOpEncoder(
  final GreenNode node,
) {
  final arrowNode = node as StretchyOpNode;
  final command = arrowCommandMapping.entries
      .firstWhereOrNull(
        (final entry) => entry.value == arrowNode.symbol,
      )
      ?.key;
  if (command == null) {
    return NonStrictEncodeResult(
      'unknown strechy_op',
      'No strict match for stretchy_op symbol under math mode: '
          '${unicodeLiteral(arrowNode.symbol)}',
    );
  } else {
    return TexCommandEncodeResult(
      command: command,
      args: <dynamic>[
        arrowNode.above,
        arrowNode.below,
      ],
    );
  }
}
