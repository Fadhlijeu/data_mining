import 'dart:math';

import '../models/clustering_config.dart';
import '../models/clustering_result.dart';
import '../models/dataset_model.dart';

class ClusteringService {
  /// Executes real K-Means clustering on the dataset based on config
  static Future<ClusteringResult> runKMeans({
    required DatasetModel dataset,
    required ClusteringConfig config,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    if (config.selectedAttributes.isEmpty) {
      throw Exception('Please select at least one attribute for clustering.');
    }

    final int k = config.k;
    final List<String> attrs = config.selectedAttributes;
    final int featureCount = attrs.length;

    // 1. Extract raw numerical feature vectors & handle missing values
    final List<Map<String, dynamic>> validRows = [];
    final List<List<double>> rawMatrix = [];

    // Compute feature column means for imputation
    final Map<String, double> featureMeans = {};
    for (var attr in attrs) {
      double sum = 0;
      int count = 0;
      for (var row in dataset.rows) {
        final val = row[attr];
        if (val is num) {
          sum += val.toDouble();
          count++;
        }
      }
      featureMeans[attr] = count > 0 ? sum / count : 0.0;
    }

    for (int i = 0; i < dataset.rows.length; i++) {
      final row = dataset.rows[i];
      final List<double> vector = [];
      bool hasMissing = false;

      for (var attr in attrs) {
        final val = row[attr];
        if (val == null || val is! num) {
          hasMissing = true;
          if (config.missingValueHandling == MissingValueHandling.meanImpute) {
            vector.add(featureMeans[attr] ?? 0.0);
          } else {
            break; // Drop row
          }
        } else {
          vector.add(val.toDouble());
        }
      }

      if (!hasMissing || config.missingValueHandling == MissingValueHandling.meanImpute) {
        validRows.add(row);
        rawMatrix.add(vector);
      }
    }

    if (rawMatrix.length < k) {
      throw Exception('Dataset record count (${rawMatrix.length}) is smaller than K ($k).');
    }

    // 2. Feature Scaling
    final List<List<double>> scaledMatrix = List.generate(
      rawMatrix.length,
      (_) => List.filled(featureCount, 0.0),
    );

    final List<double> mins = List.filled(featureCount, double.infinity);
    final List<double> maxs = List.filled(featureCount, -double.infinity);
    final List<double> means = List.filled(featureCount, 0.0);
    final List<double> stds = List.filled(featureCount, 0.0);

    for (int j = 0; j < featureCount; j++) {
      double sum = 0;
      for (int i = 0; i < rawMatrix.length; i++) {
        final v = rawMatrix[i][j];
        if (v < mins[j]) mins[j] = v;
        if (v > maxs[j]) maxs[j] = v;
        sum += v;
      }
      means[j] = sum / rawMatrix.length;

      double varianceSum = 0;
      for (int i = 0; i < rawMatrix.length; i++) {
        varianceSum += pow(rawMatrix[i][j] - means[j], 2);
      }
      stds[j] = sqrt(varianceSum / rawMatrix.length);
    }

    for (int i = 0; i < rawMatrix.length; i++) {
      for (int j = 0; j < featureCount; j++) {
        final rawVal = rawMatrix[i][j];
        if (config.scaling == FeatureScaling.minMax) {
          final range = maxs[j] - mins[j];
          scaledMatrix[i][j] = range == 0 ? 0.0 : (rawVal - mins[j]) / range;
        } else if (config.scaling == FeatureScaling.zScore) {
          scaledMatrix[i][j] = stds[j] == 0 ? 0.0 : (rawVal - means[j]) / stds[j];
        } else {
          scaledMatrix[i][j] = rawVal;
        }
      }
    }

    // 3. Initialize K Centroids using K-Means++
    final Random random = Random(42); // Fixed seed for reproducible results
    final List<List<double>> centroids = [];

    // Pick first centroid randomly
    centroids.add(List.from(scaledMatrix[random.nextInt(scaledMatrix.length)]));

    while (centroids.length < k) {
      final List<double> distSq = [];
      double totalDistSq = 0;

      for (int i = 0; i < scaledMatrix.length; i++) {
        double minDistance = double.infinity;
        for (var c in centroids) {
          final d = _euclideanDistanceSq(scaledMatrix[i], c);
          if (d < minDistance) minDistance = d;
        }
        distSq.add(minDistance);
        totalDistSq += minDistance;
      }

      double r = random.nextDouble() * totalDistSq;
      double cumSum = 0;
      int chosenIdx = 0;
      for (int i = 0; i < distSq.length; i++) {
        cumSum += distSq[i];
        if (cumSum >= r) {
          chosenIdx = i;
          break;
        }
      }
      centroids.add(List.from(scaledMatrix[chosenIdx]));
    }

    // 4. Convergence Loop
    List<int> assignments = List.filled(scaledMatrix.length, 0);
    int iterations = 0;
    bool changed = true;

    while (changed && iterations < config.maxIterations) {
      changed = false;
      iterations++;

      // Assign to nearest centroid
      for (int i = 0; i < scaledMatrix.length; i++) {
        int nearestIdx = 0;
        double minDistance = double.infinity;

        for (int c = 0; c < k; c++) {
          final dist = _euclideanDistanceSq(scaledMatrix[i], centroids[c]);
          if (dist < minDistance) {
            minDistance = dist;
            nearestIdx = c;
          }
        }

        if (assignments[i] != nearestIdx) {
          assignments[i] = nearestIdx;
          changed = true;
        }
      }

      // Update centroids
      if (changed) {
        final List<List<double>> newCentroids = List.generate(
          k,
          (_) => List.filled(featureCount, 0.0),
        );
        final List<int> counts = List.filled(k, 0);

        for (int i = 0; i < scaledMatrix.length; i++) {
          final c = assignments[i];
          counts[c]++;
          for (int j = 0; j < featureCount; j++) {
            newCentroids[c][j] += scaledMatrix[i][j];
          }
        }

        for (int c = 0; c < k; c++) {
          if (counts[c] > 0) {
            for (int j = 0; j < featureCount; j++) {
              centroids[c][j] = newCentroids[c][j] / counts[c];
            }
          }
        }
      }
    }

    // 5. Calculate Metrics (WCSS & Silhouette Score)
    double wcss = 0;
    for (int i = 0; i < scaledMatrix.length; i++) {
      final c = assignments[i];
      wcss += _euclideanDistanceSq(scaledMatrix[i], centroids[c]);
    }

    final double silhouetteScore = _calculateSilhouetteScore(scaledMatrix, assignments, k);

    // 6. Denormalize centroids back to original attribute scale for display
    final List<Map<String, double>> denormalizedCentroids = [];
    for (int c = 0; c < k; c++) {
      final Map<String, double> centroidMap = {};
      for (int j = 0; j < featureCount; j++) {
        final scaledVal = centroids[c][j];
        double rawVal = scaledVal;
        if (config.scaling == FeatureScaling.minMax) {
          rawVal = scaledVal * (maxs[j] - mins[j]) + mins[j];
        } else if (config.scaling == FeatureScaling.zScore) {
          rawVal = scaledVal * stds[j] + means[j];
        }
        centroidMap[attrs[j]] = double.parse(rawVal.toStringAsFixed(2));
      }
      denormalizedCentroids.add(centroidMap);
    }

    // 7. Cluster summaries
    final List<ClusterSummary> clusterSummaries = [];
    for (int c = 0; c < k; c++) {
      final count = assignments.where((a) => a == c).length;
      clusterSummaries.add(ClusterSummary(
        clusterId: c,
        count: count,
        percentage: (count / scaledMatrix.length) * 100,
        centroid: denormalizedCentroids[c],
      ));
    }

    // 8. Projection for 2D Scatter Plot
    // Select top 2 attributes or normalized 2D projection
    final List<ClusterDataPoint> dataPoints = [];
    for (int i = 0; i < scaledMatrix.length; i++) {
      final double xVal = scaledMatrix[i][0];
      final double yVal = featureCount > 1 ? scaledMatrix[i][1] : (i / scaledMatrix.length);

      String? recId;
      if (config.identifierAttribute != null && validRows[i].containsKey(config.identifierAttribute)) {
        recId = validRows[i][config.identifierAttribute]?.toString();
      }

      dataPoints.add(ClusterDataPoint(
        recordIndex: i + 1,
        recordId: recId,
        rawValues: validRows[i],
        featureValues: rawMatrix[i],
        clusterId: assignments[i],
        x: xVal,
        y: yVal,
      ));
    }

    stopwatch.stop();

    return ClusteringResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      executedAt: DateTime.now(),
      config: config,
      executionDurationMs: stopwatch.elapsedMilliseconds,
      iterationsPerformed: iterations,
      wcss: double.parse(wcss.toStringAsFixed(2)),
      silhouetteScore: double.parse(silhouetteScore.toStringAsFixed(3)),
      clusterSummaries: clusterSummaries,
      dataPoints: dataPoints,
    );
  }

  static double _euclideanDistanceSq(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum;
  }

  static double _calculateSilhouetteScore(List<List<double>> points, List<int> assignments, int k) {
    if (points.length <= k || k <= 1) return 0.0;

    // Subsample if dataset is large for computational efficiency
    final int sampleSize = min(300, points.length);
    double totalSilhouette = 0.0;
    int validSamples = 0;

    for (int i = 0; i < sampleSize; i++) {
      final clusterI = assignments[i];

      // a(i): average distance to points in same cluster
      double sameSum = 0;
      int sameCount = 0;

      // b(i): min average distance to points in another cluster
      final Map<int, double> otherSums = {};
      final Map<int, int> otherCounts = {};

      for (int j = 0; j < points.length; j++) {
        if (i == j) continue;
        final dist = sqrt(_euclideanDistanceSq(points[i], points[j]));
        final clusterJ = assignments[j];

        if (clusterJ == clusterI) {
          sameSum += dist;
          sameCount++;
        } else {
          otherSums[clusterJ] = (otherSums[clusterJ] ?? 0) + dist;
          otherCounts[clusterJ] = (otherCounts[clusterJ] ?? 0) + 1;
        }
      }

      if (sameCount == 0) continue;
      final double a = sameSum / sameCount;

      double b = double.infinity;
      otherSums.forEach((clusterKey, sumVal) {
        final countVal = otherCounts[clusterKey]!;
        final avgDist = sumVal / countVal;
        if (avgDist < b) b = avgDist;
      });

      if (b == double.infinity) continue;

      final double s = (b - a) / max(a, b);
      totalSilhouette += s;
      validSamples++;
    }

    return validSamples > 0 ? (totalSilhouette / validSamples) : 0.0;
  }
}
