import 'package:flutter/material.dart';
import 'package:table_example/src/alignment_flex_table.dart';
import 'package:table_example/src/csv_viewer.dart';
import 'package:table_example/src/dynamic_flex_table.dart';
import 'package:table_example/src/empty_flex_table.dart';
import 'package:table_example/src/filtered_flex_table.dart';
import 'package:table_example/src/initial_flex_table_sizes.dart';
import 'package:table_example/src/mixed_widgets_flex_table.dart';
import 'package:table_example/src/not_resizable_flex_table.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flex Table Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AlignmentFlexTable(
                  dataAlignment: Alignment.centerLeft,
                  headerAlignment: Alignment.centerLeft,
                  title: 'Alignment (Left)',
                ),
              ),
            ),
            title: const Text('Alignment (Left)'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AlignmentFlexTable(
                  dataAlignment: Alignment.topCenter,
                  headerAlignment: Alignment.center,
                  title: 'Alignment (Mixed)',
                ),
              ),
            ),
            title: const Text('Alignment (Mixed)'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AlignmentFlexTable(
                  dataAlignment: Alignment.centerRight,
                  headerAlignment: Alignment.centerRight,
                  title: 'Alignment (Right)',
                ),
              ),
            ),
            title: const Text('Alignment (Right)'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DynamicFlexTable(
                  sortable: true,
                  striped: true,
                  title: 'Dynamic Loading',
                ),
              ),
            ),
            title: const Text('Dynamic Loading'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FilteredFlexTable(
                  title: 'Filtered',
                ),
              ),
            ),
            title: const Text('Filtered'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmptyFlexTable(
                  title: 'Empty Builder',
                ),
              ),
            ),
            title: const Text('Empty Builder'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InitialFlexTableSizes(
                  sortable: true,
                  striped: true,
                  title: 'Inital Column Sizes',
                ),
              ),
            ),
            title: const Text('Inital Column Sizes'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MixedWidgetsFlexTable(),
              ),
            ),
            title: const Text('Mixed Widgets'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotResizableFlexTable(
                  title: 'Not Resizable',
                ),
              ),
            ),
            title: const Text('Not Resizable'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/ev_data.csv',
                  title: '190k rows; Not Sortable',
                ),
              ),
            ),
            title: const Text('190k rows; Not Sortable'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/iou_zipcodes.csv',
                  title: '52k rows; Not Sortable',
                ),
              ),
            ),
            title: const Text('52k rows; Not Sortable'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/ev_data.csv',
                  sortable: true,
                  title: '190k rows; Sortable',
                ),
              ),
            ),
            title: const Text('190k rows; Sortable'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/iou_zipcodes.csv',
                  sortable: true,
                  tristate: true,
                  title: '52k rows; Sortable; Tristate',
                ),
              ),
            ),
            title: const Text('52k rows; Sortable; Tristate'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/ev_data.csv',
                  striped: true,
                  title: '190k rows; Not Sortable; Striped',
                ),
              ),
            ),
            title: const Text('190k rows; Not Sortable; Striped'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/iou_zipcodes.csv',
                  striped: true,
                  title: '52k rows; Not Sortable; Striped',
                ),
              ),
            ),
            title: const Text('52k rows; Not Sortable; Striped'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/ev_data.csv',
                  striped: true,
                  sortable: true,
                  tristate: true,
                  title: '190k rows; Sortable; Tristate; Striped',
                ),
              ),
            ),
            title: const Text('190k rows; Sortable; Tristate; Striped'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/iou_zipcodes.csv',
                  striped: true,
                  sortable: true,
                  title: '52k rows; Sortable; Striped',
                ),
              ),
            ),
            title: const Text('52k rows; Sortable; Striped'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/ev_data.csv',
                  filterable: true,
                  striped: true,
                  title: '190k rows; Filterable; Striped',
                ),
              ),
            ),
            title: const Text('190k rows; Filterable; Striped'),
          ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CsvViewer(
                  asset: 'assets/iou_zipcodes.csv',
                  filterable: true,
                  striped: true,
                  title: '52k rows; Filterable; Striped',
                ),
              ),
            ),
            title: const Text('52k rows; Filterable; Striped'),
          ),
        ],
      ),
    );
  }
}
