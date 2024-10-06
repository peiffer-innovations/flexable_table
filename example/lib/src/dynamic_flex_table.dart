import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DynamicFlexTable extends StatefulWidget {
  const DynamicFlexTable({
    super.key,
    this.sortable = false,
    this.striped = false,
    required this.title,
  });

  final bool sortable;
  final bool striped;
  final String title;

  @override
  State createState() => _DynamicFlexTableState();
}

class _DynamicFlexTableState extends State<DynamicFlexTable> {
  static const kColumns = 6;

  final FlexTableController _controller = FlexTableController();
  late final FlexSortController _sortController =
      FlexSortController(controller: _controller);

  final List<FlexTableCell> _headers = [
    for (var i = 1; i <= kColumns; i++) FlexTableCell(value: 'Random #$i')
  ];

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final columns = <FlexTableCell>[];
      final random = Random();

      for (var i = 0; i < kColumns; i++) {
        final word = nouns[random.nextInt(nouns.length)];
        columns.add(FlexTableCell(value: word));
      }

      _controller.addRow(FlexTableRow(columns: columns));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sortController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          StreamBuilder(
            stream: _controller.rowStream,
            builder: (context, _) => Padding(
              padding: kDebugMode
                  ? const EdgeInsets.only(right: 48.0)
                  : const EdgeInsets.only(right: 16.0),
              child: Text(
                _controller.allRows.length.toString(),
              ),
            ),
          ),
        ],
      ),
      body: FlexTable(
        controller: _controller,
        dataBuilder: widget.striped
            ? const FlexStripeCellBuilder()
            : const FlexDataCellBuilder(),
        headers: _headers,
        headerBuilder: widget.sortable
            ? FlexSortHeaderCellBuilder(
                controller: _sortController,
              )
            : const FlexHeaderCellBuilder(),
        onRowSelected: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Row Selected: $index'),
            ),
          );
        },
      ),
    );
  }
}
