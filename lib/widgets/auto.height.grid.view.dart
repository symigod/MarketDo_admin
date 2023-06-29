import 'package:flutter/material.dart';

class AutoHeightGridView extends StatelessWidget {
  final List<Widget> children;

  const AutoHeightGridView({super.key, required this.children});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        const crossAxisCount = 3;
        return GridView.count(
            crossAxisCount: crossAxisCount,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: children
                .map((child) => LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                        height: constraints.maxHeight /
                            (children.length / crossAxisCount),
                        child: child)))
                .toList());
      });
}
