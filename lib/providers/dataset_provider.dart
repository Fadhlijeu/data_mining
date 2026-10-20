import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/dataset_model.dart';
import '../services/csv_parser_service.dart';

class DatasetProvider extends ChangeNotifier {
  final List<DatasetModel> _datasets = [];
  DatasetModel? _activeDataset;
  bool _isImporting = false;
  String? _importError;

  List<DatasetModel> get datasets => List.unmodifiable(_datasets);
  DatasetModel? get activeDataset => _activeDataset;
  bool get isImporting => _isImporting;
  String? get importError => _importError;

  DatasetProvider();

  void setActiveDataset(DatasetModel dataset) {
    _activeDataset = dataset;
    notifyListeners();
  }

  void deleteDataset(String id) {
    _datasets.removeWhere((d) => d.id == id);
    if (_activeDataset?.id == id) {
      _activeDataset = _datasets.isNotEmpty ? _datasets.first : null;
    }
    notifyListeners();
  }

  Future<bool> importCsvFromFile() async {
    _isImporting = true;
    _importError = null;
    notifyListeners();

    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv', 'txt'],
          withData: true,
        );
      } catch (_) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
        );
      }

      if (result == null || result.files.isEmpty) {
        _isImporting = false;
        notifyListeners();
        return false;
      }

      final file = result.files.first;
      String csvContent = '';

      if (file.bytes != null && file.bytes!.isNotEmpty) {
        csvContent = String.fromCharCodes(file.bytes!);
      } else if (file.path != null && file.path!.isNotEmpty) {
        csvContent = await File(file.path!).readAsString();
      } else {
        throw Exception('Could not read file content from picker.');
      }

      final datasetName = file.name.replaceAll('.csv', '').replaceAll('.txt', '');

      final dataset = CsvParserService.parseCsvContent(
        csvString: csvContent,
        datasetName: datasetName,
        source: 'Imported File',
      );

      _datasets.insert(0, dataset);
      _activeDataset = dataset;
      _isImporting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _importError = e.toString().replaceAll('Exception: ', '');
      _isImporting = false;
      notifyListeners();
      return false;
    }
  }

  void addDataset(DatasetModel dataset) {
    _datasets.insert(0, dataset);
    _activeDataset = dataset;
    notifyListeners();
  }
}
