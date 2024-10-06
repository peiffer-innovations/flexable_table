import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Defines a single row of data within a [FlexTable].
@immutable
class FlexTableRow {
  /// Creates the row with the data for the [columns] of the row.  The optional
  /// [key] can be provided to give hints to the [FlexTable] for rebuilds and
  /// the default is simply a [UniqueKey] to that every row has a unique [key].
  FlexTableRow({
    required List<FlexTableCell> columns,
    Key? key,
  })  : columns = List.unmodifiable(List<Widget>.from(columns)),
        key = key ?? UniqueKey(),
        _hashCode = columns.join('|').hashCode;

  /// The columns for the row.  This will be detached from the list passed to
  /// the constructor and will always be unmodifiable.
  final List<FlexTableCell> columns;

  /// The key to use for the widget that ultimately builds the row.
  final Key key;

  final int _hashCode;

  /// Will return if any of the following are true:
  ///   * [this] is identical to [other]
  ///   * [key] equals [other.key]
  ///   * [columns] equals [other.columns]
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlexTableRow &&
          (key == other.key || listEquals(columns, other.columns)));

  /// The consistent [hashCode] for the row.
  @override
  int get hashCode => _hashCode;
}
