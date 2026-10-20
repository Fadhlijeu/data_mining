import 'package:flutter/foundation.dart';

import '../models/clustering_config.dart';
import '../models/clustering_result.dart';
import '../models/dataset_model.dart';
import '../models/experiment_history.dart';
import '../services/clustering_service.dart';

enum ProgressPhase {
  idle,
  validating,
  extractingFeatures,
  scaling,
  clustering,
  calculatingMetrics,
  completed,
  failed,
}

class ClusteringProvider extends ChangeNotifier {
  ClusteringConfig? _config;
  ClusteringResult? _activeResult;
  ProgressPhase _phase = ProgressPhase.idle;
  String _progressMessage = '';
  String? _errorMessage;

  final List<ExperimentHistory> _history = [];

  ClusteringConfig? get config => _config;
  ClusteringResult? get activeResult => _activeResult;
  ProgressPhase get phase => _phase;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;
  List<ExperimentHistory> get history => List.unmodifiable(_history);

  bool get isRunning =>
      _phase != ProgressPhase.idle &&
      _phase != ProgressPhase.completed &&
      _phase != ProgressPhase.failed;

  void initializeConfigForDataset(DatasetModel dataset) {
    final defaultAttrs = dataset.numericalColumns.map((c) => c.name).toList();
    final idAttr = dataset.columns
        .where((c) => c.type == ColumnDataType.identifier)
        .map((c) => c.name)
        .firstOrNull;

    _config = ClusteringConfig(
      datasetId: dataset.id,
      datasetName: dataset.name,
      selectedAttributes: defaultAttrs,
      identifierAttribute: idAttr,
      k: 3,
      scaling: FeatureScaling.minMax,
    );
    notifyListeners();
  }

  void ensureConfigForDataset(DatasetModel dataset) {
    if (_config == null ||
        _config!.datasetId != dataset.id ||
        _config!.selectedAttributes.isEmpty) {
      initializeConfigForDataset(dataset);
    }
  }

  void updateConfig(ClusteringConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void toggleAttribute(String attrName) {
    if (_config == null) return;
    final attrs = List<String>.from(_config!.selectedAttributes);
    if (attrs.contains(attrName)) {
      attrs.remove(attrName);
    } else {
      attrs.add(attrName);
    }
    _config = _config!.copyWith(selectedAttributes: attrs);
    notifyListeners();
  }

  void setK(int newK) {
    if (_config == null) return;
    _config = _config!.copyWith(k: newK);
    notifyListeners();
  }

  void setScaling(FeatureScaling scaling) {
    if (_config == null) return;
    _config = _config!.copyWith(scaling: scaling);
    notifyListeners();
  }

  void setIdentifierAttribute(String? attr) {
    if (_config == null) return;
    _config = _config!.copyWith(identifierAttribute: attr);
    notifyListeners();
  }

  Future<bool> executeClustering(DatasetModel dataset) async {
    if (_config == null) {
      _errorMessage = 'No configuration found.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _updateProgress(ProgressPhase.validating, 'Validating dataset attributes...');
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      _updateProgress(ProgressPhase.extractingFeatures, 'Extracting feature vectors...');
      await Future.delayed(const Duration(milliseconds: 150));

      _updateProgress(ProgressPhase.scaling, 'Applying feature normalization...');
      await Future.delayed(const Duration(milliseconds: 150));

      _updateProgress(ProgressPhase.clustering, 'Running K-Means algorithm (K=${_config!.k})...');
      await Future.delayed(const Duration(milliseconds: 200));

      _updateProgress(ProgressPhase.calculatingMetrics, 'Computing WCSS & Silhouette Score metrics...');

      final result = await ClusteringService.runKMeans(
        dataset: dataset,
        config: _config!,
      );

      _activeResult = result;

      // Add to history
      final historyItem = ExperimentHistory(
        id: result.id,
        datasetName: dataset.name,
        clusterCount: result.config.k,
        totalRecords: result.dataPoints.length,
        attributeCount: result.config.selectedAttributes.length,
        silhouetteScore: result.silhouetteScore,
        wcss: result.wcss,
        timestamp: result.executedAt,
        result: result,
      );
      _history.insert(0, historyItem);

      _updateProgress(ProgressPhase.completed, 'Clustering complete!');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _updateProgress(ProgressPhase.failed, 'Execution failed');
      notifyListeners();
      return false;
    }
  }

  void _updateProgress(ProgressPhase phase, String message) {
    _phase = phase;
    _progressMessage = message;
    notifyListeners();
  }

  void selectResultFromHistory(ExperimentHistory item) {
    _activeResult = item.result;
    _config = item.result.config;
    notifyListeners();
  }

  void resetProgress() {
    _phase = ProgressPhase.idle;
    _progressMessage = '';
    _errorMessage = null;
    notifyListeners();
  }
}
