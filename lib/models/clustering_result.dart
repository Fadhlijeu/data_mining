import 'clustering_config.dart';

class ClusterDataPoint {
  final int recordIndex;
  final String? recordId;
  final Map<String, dynamic> rawValues;
  final List<double> featureValues;
  final int clusterId;
  final double x; // Projection X for 2D scatter plot
  final double y; // Projection Y for 2D scatter plot

  ClusterDataPoint({
    required this.recordIndex,
    this.recordId,
    required this.rawValues,
    required this.featureValues,
    required this.clusterId,
    required this.x,
    required this.y,
  });
}

class ClusterSummary {
  final int clusterId;
  final int count;
  final double percentage;
  final Map<String, double> centroid; // Feature name -> Centroid value

  ClusterSummary({
    required this.clusterId,
    required this.count,
    required this.percentage,
    required this.centroid,
  });
}

class ClusteringResult {
  final String id;
  final DateTime executedAt;
  final ClusteringConfig config;
  final int executionDurationMs;
  final int iterationsPerformed;
  final double wcss; // Within-Cluster Sum of Squares (Inertia)
  final double silhouetteScore; // Evaluation metric (-1 to 1)
  final List<ClusterSummary> clusterSummaries;
  final List<ClusterDataPoint> dataPoints;

  ClusteringResult({
    required this.id,
    required this.executedAt,
    required this.config,
    required this.executionDurationMs,
    required this.iterationsPerformed,
    required this.wcss,
    required this.silhouetteScore,
    required this.clusterSummaries,
    required this.dataPoints,
  });
}
