import 'package:flexible_table/flexible_table.dart';
import 'package:flutter/material.dart';

class EmptyFlexTable extends StatefulWidget {
  const EmptyFlexTable({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State createState() => _EmptyFlexTableState();
}

class _EmptyFlexTableState extends State<EmptyFlexTable> {
  static const kColumns = 6;

  final FlexTableController _controller = FlexTableController();

  final List<String> _headers = [
    for (var i = 1; i <= kColumns; i++) 'Empty #$i'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FlexTable(
        controller: _controller,
        emptyDataBuilder: (context) => const Center(
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        headers: _headers,
      ),
    );
  }
}
