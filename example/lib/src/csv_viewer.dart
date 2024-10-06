import 'dart:isolate';

import 'package:csv/csv.dart';
import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CsvViewer extends StatefulWidget {
  const CsvViewer({
    required this.asset,
    super.key,
    this.filterable = false,
    this.sortable = false,
    this.striped = false,
    required this.title,
    this.tristate = false,
  });

  final String asset;
  final bool filterable;
  final bool sortable;
  final bool striped;
  final String title;
  final bool tristate;

  @override
  State createState() => _CsvViewerState();
}

class _CsvViewerState extends State<CsvViewer> {
  final FlexTableController _controller = FlexTableController();
  late final FlexFilterController _filterController = FlexFilterController(
    controller: _controller,
  );
  late final FlexSortController _sortController = FlexSortController(
    controller: _controller,
    tristate: widget.tristate,
  );

  final List<int> _selectedRows = [];

  List<FlexTableCell>? _headers;
  List<List<String>>? _rows;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    const maxColumns = 10;
    final data = await rootBundle.loadString(widget.asset);

    final allRows = kIsWeb ? await _loadCsv(data) : await _spawnThread(data);

    _headers = allRows.first
        .take(maxColumns)
        .map((c) => FlexTableCell(value: c))
        .toList();
    _rows = allRows.skip(1).map((e) => e.take(maxColumns).toList()).toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _filterController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headers = _headers;
    final rows = _rows?.map(
      (r) => List<FlexTableCell>.from(
        [for (var c in r) FlexTableCell(value: c)],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: headers == null || rows == null
          ? const Center(child: CircularProgressIndicator())
          : FlexTable(
              controller: _controller,
              dataBuilder: widget.striped
                  ? const FlexStripeCellBuilder()
                  : const FlexDataCellBuilder(),
              headers: headers,
              headerBuilder: widget.sortable
                  ? FlexSortHeaderCellBuilder(
                      controller: _sortController,
                    )
                  : widget.filterable
                      ? FlexFilterHeaderCellBuilder(
                          controller: _filterController,
                        )
                      : const FlexHeaderCellBuilder(),
              initialData: [
                for (var r in rows) FlexTableRow(columns: r),
              ],
              onRowSelected: (index) {
                if (_selectedRows.contains(index)) {
                  _selectedRows.remove(index);
                } else {
                  _selectedRows.add(index);
                }

                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Row: $index'),
                  ),
                );
              },
              selectedRows: _selectedRows,
            ),
    );
  }
}

Future<List<List<String>>> _loadCsv(String data) async {
  final decoder = CsvCodec().decoder;

  final allRows = decoder.convert<String>(
    data,
    eol: '\n',
    shouldParseNumbers: false,
  );

  return allRows;
}

Future<List<List<String>>> _spawnThread(String data) async {
  List<List<String>> responseBody;
  final receivePort = ReceivePort();
  late Isolate isolate;
  try {
    isolate = await Isolate.spawn<_IsolateData>(
      _offMainThreadLoad,
      _IsolateData(
        data: data,
        sendPort: receivePort.sendPort,
      ),
    );

    responseBody = await receivePort.first;
  } finally {
    isolate.kill();
  }

  return responseBody;
}

Future<List<List<String>>?> _offMainThreadLoad(_IsolateData iData) async {
  final data = iData.data;
  final sendPort = iData.sendPort;
  List<List<String>>? result;
  result = await _loadCsv(data);

  sendPort.send(result);

  return result;
}

class _IsolateData {
  _IsolateData({
    required this.data,
    required this.sendPort,
  });

  final String data;
  final SendPort sendPort;
}
