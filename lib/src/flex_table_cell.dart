import 'package:flexible_table/src/flex_table.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FlexTableCell extends StatelessWidget {
  const FlexTableCell({
    super.key,
    this.child,
    required this.value,
  });

  final Widget? child;
  final String value;

  @override
  Widget build(BuildContext context) {
    return child ??
        Text(
          value,
          maxLines: context.read<FlexDataCellBuilder>().maxLines,
          overflow: TextOverflow.ellipsis,
        );
  }
}
