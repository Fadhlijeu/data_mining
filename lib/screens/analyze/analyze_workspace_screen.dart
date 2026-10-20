import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/clustering_config.dart';
import '../../providers/clustering_provider.dart';
import '../../providers/dataset_provider.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/section_header.dart';
import 'analysis_progress_screen.dart';

class AnalyzeWorkspaceScreen extends StatefulWidget {
  const AnalyzeWorkspaceScreen({super.key});

  @override
  State<AnalyzeWorkspaceScreen> createState() => _AnalyzeWorkspaceScreenState();
}

class _AnalyzeWorkspaceScreenState extends State<AnalyzeWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dsProv = Provider.of<DatasetProvider>(context, listen: false);
      final clProv = Provider.of<ClusteringProvider>(context, listen: false);
      if (dsProv.activeDataset != null) {
        clProv.ensureConfigForDataset(dsProv.activeDataset!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clustering Workspace'),
      ),
      body: Consumer2<DatasetProvider, ClusteringProvider>(
        builder: (context, datasetProv, clusterProv, _) {
          final datasets = datasetProv.datasets;
          final activeDataset = datasetProv.activeDataset;

          if (datasets.isEmpty || activeDataset == null) {
            return EmptyStateView(
              icon: Icons.science_outlined,
              title: 'No Dataset Selected',
              description: 'Select or import a CSV dataset from the Datasets tab before configuring clustering.',
              buttonText: 'Import CSV',
              onButtonPressed: () async {
                await datasetProv.importCsvFromFile();
              },
            );
          }

          clusterProv.ensureConfigForDataset(activeDataset);

          final config = clusterProv.config ??
              ClusteringConfig(
                datasetId: activeDataset.id,
                datasetName: activeDataset.name,
                selectedAttributes: activeDataset.numericalColumns.map((c) => c.name).toList(),
                k: 3,
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 1: Select Dataset
                const SectionHeader(
                  title: 'Step 1: Dataset Selection',
                  subtitle: 'Choose target dataset for clustering analysis',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: activeDataset.id,
                      items: datasets.map((ds) {
                        return DropdownMenuItem<String>(
                          value: ds.id,
                          child: Row(
                            children: [
                              const Icon(Icons.table_chart_outlined, size: 20, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ds.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${ds.rowCount} rows',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedId) {
                        if (selectedId != null) {
                          final newDs = datasets.firstWhere((d) => d.id == selectedId);
                          datasetProv.setActiveDataset(newDs);
                          clusterProv.initializeConfigForDataset(newDs);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Step 2: Attribute Selection
                SectionHeader(
                  title: 'Step 2: Attribute Selection',
                  subtitle: 'Select numerical features for K-Means distance vectors (${config.selectedAttributes.length} selected)',
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeDataset.numericalColumns.isEmpty)
                        const Text(
                          'No numerical columns detected in this dataset.',
                          style: TextStyle(color: AppColors.error),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: activeDataset.columns.map((col) {
                            final isNumerical = col.isNumerical;
                            final isSelected = config.selectedAttributes.contains(col.name);

                            return FilterChip(
                              selected: isSelected,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(col.name),
                                  if (!isNumerical)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Text('(cat)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ),
                                ],
                              ),
                              onSelected: isNumerical
                                  ? (_) {
                                      clusterProv.toggleAttribute(col.name);
                                    }
                                  : null,
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: AppColors.primary,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Identifier Column Selector
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          const Text(
                            'Identifier:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String?>(
                              value: config.identifierAttribute,
                              isDense: true,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Auto Record Index', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                ),
                                ...activeDataset.columns.map((c) {
                                  return DropdownMenuItem<String?>(
                                    value: c.name,
                                    child: Text(c.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                clusterProv.setIdentifierAttribute(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Step 3: Data Preprocessing
                const SectionHeader(
                  title: 'Step 3: Feature Scaling & Preprocessing',
                  subtitle: 'Normalize attribute dimensions for balanced distance computations',
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<FeatureScaling>(
                        value: FeatureScaling.minMax,
                        groupValue: config.scaling,
                        title: const Text('Min-Max Normalization (0.0 to 1.0)'),
                        subtitle: const Text('Rescales features into a uniform range from 0 to 1.', style: TextStyle(fontSize: 12)),
                        onChanged: (val) {
                          if (val != null) clusterProv.setScaling(val);
                        },
                      ),
                      const Divider(),
                      RadioListTile<FeatureScaling>(
                        value: FeatureScaling.zScore,
                        groupValue: config.scaling,
                        title: const Text('Z-Score Standardization (Mean 0, Std 1)'),
                        subtitle: const Text('Standardizes features using mean and standard deviation.', style: TextStyle(fontSize: 12)),
                        onChanged: (val) {
                          if (val != null) clusterProv.setScaling(val);
                        },
                      ),
                      const Divider(),
                      RadioListTile<FeatureScaling>(
                        value: FeatureScaling.none,
                        groupValue: config.scaling,
                        title: const Text('Raw Values (No Scaling)'),
                        subtitle: const Text('Uses raw attribute values directly.', style: TextStyle(fontSize: 12)),
                        onChanged: (val) {
                          if (val != null) clusterProv.setScaling(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Step 4: Algorithm Configuration
                const SectionHeader(
                  title: 'Step 4: Algorithm Parameters',
                  subtitle: 'Configure K-Means cluster count (K)',
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Number of Clusters (K):',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'K = ${config.k}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: config.k.toDouble(),
                        min: 2,
                        max: 8,
                        divisions: 6,
                        label: 'K = ${config.k}',
                        onChanged: (val) {
                          clusterProv.setK(val.toInt());
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Algorithm: K-Means++ Initialization • Euclidean Distance Metric',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Launch Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: config.selectedAttributes.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnalysisProgressScreen(dataset: activeDataset),
                              ),
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Clustering Analysis'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
