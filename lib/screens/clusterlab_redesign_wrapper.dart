import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clustering_config.dart';
import '../providers/clustering_provider.dart';
import '../providers/dataset_provider.dart';
import 'analyze/analysis_progress_screen.dart';
import 'clusterlab_redesign.dart';
import 'datasets/dataset_preview_screen.dart';
import 'results/clustering_results_screen.dart';

class ClusterLabRedesignWrapper extends StatelessWidget {
  const ClusterLabRedesignWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DatasetProvider, ClusteringProvider>(
      builder: (context, datasetProv, clusterProv, _) {
        final uiDatasets = datasetProv.datasets.map((d) {
          return ClusterLabDataset(
            id: d.id,
            name: d.name,
            recordCount: d.rowCount,
            attributeNames: d.numericalColumns.map((c) => c.name).toList(),
            isDemo: d.source == 'Sample Data',
            updatedLabel: d.source == 'Sample Data' ? 'Sample dataset' : 'Imported dataset',
          );
        }).toList();

        final uiExperiments = clusterProv.history.map((h) {
          return ClusterLabExperiment(
            id: h.id,
            name: h.datasetName,
            algorithm: 'K-Means',
            clusterCount: h.clusterCount,
            recordCount: h.totalRecords,
            dateLabel: '${h.timestamp.day}/${h.timestamp.month}/${h.timestamp.year} • Score: ${h.silhouetteScore}',
            status: 'Completed',
            isDemo: h.datasetName.contains('Demo'),
          );
        }).toList();

        return ClusterLabRedesign(
          datasets: uiDatasets,
          experiments: uiExperiments,
          onImportCsv: () async {
            final success = await datasetProv.importCsvFromFile();
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dataset imported successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (datasetProv.importError != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Import error: ${datasetProv.importError}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFFB42318),
                ),
              );
            }
          },
          onRunAnalysis: (ClusterLabAnalysisRequest req) async {
            final dataset = datasetProv.datasets.firstWhere((d) => d.id == req.datasetId);
            datasetProv.setActiveDataset(dataset);

            FeatureScaling scalingEnum = FeatureScaling.minMax;
            if (req.scaling.contains('Z-score') || req.scaling.contains('Z-Score')) {
              scalingEnum = FeatureScaling.zScore;
            } else if (req.scaling.contains('Raw')) {
              scalingEnum = FeatureScaling.none;
            }

            clusterProv.updateConfig(ClusteringConfig(
              datasetId: dataset.id,
              datasetName: dataset.name,
              selectedAttributes: req.featureNames,
              k: req.clusterCount,
              scaling: scalingEnum,
            ));

            if (context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysisProgressScreen(dataset: dataset),
                ),
              );
            }
          },
          onOpenDataset: (ClusterLabDataset ds) {
            final dataset = datasetProv.datasets.firstWhere((d) => d.id == ds.id);
            datasetProv.setActiveDataset(dataset);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DatasetPreviewScreen(dataset: dataset),
              ),
            );
          },
          onOpenExperiment: (ClusterLabExperiment exp) {
            final historyItem = clusterProv.history.firstWhere((h) => h.id == exp.id);
            clusterProv.selectResultFromHistory(historyItem);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClusteringResultsScreen(),
              ),
            );
          },
          onHelp: () {
            showAboutDialog(
              context: context,
              applicationName: 'ClusterLab',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.hub, color: Color(0xFF4B4ACF), size: 36),
              children: const [
                Text(
                  'Domain-agnostic Data Mining & Clustering workspace for CSV datasets. Integrated with native Dart K-Means engine and fl_chart.',
                ),
              ],
            );
          },
        );
      },
    );
  }
}
