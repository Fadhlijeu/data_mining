import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/clustering_provider.dart';
import '../../providers/dataset_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../datasets/dataset_preview_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('ClusterLab Workspace'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'ClusterLab',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.hub, color: AppColors.primary, size: 36),
                children: const [
                  Text(
                    'Domain-agnostic Data Mining and Clustering workspace for CSV datasets. Built with Flutter, K-Means Engine, and fl_chart.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<DatasetProvider, ClusteringProvider>(
        builder: (context, datasetProv, clusterProv, _) {
          final datasets = datasetProv.datasets;
          final totalRecords = datasets.fold<int>(0, (sum, d) => sum + d.rowCount);
          final history = clusterProv.history;

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger refresh state
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero / Welcome Banner
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Data Mining Workspace',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Explore Data & Uncover Hidden Clusters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Import any numerical CSV dataset, inspect attributes, configure K-Means clustering, and visualize 2D projections.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final success = await datasetProv.importCsvFromFile();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dataset imported successfully!')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.file_upload_outlined, size: 18),
                              label: const Text('Import CSV'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                if (datasetProv.activeDataset != null) {
                                  clusterProv.initializeConfigForDataset(datasetProv.activeDataset!);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Navigate to "Analyze" tab to configure experiment.')),
                                );
                              },
                              icon: const Icon(Icons.play_arrow_outlined, size: 18),
                              label: const Text('New Analysis'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // KPI Metrics
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: MetricCard(
                                    title: 'Available Datasets',
                                    value: '${datasets.length}',
                                    subtitle: 'CSV Datasets loaded',
                                    icon: Icons.table_chart_outlined,
                                    iconColor: AppColors.primary,
                                    iconBgColor: AppColors.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricCard(
                                    title: 'Total Records',
                                    value: '$totalRecords',
                                    subtitle: 'Observations indexed',
                                    icon: Icons.data_usage_outlined,
                                    iconColor: AppColors.success,
                                    iconBgColor: AppColors.successLight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricCard(
                                    title: 'Experiments Run',
                                    value: '${history.length}',
                                    subtitle: 'Clustering executions',
                                    icon: Icons.science_outlined,
                                    iconColor: AppColors.warning,
                                    iconBgColor: AppColors.warningLight,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                MetricCard(
                                  title: 'Available Datasets',
                                  value: '${datasets.length}',
                                  subtitle: 'CSV Datasets loaded',
                                  icon: Icons.table_chart_outlined,
                                  iconColor: AppColors.primary,
                                  iconBgColor: AppColors.primaryLight,
                                ),
                                const SizedBox(height: 10),
                                MetricCard(
                                  title: 'Total Records',
                                  value: '$totalRecords',
                                  subtitle: 'Observations indexed',
                                  icon: Icons.data_usage_outlined,
                                  iconColor: AppColors.success,
                                  iconBgColor: AppColors.successLight,
                                ),
                                const SizedBox(height: 10),
                                MetricCard(
                                  title: 'Experiments Run',
                                  value: '${history.length}',
                                  subtitle: 'Clustering executions',
                                  icon: Icons.science_outlined,
                                  iconColor: AppColors.warning,
                                  iconBgColor: AppColors.warningLight,
                                ),
                              ],
                            );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Datasets Summary
                  SectionHeader(
                    title: 'Active Datasets',
                    subtitle: 'Select or inspect available CSV datasets',
                    action: TextButton.icon(
                      onPressed: () {
                        // Switch to datasets tab
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                    ),
                  ),

                  if (datasets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No datasets imported yet. Click "Import CSV" to get started.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: datasets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ds = datasets[index];
                        final isSelected = datasetProv.activeDataset?.id == ds.id;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight : AppColors.surfaceSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.insert_drive_file_outlined,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ds.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (ds.source == 'Sample Data')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Demo Data',
                                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${ds.rowCount} rows • ${ds.columnCount} columns (${ds.numericalColumns.length} numerical)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                              onPressed: () {
                                datasetProv.setActiveDataset(ds);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DatasetPreviewScreen(dataset: ds),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              datasetProv.setActiveDataset(ds);
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Recent Experiments
                  const SectionHeader(
                    title: 'Recent Experiments',
                    subtitle: 'Latest K-Means clustering runs',
                  ),

                  if (history.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.science_outlined, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          const Text(
                            'No experiments executed yet.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Go to the Analyze tab to configure and run your first clustering analysis.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.take(3).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.datasetName} (K=${item.clusterCount})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Silhouette Score: ${item.silhouetteScore} • WCSS: ${item.wcss}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                                onPressed: () {
                                  clusterProv.selectResultFromHistory(item);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
