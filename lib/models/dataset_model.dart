enum ColumnDataType {
  numeric,
  categorical,
  identifier,
}

class ColumnModel {
  final String name;
  final ColumnDataType type;
  final int missingCount;
  final double? min;
  final double? max;
  final double? mean;
  final List<String>? uniqueValues;

  ColumnModel({
    required this.name,
    required this.type,
    this.missingCount = 0,
    this.min,
    this.max,
    this.mean,
    this.uniqueValues,
  });

  bool get isNumerical => type == ColumnDataType.numeric;
}

class DatasetModel {
  final String id;
  final String name;
  final String source;
  final DateTime importedAt;
  final List<ColumnModel> columns;
  final List<Map<String, dynamic>> rows;

  DatasetModel({
    required this.id,
    required this.name,
    required this.source,
    required this.importedAt,
    required this.columns,
    required this.rows,
  });

  int get rowCount => rows.length;
  int get columnCount => columns.length;

  List<ColumnModel> get numericalColumns =>
      columns.where((c) => c.type == ColumnDataType.numeric).toList();

  List<ColumnModel> get categoricalColumns =>
      columns.where((c) => c.type == ColumnDataType.categorical).toList();

  int get totalMissingValues =>
      columns.fold(0, (sum, col) => sum + col.missingCount);
}
