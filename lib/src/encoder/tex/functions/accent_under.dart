part of '../functions.dart';

EncodeResult _accentUnderEncoder(
  final GreenNode node,
) {
  final accentNode = node as AccentUnderNode;
  final label = accentNode.label;
  final command = accentUnderMapping.entries.firstWhereOrNull((final entry) => entry.value == label)?.key;
  if (command == null) {
    return NonStrictEncodeResult(
      'unknown accent_under',
      'No strict match for accent_under symbol under math mode: '
          '${unicodeLiteral(accentNode.label)}',
    );
  } else {
    return TexCommandEncodeResult(
      command: command,
      args: accentNode.children,
    );
  }
}
