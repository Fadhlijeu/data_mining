import 'package:csv/csv.dart';

import '../models/dataset_model.dart';

class CsvParserService {
  /// Parses raw CSV text content and builds a DatasetModel automatically for any CSV
  static DatasetModel parseCsvContent({
    required String csvString,
    required String datasetName,
    required String source,
  }) {
    final normalizedString = csvString.replaceAll('\r\n', '\n');

    // Detect field delimiter if comma yields 1 column
    String fieldDelimiter = ',';
    final firstLine = normalizedString.split('\n').firstWhere(
          (line) => line.trim().isNotEmpty,
          orElse: () => '',
        );

    if (firstLine.contains(';') && !firstLine.contains(',')) {
      fieldDelimiter = ';';
    } else if (firstLine.contains('\t') && !firstLine.contains(',')) {
      fieldDelimiter = '\t';
    }

    final List<List<dynamic>> rawTable = CsvToListConverter(
      fieldDelimiter: fieldDelimiter,
      eol: '\n',
      shouldParseNumbers: true,
      allowInvalid: true,
    ).convert(normalizedString);

    if (rawTable.isEmpty) {
      throw Exception('The CSV file is empty.');
    }

    // Header row
    final List<dynamic> headers = rawTable.first;
    final List<List<dynamic>> dataRows = rawTable.sublist(1);

    final List<ColumnModel> columns = [];
    final List<Map<String, dynamic>> parsedRows = [];

    // First pass: analyze column data types and semantic stats
    for (int colIdx = 0; colIdx < headers.length; colIdx++) {
      final String colName = headers[colIdx].toString().trim();
      int numericCount = 0;
      int nonNullCount = 0;
      int missingCount = 0;
      double min = double.infinity;
      double max = -double.infinity;
      double sum = 0.0;
      final Set<String> uniqueVals = {};

      for (var row in dataRows) {
        if (colIdx >= row.length) {
          missingCount++;
          continue;
        }
        final val = row[colIdx];
        if (val == null || val.toString().trim().isEmpty) {
          missingCount++;
          continue;
        }

        nonNullCount++;
        final valStr = val.toString().trim();
        uniqueVals.add(valStr);

        double? numVal;
        if (val is num) {
          numVal = val.toDouble();
        } else {
          // Clean currency and percentage symbols if present
          final cleanedStr = valStr
              .replaceAll('\$', '')
              .replaceAll('€', '')
              .replaceAll('£', '')
              .replaceAll('%', '')
              .replaceAll(',', '')
              .trim();
          numVal = double.tryParse(cleanedStr);
        }

        if (numVal != null) {
          numericCount++;
          if (numVal < min) min = numVal;
          if (numVal > max) max = numVal;
          sum += numVal;
        }
      }

      final isNumeric = nonNullCount > 0 && (numericCount / nonNullCount) >= 0.75;
      final isId = !isNumeric && uniqueVals.length == dataRows.length && dataRows.length > 5;

      final ColumnDataType type = isId
          ? ColumnDataType.identifier
          : (isNumeric ? ColumnDataType.numeric : ColumnDataType.categorical);

      columns.add(ColumnModel(
        name: colName,
        type: type,
        missingCount: missingCount,
        min: isNumeric && numericCount > 0 ? min : null,
        max: isNumeric && numericCount > 0 ? max : null,
        mean: isNumeric && numericCount > 0 ? sum / numericCount : null,
        uniqueValues: !isNumeric ? uniqueVals.take(20).toList() : null,
      ));
    }

    // Second pass: construct row maps for each record
    for (int rowIdx = 0; rowIdx < dataRows.length; rowIdx++) {
      final row = dataRows[rowIdx];
      final Map<String, dynamic> rowMap = {};
      for (int colIdx = 0; colIdx < columns.length; colIdx++) {
        final colName = columns[colIdx].name;
        final val = colIdx < row.length ? row[colIdx] : null;

        if (columns[colIdx].isNumerical) {
          if (val is num) {
            rowMap[colName] = val.toDouble();
          } else {
            final cleanedStr = val?.toString().trim().replaceAll('\$', '').replaceAll('€', '').replaceAll('%', '').replaceAll(',', '') ?? '';
            rowMap[colName] = double.tryParse(cleanedStr);
          }
        } else {
          rowMap[colName] = val != null ? val.toString().trim() : '';
        }
      }
      parsedRows.add(rowMap);
    }

    return DatasetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + colIdxSeed().toString(),
      name: datasetName,
      source: source,
      importedAt: DateTime.now(),
      columns: columns,
      rows: parsedRows,
    );
  }

  static int _idSeed = 0;
  static int colIdxSeed() => ++_idSeed;
}
