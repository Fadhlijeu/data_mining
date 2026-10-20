import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/dataset_provider.dart';
import '../../shared/widgets/empty_state_view.dart';
import 'dataset_preview_screen.dart';

class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Management'),
        actions: [
          Consumer<DatasetProvider>(
            builder: (context, datasetProv, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ElevatedButton.icon(
                  onPressed: datasetProv.isImporting
                      ? null
                      : () async {
                          final success = await datasetProv.importCsvFromFile();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dataset imported successfully.')),
                            );
                          } else if (datasetProv.importError != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Import error: ${datasetProv.importError}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  icon: datasetProv.isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: const Text('Import CSV'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DatasetProvider>(
        builder: (context, datasetProv, _) {
          final datasets = datasetProv.datasets;

          if (datasets.isEmpty) {
            return EmptyStateView(
              icon: Icons.table_chart_outlined,
              title: 'No Datasets Imported',
              description: 'Import a CSV dataset to start analyzing and clustering data points.',
              buttonText: 'Import CSV File',
              onButtonPressed: () async {
                await datasetProv.importCsvFromFile();
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: datasets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ds = datasets[index];
              final isSelected = datasetProv.activeDataset?.id == ds.id;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.insert_drive_file_outlined,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ds.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (ds.source == 'Sample Data')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Sample Data',
                                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Imported ${ds.importedAt.day}/${ds.importedAt.month}/${ds.importedAt.year} • ${ds.source}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Column attributes overview
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge('${ds.rowCount} Rows', Icons.swap_vert, AppColors.textPrimary),
                          _buildBadge('${ds.columnCount} Columns', Icons.view_column_outlined, AppColors.textPrimary),
                          _buildBadge('${ds.numericalColumns.length} Numerical', Icons.numbers, AppColors.primary),
                          _buildBadge('${ds.categoricalColumns.length} Categorical', Icons.label_outlined, AppColors.textSecondary),
                          if (ds.totalMissingValues > 0)
                            _buildBadge('${ds.totalMissingValues} Missing', Icons.warning_amber_outlined, AppColors.warning),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (ds.source != 'Sample Data')
                            TextButton.icon(
                              onPressed: () {
                                _showDeleteDialog(context, datasetProv, ds.id, ds.name);
                              },
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                            ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              datasetProv.setActiveDataset(ds);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DatasetPreviewScreen(dataset: ds),
                                ),
                              );
                            },
                            icon: const Icon(Icons.table_view_outlined, size: 18),
                            label: const Text('Preview Table'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DatasetProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete dataset "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              provider.deleteDataset(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dataset deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
