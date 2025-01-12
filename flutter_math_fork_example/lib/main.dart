import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// ignore: implementation_imports
import 'package:flutter_math_fork/supported_data.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:provider/provider.dart';

import 'example.dart';
import 'simple_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(
    final BuildContext context,
  ) =>
      MaterialApp(
        title: 'Flutter Math Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        supportedLocales: const [
          Locale('en', 'US'),
          // Providing another supported locale ("de_DE" in this case) allows
          // switching the locale on the emulator (for example) and then seeing
          // a different decimal separator. Only locales that are declared in the
          // supportedLocales will be returned by Localizations.localeOf.
          // So if you want to prevent commas as decimal separators, you should
          // not provide supported locales that use commas as decimal separators.
          Locale('de', 'DE'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
        ],
        home: DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Flutter Math Demo',
              ),
              bottom: const TabBar(
                tabs: [
                  Text(
                    'Interactive Demo',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Equation Samples',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Supported Features',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Keyboard Simple',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Keyboard Advanced',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                DemoPage(),
                EquationsPage(),
                FeaturePage(),
                KeyboardSimpled(),
                KeyboardAdvanced(),
              ],
            ),
          ),
        ),
      );
}

class DemoPage extends StatelessWidget {
  const DemoPage();

  @override
  Widget build(
    final BuildContext context,
  ) =>
      Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: ChangeNotifierProvider(
            create: (final context) => TextEditingController(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Consumer<TextEditingController>(
                    builder: (final context, final controller, final _) => TextField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Input TeX equation here',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Flutter Math's output",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.all(10),
                            child: Consumer<TextEditingController>(
                              builder: (
                                final context,
                                final controller,
                                final _,
                              ) =>
                                  SelectableMath.tex(
                                controller.value.text,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Flutter TeX's output",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Consumer<TextEditingController>(
                              builder: (
                                final context,
                                final controller,
                                final _,
                              ) =>
                                  TeXView(
                                // Must use a GlobalKey, otherwise it will stack
                                key: GlobalKey(
                                  debugLabel: 'texView',
                                ),
                                renderingEngine: const TeXViewRenderingEngine.katex(),
                                child: TeXViewDocument(
                                  '\$\$${controller.value.text}\$\$',
                                  style: const TeXViewStyle(
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                style: const TeXViewStyle(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}

class EquationsPage extends StatelessWidget {
  static const equations = [
    ['Solution of quadratic equation', r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}'],
    [
      'Schrodinger\'s equation',
      r'i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)'
    ],
    ['Fourier transform', r'\hat f(\xi) = \int_{-\infty}^\infty {f(x)e^{- 2\pi i \xi x}\mathrm{d}x}'],
    [
      'Maxwell\'s equations',
      r'''\left\{\begin{array}{l}
  \nabla\cdot\vec{D} = \rho \\
  \nabla\cdot\vec{B} = 0 \\
  \nabla\times\vec{E} = -\frac{\partial\vec{B}}{\partial t} \\
  \nabla\times\vec{H} = \vec{J}_f + \frac{\partial\vec{D}}{\partial t} 
\end{array}\right.'''
    ],
  ];

  const EquationsPage();

  @override
  Widget build(
    final BuildContext context,
  ) =>
      Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: ListView(
            children: equations
                .map(
                  (final entry) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(entry[0]),
                            subtitle: SelectableText(
                              entry[1],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                            child: SelectableMath.tex(
                              entry[1],
                              textStyle: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
}

class FeaturePage extends StatelessWidget {
  static const largeSections = {
    'Delimiter Sizing',
    'Environment',
    'Unicode Mathematical Alphanumeric Symbols',
  };

  const FeaturePage();

  @override
  Widget build(
    final BuildContext context,
  ) {
    final entries = supportedData.entries.toList();
    return ListView.builder(
      itemCount: supportedData.length,
      itemBuilder: (final context, final i) => Column(
        children: [
          Text(
            entries[i].key,
            style: Theme.of(context).textTheme.headline3,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries[i].value.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: (){
                if (largeSections.contains(entries[i].key)) {
                  return 250.0;
                } else {
                  return 125.0;
                }
              }(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (final context, final j) {
              final entry = entries[i].value[j];
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(
                        8.0,
                      ),
                      child: Text(
                        entry,
                        softWrap: true,
                      ),
                    ),
                    const Divider(
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    Expanded(
                      child: Center(
                        child: Math.tex(
                          entry,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
