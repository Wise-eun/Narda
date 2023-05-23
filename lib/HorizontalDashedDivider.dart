import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class HorizontalDashedDivider extends StatelessWidget {
  const HorizontalDashedDivider({Key? key,
    this.space,
    this.length,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent})
      : assert(space == null || space >= 0.0),
        assert(length == null || length >= 0.0),
        assert(thickness == null || thickness >= 0.0),
        assert(indent == null || indent >= 0.0),
        assert(endIndent == null || endIndent >= 0.0),
        super(key: key);

  final double? space;
  final double? length;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    // Part1
    final DividerThemeData dividerTheme = DividerTheme.of(context);
    final double space = this.space ?? dividerTheme.space ?? 10.0;
    final double length = this.length ?? 6.0;
    final double thickness = this.thickness ?? dividerTheme.thickness ?? 2.0;
    final Color color =
        this.color ?? dividerTheme.color ?? Theme
            .of(context)
            .dividerColor;
    final double indent = this.indent ?? dividerTheme.indent ?? 0.0;
    final double endIndent = this.endIndent ?? dividerTheme.endIndent ?? 0.0;

    // Part2
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(
        height: space,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final boxWidth = constraints.constrainWidth();
            final dashLength = length;
            final dashThickness = thickness;
            final dashCount = (boxWidth / (2 * dashLength)).floor();
            return Flex(
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashLength,
                  height: dashThickness,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color),
                  ),
                );
              }),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
            );
          },
        ),
      ),
    );
  }
}