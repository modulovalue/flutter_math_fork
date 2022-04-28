import 'package:flutter/material.dart';

import 'display.dart';
import 'supported_data.dart';

const largeSections = {
  'Delimiter Sizing',
  'Environment',
  'Unicode Mathematical Alphanumeric Symbols',
};

class FeaturePage extends StatelessWidget {
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
              maxCrossAxisExtent: largeSections.contains(entries[i].key) ? 250 : 125,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (final BuildContext context, final int j) => DisplayMath(
              expression: entries[i].value[j],
            ),
          ),
        ],
      ),
    );
  }
}
