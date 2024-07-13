import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flex_table/flex_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InitialFlexTableSizes extends StatefulWidget {
  const InitialFlexTableSizes({
    super.key,
    this.sortable = false,
    this.striped = false,
    required this.title,
  });

  final bool sortable;
  final bool striped;
  final String title;

  @override
  State createState() => _InitialFlexTableSizesState();
}

class _InitialFlexTableSizesState extends State<InitialFlexTableSizes> {
  final FlexTableController _controller = FlexTableController();
  late final FlexSortController _sortController =
      FlexSortController(controller: _controller);

  final List<String> _headers = [
    'Small',
    'Medium',
    'Large',
    'Has Minimum',
    'Has Maximum',
    'Sized',
  ];
  final List<FlexTableColumnSize> _sizes = [
    FlexTableColumnSize(flex: 0.5),
    FlexTableColumnSize(flex: 1.0),
    FlexTableColumnSize(flex: 2.0),
    FlexTableColumnSize(minFlex: 1.0),
    FlexTableColumnSize(maxFlex: 2.0),
    FlexTableColumnSize(size: 200.0),
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
        dataBuilder: widget.striped
            ? const FlexStripeCellBuilder()
            : const FlexDataCellBuilder(),
        headers: _headers,
        headerBuilder: widget.sortable
            ? FlexSortHeaderCellBuilder(
                controller: _sortController,
              )
            : const FlexHeaderCellBuilder(),
        initialColumnSizes: _sizes,
      ),
    );
  }
}
