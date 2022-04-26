// The MIT License (MIT)
//
// Copyright (c) 2013-2019 Khan Academy and other contributors
// Copyright (c) 2020 znjameswu <znjameswu@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import '../ast/ast.dart';
import '../ast/types.dart';
import 'environment_array.dart';
import 'environment_eqn_array.dart';
import 'parser.dart';

class EnvContext {
  final Mode mode;
  final String envName;

  const EnvContext({
    required final this.mode,
    required final this.envName,
  });
}

class EnvSpec {
  final int numArgs;
  final int greediness;
  final bool allowedInText;
  final int numOptionalArgs;
  final GreenNode Function(TexParser parser, EnvContext context) handler;
  const EnvSpec({
    required final this.numArgs,
    required final this.handler,
    final this.greediness = 1,
    final this.allowedInText = false,
    final this.numOptionalArgs = 0,
  });
}

final Map<String, EnvSpec> _environments = {};
Map<String, EnvSpec> get environments {
  if (_environments.isEmpty) {
    _environmentsEntries.forEach((final key, final value) {
      for (final name in key) {
        _environments[name] = value;
      }
    });
  }
  return _environments;
}

final _environmentsEntries = {
  ...arrayEntries,
  ...eqnArrayEntries,
};
