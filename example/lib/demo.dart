import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:provider/provider.dart';

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
