/// Utilities for Tex encoding and parsing.
library tex;

export 'src/ast/ast.dart' show SyntaxTree, SyntaxNode, GreenNode, EquationRowNode;
export 'src/encoder/tex_encoder.dart' show TexEncoder, TexEncoderExt, ListTexEncoderExt;
export 'src/parser/colors.dart';
export 'src/parser/macros.dart' show MacroDefinition, defineMacro, MacroExpansion;
export 'src/parser/parser.dart' show TexParser;
export 'src/parser/settings.dart';
