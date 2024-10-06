import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotResizableFlexTable extends StatefulWidget {
  const NotResizableFlexTable({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State createState() => _NotResizableFlexTableState();
}

class _NotResizableFlexTableState extends State<NotResizableFlexTable> {
  static const kColumns = 6;

  final FlexTableController _controller = FlexTableController();

  final List<FlexTableCell> _headers = [
    for (var i = 1; i <= kColumns; i++) FlexTableCell(value: 'Random #$i'),
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
        dataBuilder: const FlexStripeCellBuilder(),
        headers: _headers,
        headerBuilder: const FlexHeaderCellBuilder(),
        resizable: false,
      ),
    );
  }
}
