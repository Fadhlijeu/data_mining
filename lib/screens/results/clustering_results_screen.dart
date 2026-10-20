import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/clustering_provider.dart';
import '../../shared/widgets/section_header.dart';

class ClusteringResultsScreen extends StatefulWidget {
  const ClusteringResultsScreen({super.key});

  @override
  State<ClusteringResultsScreen> createState() => _ClusteringResultsScreenState();
}

class _ClusteringResultsScreenState extends State<ClusteringResultsScreen> {
  int? _selectedClusterFilter;
  int _activeTab = 0; // 0: Charts, 1: Centroids, 2: Record Inspector

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clusterProv = Provider.of<ClusteringProvider>(context);
    final result = clusterProv.activeResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clustering Results')),
        body: const Center(child: Text('No result available.')),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Clustering Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Results CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result exported as CSV format.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              'Execution Completed (${result.executionDurationMs} ms)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'K = ${result.config.k} Clusters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dataset: ${result.config.datasetName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Features used: ${result.config.selectedAttributes.join(', ')}',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Key Evaluation Metrics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_graph, color: cs.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Silhouette Score', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${result.silhouetteScore}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.silhouetteScore > 0.5
                              ? 'Strong Separation'
                              : (result.silhouetteScore > 0.25 ? 'Moderate Structure' : 'Weak Structure'),
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bubble_chart_outlined, color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Text('WCSS (Inertia)', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${result.wcss}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${result.iterationsPerformed} Iterations',
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tab navigation selector
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('2D Visualizations'), icon: Icon(Icons.scatter_plot)),
                ButtonSegment(value: 1, label: Text('Centroids Table'), icon: Icon(Icons.table_chart)),
                ButtonSegment(value: 2, label: Text('Records Inspector'), icon: Icon(Icons.list_alt)),
              ],
              selected: {_activeTab},
              onSelectionChanged: (set) {
                setState(() {
                  _activeTab = set.first;
                });
              },
            ),

            const SizedBox(height: 20),

            // Tab 0: Visualizations (Scatter Plot + Cluster Distribution)
            if (_activeTab == 0) ...[
              const SectionHeader(
                title: '2D Scatter Plot Visualization',
                subtitle: 'Data points mapped onto top numerical dimensions colored by cluster',
              ),
              Container(
                height: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ScatterChart(
                        ScatterChartData(
                          scatterSpots: result.dataPoints.map((pt) {
                            final color = AppColors.getClusterColor(pt.clusterId);
                            return ScatterSpot(
                              pt.x,
                              pt.y,
                              dotPainter: FlDotCirclePainter(
                                color: color,
                                radius: 5,
                                strokeWidth: 0,
                              ),
                            );
                          }).toList(),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (val) => FlLine(color: cs.outlineVariant, strokeWidth: 1),
                            getDrawingVerticalLine: (val) => FlLine(color: cs.outlineVariant, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)))),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)))),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cluster Legend Bar
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: result.clusterSummaries.map((csItem) {
                        final color = AppColors.getClusterColor(csItem.clusterId);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(
                              'Cluster ${csItem.clusterId + 1} (${csItem.count} pts)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cluster Distribution Bar Chart
              const SectionHeader(
                title: 'Cluster Distribution',
                subtitle: 'Proportion of observation count per cluster group',
              ),
              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: result.clusterSummaries.fold<double>(0, (m, c) => c.count > m ? c.count.toDouble() : m) * 1.2,
                    barGroups: result.clusterSummaries.map((csItem) {
                      return BarChartGroupData(
                        x: csItem.clusterId,
                        barRods: [
                          BarChartRodData(
                            toY: csItem.count.toDouble(),
                            color: AppColors.getClusterColor(csItem.clusterId),
                            width: 24,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)))),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Cluster ${idx + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.onSurface)),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],

            // Tab 1: Centroids Comparison Table
            if (_activeTab == 1) ...[
              const SectionHeader(
                title: 'Cluster Centroids & Feature Means',
                subtitle: 'Denormalized feature averages calculated for each cluster center',
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(cs.surfaceContainerHigh),
                    columns: [
                      const DataColumn(label: Text('Cluster', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Records', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold))),
                      ...result.config.selectedAttributes.map((attr) {
                        return DataColumn(label: Text(attr, style: const TextStyle(fontWeight: FontWeight.bold)));
                      }),
                    ],
                    rows: result.clusterSummaries.map((csItem) {
                      final color = AppColors.getClusterColor(csItem.clusterId);
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('Cluster ${csItem.clusterId + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          DataCell(Text('${csItem.count}')),
                          DataCell(Text('${csItem.percentage.toStringAsFixed(1)}%')),
                          ...result.config.selectedAttributes.map((attr) {
                            final val = csItem.centroid[attr] ?? 0.0;
                            return DataCell(Text('$val'));
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // Tab 2: Record Inspector Table
            if (_activeTab == 2) ...[
              const SectionHeader(
                title: 'Cluster Record Inspector',
                subtitle: 'Inspect individual records and cluster assignments',
              ),
              // Filter chips
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Clusters'),
                    selected: _selectedClusterFilter == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedClusterFilter = null;
                      });
                    },
                  ),
                  ...result.clusterSummaries.map((csItem) {
                    return ChoiceChip(
                      label: Text('Cluster ${csItem.clusterId + 1}'),
                      selected: _selectedClusterFilter == csItem.clusterId,
                      onSelected: (_) {
                        setState(() {
                          _selectedClusterFilter = csItem.clusterId;
                        });
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(cs.surfaceContainerHigh),
                    columns: [
                      const DataColumn(label: Text('Row #', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Record ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Assigned Cluster', style: TextStyle(fontWeight: FontWeight.bold))),
                      ...result.config.selectedAttributes.map((attr) {
                        return DataColumn(label: Text(attr, style: const TextStyle(fontWeight: FontWeight.bold)));
                      }),
                    ],
                    rows: result.dataPoints
                        .where((pt) => _selectedClusterFilter == null || pt.clusterId == _selectedClusterFilter)
                        .take(100)
                        .map((pt) {
                      final color = AppColors.getClusterColor(pt.clusterId);
                      return DataRow(
                        cells: [
                          DataCell(Text('#${pt.recordIndex}')),
                          DataCell(Text(pt.recordId ?? 'REC-${pt.recordIndex}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Cluster ${pt.clusterId + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
                              ),
                            ),
                          ),
                          ...result.config.selectedAttributes.map((attr) {
                            final val = pt.rawValues[attr];
                            return DataCell(Text(val != null ? val.toString() : '-'));
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
