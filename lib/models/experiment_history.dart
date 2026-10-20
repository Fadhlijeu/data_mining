import 'clustering_result.dart';

class ExperimentHistory {
  final String id;
  final String datasetName;
  final int clusterCount;
  final int totalRecords;
  final int attributeCount;
  final double silhouetteScore;
  final double wcss;
  final DateTime timestamp;
  final ClusteringResult result;

  ExperimentHistory({
    required this.id,
    required this.datasetName,
    required this.clusterCount,
    required this.totalRecords,
    required this.attributeCount,
    required this.silhouetteScore,
    required this.wcss,
    required this.timestamp,
    required this.result,
  });
}
