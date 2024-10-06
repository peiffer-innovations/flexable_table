import 'dart:async';
import 'dart:math';

import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

/// A type definition for a function that can perform a filter.  This function
/// should return [true] when a value should be filtered (removed) from the
/// result set and [false] if the value should remain in the result set.
typedef FlexTableFilterer = bool Function(String filter, String value);

/// A type definition for a function that can perform value sorting.  The
/// returned value must be 0 if the values are considered equal, <0 if the
/// [a] value is less than the [b] value and >0 if the [a] value is greater than
/// the [b] value.
typedef FlexTableSorter = int Function(bool ascending, String a, String b);

/// Builder for building any type of cell within the [FlexTable].  In general,
/// you will want to extend either the [FlexDataCellBuilder] or
/// [FlexHeaderCellBuilder] rather than this class as those are the two classes
/// required by the [FlexTable] itself.
///
/// See also
///   * [FlexDataCellBuilder]
///   * [FlexHeaderCellBuilder]
abstract class FlexCellBuilder {
  /// Defines the [alignment] of the content within the cell, the maximum number
  /// of lines allowed for the [Text] within the cell, the background [color] of
  /// the cell and the cell's internal [padding].
  const FlexCellBuilder({
    this.alignment = Alignment.centerLeft,
    this.color,
    this.maxLines = 1,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8.0,
    ),
    this.selectedColor,
  });

  final Alignment alignment;
  final Color? color;
  final int maxLines;
  final EdgeInsetsGeometry padding;
  final Color? selectedColor;

  /// Builds the [Widget] for the cell located at [columnIndex] and [rowIndex].
  /// The passed in [child] should be wrapped by whatever widgets this builder
  /// provides.
  ///
  /// For headers, the [rowIndex] will always be -1.
  Widget build({
    required Widget child,
    required BuildContext context,
    required int columnIndex,
    required int rowIndex,
    required bool selected,
  }) {
    Widget result = Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    final color = selected ? (selectedColor ?? Colors.black12) : this.color;

    if (color != null) {
      result = Material(
        color: color,
        child: result,
      );
    }

    return result;
  }
}

/// Builder for data cells within the [FlexTable].  The default implementation
/// provides no additional functionality over the [FlexCellBuilder] and exists
/// solely so the header cells and data cells have fully distinct classes to
/// prevent accidental mix ups.
///
/// See also:
///   * [FlexStripeCellBuilder]
class FlexDataCellBuilder extends FlexCellBuilder {
  const FlexDataCellBuilder({
    super.alignment,
    super.color,
    super.maxLines,
    super.padding,
    super.selectedColor,
  });
}

/// Builds a divider between the table headers.  The divider is the draggable
/// portion that allows for resizing the columns.
class FlexDefaultHeaderDividerBuilder extends FlexHeaderDividerBuilder {
  /// Constructs the divider builder with the background [color] for the
  /// draggable area, the resting [padding] to use within the divider, and the
  /// [indicatorColor] to use for the centered indicator.
  ///
  /// The [hoverColor], [hoverIndicatorColor], and [hoverPadding] will be
  /// applied when the divider has been hovered but not pressed.
  ///
  /// The [draggingColor], [draggingIndicatorColor], and [draggingPadding] will
  /// be applied when the divider has been activated by being pressed and can
  /// be actively dragged.
  const FlexDefaultHeaderDividerBuilder({
    this.color = Colors.transparent,
    this.draggingColor = Colors.black26,
    this.draggingIndicatorColor = Colors.black,
    this.draggingPadding = const EdgeInsets.symmetric(vertical: 4.0),
    this.hoverColor = Colors.black12,
    this.hoverIndicatorColor = Colors.black87,
    this.hoverPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.indicatorColor = Colors.black54,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0),
  }) : super();

  /// The color to use as the background of the divider when it is neither
  /// hovered nor pressed.
  final Color color;

  /// The color to use as the background of the divider when it is pressed.
  final Color draggingColor;

  /// The color to use as the draggable indicator of the divider when it is
  /// pressed.
  final Color draggingIndicatorColor;

  /// The internal padding around the indicator when the divider is pressed.
  final EdgeInsets draggingPadding;

  /// The color to use as the background of the divider when it is hovered.
  final Color hoverColor;

  /// The color to use as the draggable indicator of the divider when it is
  /// hovered.
  final Color hoverIndicatorColor;

  /// The internal padding around the indicator when the divider is hovered.
  final EdgeInsets hoverPadding;

  /// The color to use as the draggable indicator of the divider when it is
  /// neither pressed nor hovered.
  final Color indicatorColor;

  /// The internal padding around the indicator when the divider is neither
  /// pressed nor hovered.
  final EdgeInsets padding;

  /// Builds the section for the draggable divider.
  ///
  /// This conforms to the divider builder signature of the [MultiSplitView]
  /// though the default implementation does not actually make use of the
  /// [axis], [index], [resizable], nor the [themeData] attributes.  Only the
  /// [dragging] and [highlighted] values are used for building the cell and
  /// indicator.
  @override
  Widget build(
    Axis axis,
    int index,
    bool resizable,
    bool dragging,
    bool highlighted,
    MultiSplitViewThemeData themeData,
  ) =>
      ColoredBox(
        color: dragging
            ? draggingColor
            : highlighted
                ? hoverColor
                : color,
        child: Center(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: dragging
                ? draggingPadding
                : highlighted
                    ? hoverPadding
                    : padding,
            child: SizedBox(
              width: 2.0,
              height: double.infinity,
              child: ColoredBox(
                color: dragging
                    ? draggingIndicatorColor
                    : highlighted
                        ? hoverIndicatorColor
                        : indicatorColor,
              ),
            ),
          ),
        ),
      );
}

/// Builds a divider between the table headers.  The divider is the draggable
/// portion that allows for resizing the columns.
///
/// This is an abstract class that only provides the interface.  The default
/// implementation is the [FlexDefaultHeaderDividerBuilder].
abstract class FlexHeaderDividerBuilder {
  const FlexHeaderDividerBuilder();

  Widget build(
    Axis axis,
    int index,
    bool resizable,
    bool dragging,
    bool highlighted,
    MultiSplitViewThemeData themeData,
  );
}

/// Builder for data cells within the [FlexTable].  The default implementation
/// provides no additional functionality over the [FlexCellBuilder] and exists
/// solely so the header cells and data cells have fully distinct classes to
/// prevent accidental mix ups.
///
/// See also:
///   * [FlexFilterHeaderCellBuilder]
///   * [FlexSortHeaderCellBuilder]
class FlexHeaderCellBuilder extends FlexCellBuilder {
  const FlexHeaderCellBuilder({
    super.alignment,
    super.color,
    super.maxLines,
    super.padding,
  });
}

/// Controller to use to be able to filter by column values.  Be sure to
/// [dispose] the filter when it is no longer required to prevent memory leaks.
class FlexFilterController<F> {
  /// Constructs the filter controller with the associated
  /// [FlexTableController].
  FlexFilterController({
    required this.controller,
  });

  /// Controller bound to the [FlexTable] to be able to apply filters to the
  /// table.
  final FlexTableController controller;
  final StreamController<void> _controller = StreamController<void>.broadcast();

  int? _filterIndex;
  String? _filterValue;

  /// The current column index where a filter is being applied.  Will be if no
  /// filter is being applied.
  int? get filterIndex => _filterIndex;

  /// The current value of the filter being applied.  Will be null if no filter
  /// is being applied.
  String? get filterValue => _filterValue;

  /// Returns the [stream] that can be listened to.  The stream will have an
  /// event applied whenever the filter is changed.
  Stream<void> get stream => _controller.stream;

  /// Disposes the controller.
  void dispose() {
    _controller.close();
  }

  /// Updates the filter and applies it to the [FlexTable].  The [index] is the
  /// index of the column to apply the filter to and the [value] is the value to
  /// use when applying the filter.  Set both to null to remove the filter and
  /// cause the table to show all the rows.
  void update(int? index, String? value) {
    _filterIndex = index;
    _filterValue = value;

    _controller.add(null);
    controller.filter(index, value);
  }
}

/// Builder for [FlexTable] headers that utilize a popover to allow for
/// filtering the contents based on a particular value.
class FlexFilterHeaderCellBuilder extends FlexHeaderCellBuilder {
  /// Constructs the builder with the [controller] to use to apply the filters.
  /// When a column is being filtered, a filter [icon] will be displayed in the
  /// header.
  const FlexFilterHeaderCellBuilder({
    super.alignment,
    super.color,
    required this.controller,
    this.icon = const Icon(
      Icons.filter_alt,
      color: Colors.black,
      size: 16.0,
    ),
    super.maxLines,
    super.padding,
  });

  /// The controller given to the [FlexTable] that this should interact with.
  final FlexFilterController controller;

  /// The icon to display in the [FlexTable] header when a filter is applied to
  /// a column.
  final Icon icon;

  @override
  Widget build({
    required Widget child,
    required BuildContext context,
    required int columnIndex,
    required int rowIndex,
    required bool selected,
  }) =>
      Material(
        color: super.color,
        child: _FlexFilterHeaderCell(
          alignment: super.alignment,
          controller: controller,
          icon: icon,
          index: columnIndex,
          child: super.build(
            context: context,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            selected: selected,
            child: child,
          ),
        ),
      );
}

/// Controller for being able to sort rows by the values in a single column.
class FlexSortController {
  /// Constructs the controller with the [FlexTableController] to be able to
  /// communicate with the [FlexTable].
  ///
  /// When [tristate] is true, the sort will switch from ascending to descending
  /// to disabled and when it is false the sort will switch from ascending to
  /// descending when the same column index is used.
  ///
  /// Be sure to [dispose] of this when it is no longer used to prevent
  /// potential memory leaks.
  FlexSortController({
    required this.controller,
    this.tristate = false,
  });

  /// The controller given to the [FlexTable] that this should interact with.
  final FlexTableController controller;

  /// Defines whether the sort is tristate.  Tristate means that it will switch
  /// from ascending to descending to disabled.  When this is false it will only
  /// switch between ascending and descending.
  final bool tristate;

  final StreamController<void> _controller = StreamController<void>.broadcast();

  bool _ascending = true;
  int? _columnIndex;

  /// Returns whether the list is sorted in ascending order (Z at the top, A at
  /// the bottom) or descending order (A at the top, Z at the bottom).
  bool get ascending => _ascending;

  /// Returns the column index to use for sorting.
  int? get columnIndex => _columnIndex;

  /// The event [stream] that can be listened to for when sort events are
  /// triggered.
  Stream<void> get stream => _controller.stream;

  /// Disposes the controller.
  void dispose() {
    _controller.close();
  }

  /// Updates the sort order for the [FlexTable].  If [index] is null, then
  /// sorting will be disabled.
  void update(int? index, bool ascending) {
    if (tristate) {
      if (index == _columnIndex && ascending == true) {
        index = null;
        ascending = true;
      }
    }

    _ascending = ascending;
    _columnIndex = index;

    _controller.add(null);

    controller.sort(index, ascending);
  }
}

/// Builder to build headers for a [FlexTable] that allow for sorting a column.
class FlexSortHeaderCellBuilder extends FlexHeaderCellBuilder {
  /// Constructs the builder with the [ascendingIcon] to use when sorting
  /// ascending and the [descendingIcon] to use when sorting descending.
  ///
  /// This also requires the [controller] to use to trigger sort events.
  const FlexSortHeaderCellBuilder({
    super.alignment,
    this.ascendingIcon = const Icon(
      Icons.arrow_downward,
      color: Colors.black,
      size: 16.0,
    ),
    super.color,
    required this.controller,
    this.descendingIcon = const Icon(
      Icons.arrow_upward,
      color: Colors.black,
      size: 16.0,
    ),
    super.maxLines,
    super.padding,
  });

  /// Icon to use when sorting in ascending order.
  final Icon ascendingIcon;

  /// The controller to use to trigger sort events.
  final FlexSortController controller;

  /// Icon to use when sorting in descending order.
  final Icon descendingIcon;

  @override
  Widget build({
    required Widget child,
    required BuildContext context,
    required int columnIndex,
    required int rowIndex,
    required bool selected,
  }) =>
      Material(
        color: super.color,
        child: _FlexSortHeaderCell(
          alignment: super.alignment,
          ascendingIcon: ascendingIcon,
          controller: controller,
          descendingIcon: descendingIcon,
          index: columnIndex,
          child: super.build(
            child: child,
            context: context,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            selected: selected,
          ),
        ),
      );
}

/// Builder to use to build data cells that alternate in color by rows.
class FlexStripeCellBuilder extends FlexDataCellBuilder {
  const FlexStripeCellBuilder({
    super.alignment,
    this.even = Colors.transparent,
    super.maxLines,
    this.odd = const Color(0x30FFEB3B),
    super.padding,
    super.selectedColor,
  });

  final Color even;
  final Color odd;

  @override
  Widget build({
    required Widget child,
    required BuildContext context,
    required int columnIndex,
    required int rowIndex,
    required bool selected,
  }) =>
      Material(
        color: rowIndex.isEven ? even : odd,
        child: super.build(
          child: child,
          context: context,
          columnIndex: columnIndex,
          rowIndex: rowIndex,
          selected: selected,
        ),
      );
}

/// Table that is higly performant regardless of the number of rows and allows
/// for fully resizable columns.
class FlexTable extends StatefulWidget {
  /// Flexible table with an effectively unlimited number of rows, resizable
  /// columns, and other configurable options.
  ///
  /// This requires the [controller] to be able communicate between the
  /// [FlexTable] and other systems.
  ///
  /// The [dataHeight] defines the fixed height to use for each data cell in the
  /// table and the [headerHeight] defines the same but for the header row.
  ///
  /// An optional [emptyDataBuilder] can be used to render the data section when
  /// there are no rows.
  ///
  /// The [dataBuilder] provides a way to customize how the data cells are built
  /// and the [headerBuilder] does the same for the cells in the header row.
  ///
  /// The [headerDividerBuilder] provides a custom way to build the draggable
  /// divider between the header cells that allow for resizing when [resizable]
  /// is not false.
  ///
  /// The [dataStyle] and [headerStyle] define the text styles for the data
  /// cells and header cells respectively.
  ///
  /// Use [initialColumnSizes] allows you to define the initial sizes for each
  /// of the columns.
  ///
  /// The [initialData] can be provided to bootstrap the [controller] with the
  /// initial set of rows.
  ///
  /// When [pushDividers] is set to true then moving one column into another
  /// allows the column being dragged to push the adjacent one as well.  When
  /// false, the column will stop once it hits an adjacent column.
  ///
  /// To prevent resizing of the columns, set [resizable] to false.
  const FlexTable({
    required this.controller,
    this.dataHeight = 40.0,
    this.dataBuilder = const FlexDataCellBuilder(),
    this.dataStyle,
    this.emptyDataBuilder,
    required this.headers,
    this.headerBuilder = const FlexHeaderCellBuilder(),
    this.headerDividerBuilder = const FlexDefaultHeaderDividerBuilder(),
    this.headerHeight = 40.0,
    this.headerStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.initialColumnSizes,
    this.initialData = const [],
    super.key,
    this.onRowSelected,
    this.pushDividers = true,
    this.resizable = true,
    this.selectedRows = const [],
  });

  /// The controller to provide two way communication between the table and
  /// other systems.
  final FlexTableController controller;

  /// Builder to build data cells.
  final FlexDataCellBuilder dataBuilder;

  /// Fixed height to use for data rows.
  final double dataHeight;

  /// Text style to use for text in data cells.
  final TextStyle? dataStyle;

  /// Optional builder to build the section for the data when there are no rows.
  final WidgetBuilder? emptyDataBuilder;

  /// List of column headers.
  final List<FlexTableCell> headers;

  /// Builder to build the header cells.
  final FlexHeaderCellBuilder headerBuilder;

  /// Builder to build the dividers between the header cells.  Will be ignored
  /// when [resizable] is false.
  final FlexHeaderDividerBuilder headerDividerBuilder;

  /// Fixed height to use for the header cells.
  final double headerHeight;

  /// Text style to use for text in the header cells.
  final TextStyle? headerStyle;

  /// Inticial sizes for the columns.
  final List<FlexTableColumnSize>? initialColumnSizes;

  /// Initial rows to populate on the [controller] and display during first
  /// build.
  final List<FlexTableRow> initialData;

  final ValueChanged<int>? onRowSelected;

  /// Defines whether one column can push across the width of another or not.
  final bool pushDividers;

  /// Defines whether the columns are resizable or not.
  final bool resizable;

  /// Indicies of the rows that are selected within the table.
  final List<int> selectedRows;

  @override
  State createState() => _FlexTableState();
}

/// Defines the initial sizes for the columns within a [FlexTable].
class FlexTableColumnSize {
  /// Defines the initial sizes for columns within a [FlexTable].
  ///
  /// The [flex] is a relative double that is effectively a ratio to use across
  /// the entire width of the table.
  ///
  /// The [maxFlex] is the maximum [flex] value that the [FlexTable] will allow
  /// on the column as columns are resized.
  ///
  /// The [minFlex] is the minimum [flex] value that the [FlexTable] will allow
  /// on the column as columns are resized.
  ///
  /// Unlike [flex], [maxFlex], and [minFlex], the [size] is not a ratio.  It is
  /// the number of points / pixels to use as the initial width of the column.
  FlexTableColumnSize({
    this.flex,
    this.maxFlex,
    this.minFlex,
    this.size,
  });

  /// A relative double that is effectively a ratio to use across the entire
  /// width of the table.
  final double? flex;

  /// The maximum [flex] value that the [FlexTable] will allow on the column as
  /// columns are resized.
  final double? maxFlex;

  /// The minimum [flex] value that the [FlexTable] will allow on the column a
  /// columns are resized.
  final double? minFlex;

  /// The number of points / pixels to use as the initial width of the column.
  final double? size;
}

/// Controller to provide programmatic control over a [FlexTable].
class FlexTableController {
  /// Controller for a [FlexTable].
  ///
  /// The optional [filterFn] function is used when filtering the data is
  /// requested.  The default implementation performs a equality test between
  /// the filter.  It will return [true] if the values do not match and [false]
  /// if they match.
  ///
  /// The optional [sortFn] function is used to perform sorting on the columns
  /// when requested.  The default implementation uses a case insensitive
  /// comparitor to perform the sorting.  When [ascending] is true, it will
  /// return based on comparing the `a` value to the `b` value and returning the
  /// result and when [ascending] is false, it will compare the `b` value to the
  /// `a` value.  For example when [ascending] is true "apple" will come before
  /// "banana".
  ///
  /// It's helpful to think of the [ascending] in terms of the logical list
  /// rather than the visual representation of the table.  So the data ascends
  /// later in the list which results in it visually getting "larger" as you go
  /// look further down the table.
  ///
  /// To prevent memory leaks, be sure to [dispose] this when it is no longer
  /// needed.
  FlexTableController({
    FlexTableFilterer? filterFn,
    FlexTableSorter? sortFn,
  })  : _filterFn =
            filterFn ?? ((String filter, String value) => filter != value),
        _sortFn = sortFn ??
            ((bool ascending, String a, String b) {
              final aValue = a.toLowerCase();
              final bValue = b.toLowerCase();

              return ascending
                  ? aValue.compareTo(bValue)
                  : bValue.compareTo(aValue);
            });

  final StreamController<List<Area>> _columnController =
      StreamController<List<Area>>.broadcast();
  final StreamController<void> _rowController =
      StreamController<void>.broadcast();

  final FlexTableFilterer _filterFn;
  final FlexTableSorter _sortFn;

  List<FlexTableRow> _allRows = [];
  List<Area> _areas = [];
  bool _ascending = false;
  int? _filterIndex;
  String? _filterValue;
  List<FlexTableRow> _rows = [];
  int? _sortIndex;

  /// Returns all the rows known by the [FlexTable].  This will ignore any
  /// current filter or sort and will maintain it's order based on the order the
  /// values were inserted.  The returned list will be unmodifiable.
  List<FlexTableRow> get allRows => List.unmodifiable(_allRows);

  /// Returns the current size values for all columns.
  List<FlexTableColumnSize> get columnSizes {
    final sizes = <FlexTableColumnSize>[];
    for (var area in _areas) {
      sizes.add(FlexTableColumnSize(
        flex: area.flex,
        maxFlex: area.max,
        minFlex: area.min,
        size: area.size,
      ));
    }

    return sizes;
  }

  /// The event [Stream] that can be listened to for column events.  Whenever a
  /// modification is performed on a column, an event will be fired.
  Stream<void> get columnStream => _columnController.stream;

  /// The event [Stream] that can be listened to for row events.  Whenever a
  /// modification is performed on any row, an event will be fired.
  Stream<void> get rowStream => _rowController.stream;

  /// Contains all the rows that match any current filter and sorted in the
  /// defined sort order.  The returned list will be unmodifiable.
  List<FlexTableRow> get rows => _rows;

  /// Disposes the controller and frees up its resources.
  void dispose() {
    _columnController.close();
    _rowController.close();
    _allRows = const [];
    _areas = const [];
    _rows = const [];
  }

  /// Adds a [row] to the bottom / end of the [FlexTable].  This will fire an
  /// event that can be listened for on the [rowStream].
  ///
  /// When adding multiple rows, it is strongly suggested to use the [addRows]
  /// function instead as this will fire an event for each row, which can
  /// trigger a lot of sorting and filter processing where as [addRows] will
  /// only trigger a single event once all the rows have been added.
  void addRow(FlexTableRow row) {
    _allRows.add(row);
    _sortAndFilter();
  }

  /// Adds one or more [rows] to the bottom / end of the [FlexTable].  This will
  /// fire a single event to the [rowStream] after all the rows have been added.
  void addRows(Iterable<FlexTableRow> rows) {
    _allRows.addAll(rows);
    _sortAndFilter();
  }

  /// Sets the current filter and applies it to the [FlexTable].  If either the
  /// [index] or [value] is set to null, this will disable the sorting.
  void filter(int? index, String? value) {
    _filterIndex = index;
    _filterValue = value;

    _sortAndFilter();
  }

  /// Inserts a single [row] to the [FlexTable] at the [index].  The [index] is
  /// based on the [allRows].
  void insertRow(int index, FlexTableRow row) {
    _allRows.insert(index, row);
    _sortAndFilter();
  }

  /// Sets the current sort and applies it to the [FlexTable].  If the [index]
  /// is null, this will disable the sorting.
  void sort(int? index, bool ascending) {
    _ascending = ascending;
    _sortIndex = index;
    _sortAndFilter();
  }

  /// Remove the [row] from the [FlexTable].  This will post an event to the
  /// [rowStream] if the row is removed.
  ///
  /// If multiple rows are being removed, use [removeRows] instead as that will
  /// only fire a single event once all rows have been removed.
  void removeRow(FlexTableRow row) {
    final removed = _allRows.remove(row);

    if (removed) {
      _sortAndFilter();
    }
  }

  /// Removes the given [rows] from the [FlexTable].
  ///
  /// This will post a single event at the end to the [rowStream] if at least
  /// one of the given [rows] was removed.
  void removeRows(Iterable<FlexTableRow> rows) {
    var removed = false;
    for (var row in rows) {
      removed = _allRows.remove(row) || removed;
    }

    if (removed) {
      _sortAndFilter();
    }
  }

  /// Removes a row at the given [index].  The index is based on the [allRows]
  /// list and not the [rows] list.  This will post an event to the [rowStream]
  /// when the row is removed;
  void removeRowAt(int index) {
    _allRows.removeAt(index);
    _sortAndFilter();
  }

  void _setColumns(List<Area> areas) {
    _areas = areas;
    _columnController.add(areas);
  }

  void _sortAndFilter() {
    final filterIndex = _filterIndex;
    final sortIndex = _sortIndex;
    final filtered = List<FlexTableRow>.from(_allRows);

    final filterValue = _filterValue;
    if (filterIndex != null && filterValue != null) {
      filtered.removeWhere(
          (row) => _filterFn(filterValue, row.columns[filterIndex].value));
    }

    if (sortIndex != null) {
      filtered.sort(
        (a, b) => _sortFn(
          _ascending,
          a.columns[sortIndex].value.toLowerCase(),
          b.columns[sortIndex].value.toLowerCase(),
        ),
      );
    }

    _rows = List.unmodifiable(filtered);
    _rowController.add(null);
  }
}

class _FlexFilterHeaderCell extends StatefulWidget {
  const _FlexFilterHeaderCell({
    required this.alignment,
    required this.child,
    required this.controller,
    required this.icon,
    required this.index,
  });

  final Alignment alignment;
  final Widget child;
  final FlexFilterController controller;
  final Icon icon;
  final int index;

  @override
  State createState() => _FlexFilterHeaderCellState();
}

class _FlexFilterHeaderCellState extends State<_FlexFilterHeaderCell> {
  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions.add(widget.controller.stream.listen((_) => setState(() {})));
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterIndex = widget.controller._filterIndex;
    final filterValue = widget.controller._filterValue;
    final indicator = filterIndex == widget.index ? widget.icon : null;

    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final monospace = TextStyle(
      fontSize:
          (theme.listTileTheme.titleTextStyle ?? theme.textTheme.bodyLarge)
                  ?.fontSize ??
              14.0,
      fontFamily: "monospace",
      fontFamilyFallback: const <String>["Courier"],
    );

    return InkWell(
      onTap: () {
        // These lists can be very large and can include hundreds or even
        // thousands of values.  The built in menu button lags horrifically at
        // lists of this size because it needs to measure every row to determine
        // the width, and measuring text is relatively expensive.
        //
        // So... we cheat!  By using a monospaced font we only need to measure
        // a single longest word to determine the max width to use for the
        // whole popup regardless of the letters involved.
        //
        // This performs equally well when there are a handful of values to when
        // there are several thousand.
        var longestWord = '';
        var maxWidth = 80.0;

        final values = <String>{
          ...widget.controller.controller._allRows.map(
            (row) {
              final value = row.columns[widget.index].value;
              if (longestWord.length < value.length) {
                longestWord = value;
              }

              return value;
            },
          )
        }.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        final span = TextSpan(
          text: longestWord,
          style: monospace,
        );
        final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        tp.layout();

        maxWidth = max(maxWidth, tp.width);

        showPopover(
          context: context,
          bodyBuilder: (context) => SizedBox(
            height: min(mq.size.height - 120.0, values.length * 40.0 + 80.0),
            width: min(maxWidth + 100.0, mq.size.width - 100.0),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    widget.controller.update(null, null);
                    Navigator.of(context).pop();
                  },
                  title: const Text('(clear)'),
                  trailing: const Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        widget.controller.update(widget.index, values[index]);
                        Navigator.of(context).pop();
                      },
                      title: Text(values[index], style: monospace),
                      trailing: values[index] == filterValue
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                    ),
                    itemCount: values.length,
                  ),
                ),
              ],
            ),
          ),
          direction: PopoverDirection.top,
        );
      },
      child: indicator == null
          ? widget.child
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.alignment.x < 0.0)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: indicator,
                  ),
                if (widget.alignment.x == 0.0) ...[
                  widget.child,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: indicator,
                  ),
                ],
                if (widget.alignment.x != 0.0)
                  Expanded(
                    child: widget.child,
                  ),
                if (widget.alignment.x > 0.0)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 4.0,
                    ),
                    child: indicator,
                  ),
              ],
            ),
    );
  }
}

class _FlexSortHeaderCell extends StatefulWidget {
  const _FlexSortHeaderCell({
    required this.alignment,
    required this.ascendingIcon,
    required this.child,
    required this.controller,
    required this.descendingIcon,
    required this.index,
  });

  final Alignment alignment;
  final Icon ascendingIcon;
  final Widget child;
  final FlexSortController controller;
  final Icon descendingIcon;
  final int index;

  @override
  State createState() => _FlexSortHeaderCellState();
}

class _FlexSortHeaderCellState extends State<_FlexSortHeaderCell> {
  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions.add(widget.controller.stream.listen(
      (_) => setState(() {}),
    ));
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortIndex = widget.controller._columnIndex;
    final ascending = widget.controller.ascending;
    final indicator = sortIndex == widget.index
        ? Builder(
            key: ValueKey(ascending ? 'ascending' : 'descending'),
            builder: (context) =>
                ascending ? widget.ascendingIcon : widget.descendingIcon,
          )
        : null;

    return InkWell(
      onTap: () {
        widget.controller.update(
          widget.index,
          sortIndex != widget.index ? true : !widget.controller._ascending,
        );
      },
      child: indicator == null
          ? widget.child
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.alignment.x < 0.0)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: indicator,
                  ),
                if (widget.alignment.x == 0.0) ...[
                  widget.child,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: indicator,
                  ),
                ],
                if (widget.alignment.x != 0.0)
                  Expanded(
                    child: widget.child,
                  ),
                if (widget.alignment.x > 0.0)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 4.0,
                    ),
                    child: indicator,
                  ),
              ],
            ),
    );
  }
}

class _FlexTableHeader extends StatefulWidget {
  const _FlexTableHeader({
    required this.builder,
    required this.columns,
    required this.controller,
    required this.dividerBuilder,
    required this.initialColumnSizes,
    required this.pushDividers,
    required this.resizable,
    required this.style,
  });

  final FlexCellBuilder builder;
  final List<FlexTableCell> columns;
  final FlexTableController controller;
  final FlexHeaderDividerBuilder dividerBuilder;
  final List<FlexTableColumnSize>? initialColumnSizes;
  final bool pushDividers;
  final bool resizable;
  final TextStyle? style;

  @override
  State createState() => _FlexTableHeaderState();
}

class _FlexTableHeaderState extends State<_FlexTableHeader> {
  final MultiSplitViewController multiSplitViewController =
      MultiSplitViewController();
  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.columns.length; i++) {
      final size = widget
          .initialColumnSizes?[min(i, widget.initialColumnSizes?.length ?? 0)];
      final column = widget.columns[i];
      multiSplitViewController.addArea(
        Area(
          builder: (context, area) => widget.builder.build(
            child: column,
            context: context,
            columnIndex: i,
            rowIndex: -1,
            selected: false,
          ),
          flex: size?.flex,
          max: size?.maxFlex,
          min: size?.minFlex,
          size: size?.size,
        ),
      );
    }
    widget.controller._setColumns(multiSplitViewController.areas);
    multiSplitViewController.addListener(multiSplitViewControllerListener);
  }

  @override
  void dispose() {
    multiSplitViewController.removeListener(multiSplitViewControllerListener);
    multiSplitViewController.dispose();
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();

    super.dispose();
  }

  void multiSplitViewControllerListener() =>
      widget.controller._setColumns(multiSplitViewController.areas);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      child: MultiSplitView(
        controller: multiSplitViewController,
        dividerBuilder: widget.resizable
            ? widget.dividerBuilder.build
            : (axis, index, resizable, dragging, highlighted, themeData) =>
                widget.builder.build(
                  child: const SizedBox(),
                  context: context,
                  columnIndex: index,
                  rowIndex: -1,
                  selected: false,
                ),
        pushDividers: widget.pushDividers,
        resizable: widget.resizable,
      ),
    );
  }
}

class _FlexTableRow extends StatefulWidget {
  _FlexTableRow({
    required this.builder,
    required this.controller,
    required this.data,
    required this.index,
    required this.selected,
    required this.style,
  }) : super(key: data.key);

  final FlexCellBuilder builder;
  final FlexTableController controller;
  final FlexTableRow data;
  final int index;
  final bool selected;
  final TextStyle? style;

  @override
  State createState() => _FlexTableRowState();
}

class _FlexTableRowState extends State<_FlexTableRow> {
  final MultiSplitViewController controller = MultiSplitViewController();
  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.data.columns.length; i++) {
      final headerArea = widget.controller._areas[i];
      controller.addArea(buildArea(headerArea, i));
    }
    final columns = widget.data.columns;
    subscriptions.add(
      widget.controller._columnController.stream.listen((areas) {
        final newAreas = <Area>[];
        final style = widget.style;
        for (var i = 0; i < columns.length; i++) {
          final area = areas[i];
          final id = controller.getArea(i).id;
          newAreas.add(Area(
            builder: (context, area) => widget.builder.build(
              child: style == null
                  ? columns[i]
                  : DefaultTextStyle(
                      style: style,
                      child: columns[i],
                    ),
              context: context,
              columnIndex: i,
              rowIndex: widget.index,
              selected: widget.selected,
            ),
            flex: area.flex,
            id: id,
            max: area.max,
            min: area.min,
            size: area.size,
          ));
        }
        controller.areas = newAreas;
      }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();

    super.dispose();
  }

  Area buildArea(Area header, int index) {
    final style = widget.style;
    return Area(
      builder: (context, area) => widget.builder.build(
        context: context,
        columnIndex: index,
        rowIndex: widget.index,
        selected: widget.selected,
        child: style == null
            ? widget.data.columns[index]
            : DefaultTextStyle(style: style, child: widget.data.columns[index]),
      ),
      flex: header.flex,
      max: header.max,
      min: header.min,
      size: header.size,
    );
  }

  @override
  Widget build(BuildContext context) => MultiSplitView(
        controller: controller,
        dividerBuilder:
            (axis, index, resizable, dragging, highlighted, themeData) =>
                widget.builder.build(
          child: const SizedBox(),
          context: context,
          columnIndex: index,
          rowIndex: widget.index,
          selected: widget.selected,
        ),
        resizable: false,
      );
}

class _FlexTableState extends State<FlexTable> {
  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();

    widget.controller.addRows(widget.initialData);
  }

  @override
  void dispose() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emptyDataBuilder =
        widget.controller._rows.isNotEmpty ? null : widget.emptyDataBuilder;
    final onRowSelected = widget.onRowSelected;
    return MultiProvider(
      providers: [
        Provider.value(value: widget.controller),
        Provider.value(value: widget.dataBuilder),
        Provider.value(value: widget.headerBuilder),
        Provider.value(value: widget.headerDividerBuilder),
      ],
      child: Column(
        children: [
          SizedBox(
            height: widget.headerHeight,
            child: _FlexTableHeader(
              builder: widget.headerBuilder,
              columns: widget.headers,
              controller: widget.controller,
              dividerBuilder: widget.headerDividerBuilder,
              initialColumnSizes: widget.initialColumnSizes,
              pushDividers: widget.pushDividers,
              resizable: widget.resizable,
              style: widget.headerStyle,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: widget.controller._rowController.stream,
              builder: (context, snapshot) => emptyDataBuilder != null
                  ? emptyDataBuilder(context)
                  : ListView.builder(
                      itemBuilder: (context, index) => SizedBox(
                        height: widget.dataHeight,
                        child: Material(
                          child: InkWell(
                            onTap: onRowSelected == null
                                ? null
                                : () => onRowSelected(index),
                            child: _FlexTableRow(
                              builder: widget.dataBuilder,
                              controller: widget.controller,
                              data: widget.controller._rows[index],
                              index: index,
                              selected: widget.selectedRows.contains(index),
                              style: widget.dataStyle,
                            ),
                          ),
                        ),
                      ),
                      itemCount: widget.controller._rows.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
