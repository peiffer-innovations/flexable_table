import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flex_table/flex_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilteredFlexTable extends StatefulWidget {
  const FilteredFlexTable({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State createState() => _FilteredFlexTableState();
}

class _FilteredFlexTableState extends State<FilteredFlexTable> {
  static const kColumns = 6;
  final FlexTableController _controller = FlexTableController();
  late final FlexFilterController _filterController =
      FlexFilterController(controller: _controller);

  final List<String> _headers = [
    for (var i = 1; i <= kColumns; i++) 'Random #$i'
  ];

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final columns = <String>[];
      final random = Random();

      for (var i = 0; i < _headers.length; i++) {
        final word = nouns[random.nextInt(nouns.length)];
        columns.add(word);
      }

      _controller.addRow(FlexTableRow(columns: columns));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _filterController.dispose();
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
                '${_controller.rows.length} (${_controller.allRows.length})',
              ),
            ),
          ),
        ],
      ),
      body: FlexTable(
        controller: _controller,
        dataBuilder: const FlexStripeCellBuilder(),
        headers: _headers,
        headerBuilder: FlexFilterHeaderCellBuilder(
          controller: _filterController,
        ),
      ),
    );
  }
}
