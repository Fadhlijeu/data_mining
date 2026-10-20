enum FeatureScaling {
  none,
  minMax,
  zScore,
}

enum MissingValueHandling {
  drop,
  meanImpute,
}

class ClusteringConfig {
  final String datasetId;
  final String datasetName;
  final List<String> selectedAttributes;
  final String? identifierAttribute;
  final int k;
  final int maxIterations;
  final FeatureScaling scaling;
  final MissingValueHandling missingValueHandling;

  ClusteringConfig({
    required this.datasetId,
    required this.datasetName,
    required this.selectedAttributes,
    this.identifierAttribute,
    this.k = 3,
    this.maxIterations = 100,
    this.scaling = FeatureScaling.minMax,
    this.missingValueHandling = MissingValueHandling.meanImpute,
  });

  ClusteringConfig copyWith({
    String? datasetId,
    String? datasetName,
    List<String>? selectedAttributes,
    String? identifierAttribute,
    int? k,
    int? maxIterations,
    FeatureScaling? scaling,
    MissingValueHandling? missingValueHandling,
  }) {
    return ClusteringConfig(
      datasetId: datasetId ?? this.datasetId,
      datasetName: datasetName ?? this.datasetName,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      identifierAttribute: identifierAttribute ?? this.identifierAttribute,
      k: k ?? this.k,
      maxIterations: maxIterations ?? this.maxIterations,
      scaling: scaling ?? this.scaling,
      missingValueHandling: missingValueHandling ?? this.missingValueHandling,
    );
  }
}
