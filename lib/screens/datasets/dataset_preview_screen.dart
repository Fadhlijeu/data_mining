import 'package:flutter/material.dart';

import '../../models/dataset_model.dart';

class DatasetPreviewScreen extends StatefulWidget {
  final DatasetModel dataset;

  const DatasetPreviewScreen({super.key, required this.dataset});

  @override
  State<DatasetPreviewScreen> createState() => _DatasetPreviewScreenState();
}

class _DatasetPreviewScreenState extends State<DatasetPreviewScreen> {
  String _searchQuery = '';
  final int _rowsPerPage = 25;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dataset = widget.dataset;

    // Filter rows based on search
    final filteredRows = dataset.rows.where((row) {
      if (_searchQuery.isEmpty) return true;
      return row.values.any((val) => val != null && val.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    final totalFiltered = filteredRows.length;
    final totalPages = (totalFiltered / _rowsPerPage).ceil().clamp(1, 9999);
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage < totalFiltered) ? startIndex + _rowsPerPage : totalFiltered;
    final visibleRows = (startIndex < totalFiltered) ? filteredRows.sublist(startIndex, endIndex) : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dataset.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text('${dataset.rowCount} Rows • ${dataset.columnCount} Columns (${dataset.numericalColumns.length} Numeric, ${dataset.categoricalColumns.length} Categorical)', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Column Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: cs.surfaceContainer,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dataset.columns.map((col) {
                  final uniqueList = col.uniqueValues ?? [];
                  final sampleText = uniqueList.isNotEmpty
                      ? '${uniqueList.length} Categories: ${uniqueList.take(2).join(', ')}${uniqueList.length > 2 ? '...' : ''}'
                      : 'CATEGORICAL';

                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              col.isNumerical ? Icons.numbers : Icons.label_outlined,
                              size: 14,
                              color: col.isNumerical ? cs.primary : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              col.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (col.isNumerical && col.mean != null)
                          Text(
                            'Mean: ${col.mean!.toStringAsFixed(2)} | Min: ${col.min} | Max: ${col.max}',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          )
                        else
                          Text(
                            '$sampleText | ${col.missingCount} Missing',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(),

          // Search and Pagination Controls
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                      filled: true,
                      fillColor: cs.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Showing $startIndex-$endIndex of $totalFiltered',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Scrollable Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(cs.surfaceContainerHigh),
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 52,
                  columns: dataset.columns.map((col) {
                    return DataColumn(
                      label: Row(
                        children: [
                          Text(
                            col.name,
                            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: col.isNumerical ? cs.primaryContainer : cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              col.isNumerical ? 'NUM' : 'CAT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: col.isNumerical ? cs.primary : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  rows: visibleRows.map((rowMap) {
                    return DataRow(
                      cells: dataset.columns.map((col) {
                        final val = rowMap[col.name];
                        return DataCell(
                          Text(
                            val != null ? val.toString() : '-',
                            style: TextStyle(
                              color: val == null ? cs.onSurfaceVariant : cs.onSurface,
                              fontStyle: val == null ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Pagination Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cs.surfaceContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: TextStyle(color: cs.onSurface),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: cs.onSurface,
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      color: cs.onSurface,
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
