import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/dataset_model.dart';
import '../../providers/clustering_provider.dart';
import '../results/clustering_results_screen.dart';

class AnalysisProgressScreen extends StatefulWidget {
  final DatasetModel dataset;

  const AnalysisProgressScreen({super.key, required this.dataset});

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = Provider.of<ClusteringProvider>(context, listen: false);
      final success = await prov.executeClustering(widget.dataset);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ClusteringResultsScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Analysis'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ClusteringProvider>(
        builder: (context, clusterProv, _) {
          final phase = clusterProv.phase;
          final msg = clusterProv.progressMessage;
          final error = clusterProv.errorMessage;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.errorLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Analysis Failed',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        clusterProv.resetProgress();
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Workspace'),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      msg.isEmpty ? 'Preparing Analysis...' : msg,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Executing K-Means clustering algorithm on ${widget.dataset.name}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Progress indicators
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildStepItem('1. Validate Dataset', phase.index >= ProgressPhase.validating.index),
                          const Divider(),
                          _buildStepItem('2. Feature Extraction', phase.index >= ProgressPhase.extractingFeatures.index),
                          const Divider(),
                          _buildStepItem('3. Feature Scaling', phase.index >= ProgressPhase.scaling.index),
                          const Divider(),
                          _buildStepItem('4. K-Means Algorithm', phase.index >= ProgressPhase.clustering.index),
                          const Divider(),
                          _buildStepItem('5. Metrics Calculation', phase.index >= ProgressPhase.calculatingMetrics.index),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
