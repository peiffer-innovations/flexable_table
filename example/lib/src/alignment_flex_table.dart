import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AlignmentFlexTable extends StatefulWidget {
  const AlignmentFlexTable({
    required this.dataAlignment,
    required this.headerAlignment,
    super.key,
    required this.title,
  });

  final Alignment dataAlignment;
  final Alignment headerAlignment;
  final bool sortable = true;
  final bool striped = true;
  final String title;

  @override
  State createState() => _AlignmentFlexTableState();
}

class _AlignmentFlexTableState extends State<AlignmentFlexTable> {
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

      for (var i = 0; i < _headers.length; i++) {
        final word = nouns[random.nextInt(nouns.length)];
        columns.add(FlexTableCell(value: word));
      }

      _controller.addRow(FlexTableRow(columns: columns));

      if (_controller.rows.length > 1000) {
        _timer.cancel();
      }
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
        dataBuilder: FlexStripeCellBuilder(
          alignment: widget.dataAlignment,
        ),
        headers: _headers,
        headerBuilder: FlexSortHeaderCellBuilder(
          alignment: widget.headerAlignment,
          controller: _sortController,
        ),
      ),
    );
  }
}
