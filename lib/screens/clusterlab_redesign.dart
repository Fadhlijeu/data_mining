import 'package:flutter/material.dart';

import '../core/widgets/basics.dart';

/// ClusterLab Modern Clean UI Layer (Supporting Light & Dark Theme)

class ClusterLabDataset {
  const ClusterLabDataset({
    required this.id,
    required this.name,
    required this.recordCount,
    required this.attributeNames,
    this.isDemo = false,
    this.updatedLabel = 'Imported',
  });

  final String id;
  final String name;
  final int recordCount;
  final List<String> attributeNames;
  final bool isDemo;
  final String updatedLabel;

  int get attributeCount => attributeNames.length;
}

class ClusterLabExperiment {
  const ClusterLabExperiment({
    required this.id,
    required this.name,
    required this.algorithm,
    required this.clusterCount,
    required this.recordCount,
    required this.dateLabel,
    required this.status,
    this.isDemo = false,
  });

  final String id;
  final String name;
  final String algorithm;
  final int clusterCount;
  final int recordCount;
  final String dateLabel;
  final String status;
  final bool isDemo;
}

class ClusterLabAnalysisRequest {
  const ClusterLabAnalysisRequest({
    required this.datasetId,
    required this.featureNames,
    required this.scaling,
    required this.clusterCount,
    required this.algorithm,
  });

  final String datasetId;
  final List<String> featureNames;
  final String scaling;
  final int clusterCount;
  final String algorithm;
}

class ClusterLabRedesign extends StatefulWidget {
  const ClusterLabRedesign({
    super.key,
    this.datasets = const [],
    this.experiments = const [],
    this.onImportCsv,
    this.onRunAnalysis,
    this.onOpenDataset,
    this.onOpenExperiment,
    this.onHelp,
  });

  final List<ClusterLabDataset> datasets;
  final List<ClusterLabExperiment> experiments;
  final VoidCallback? onImportCsv;
  final Future<void> Function(ClusterLabAnalysisRequest request)? onRunAnalysis;
  final ValueChanged<ClusterLabDataset>? onOpenDataset;
  final ValueChanged<ClusterLabExperiment>? onOpenExperiment;
  final VoidCallback? onHelp;

  @override
  State<ClusterLabRedesign> createState() => _ClusterLabRedesignState();
}

class _ClusterLabRedesignState extends State<ClusterLabRedesign> {
  int _tabIndex = 0;
  String? _selectedDatasetId;
  final Set<String> _selectedFeatures = <String>{};
  String _scaling = 'Min-Max';
  int _clusterCount = 3;
  bool _isRunning = false;
  String _datasetSearch = '';

  ClusterLabDataset? get _selectedDataset {
    final data = widget.datasets;
    if (data.isEmpty) return null;
    for (final item in data) {
      if (item.id == _selectedDatasetId) return item;
    }
    return data.first;
  }

  @override
  void initState() {
    super.initState();
    _syncSelectedDataset();
  }

  @override
  void didUpdateWidget(covariant ClusterLabRedesign oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasets != widget.datasets) {
      _syncSelectedDataset();
    }
  }

  void _syncSelectedDataset() {
    final data = widget.datasets;
    if (data.isEmpty) {
      _selectedDatasetId = null;
      _selectedFeatures.clear();
      return;
    }
    final exists = data.any((item) => item.id == _selectedDatasetId);
    if (!exists) _selectedDatasetId = data.first.id;
    final selected = data.firstWhere((item) => item.id == _selectedDatasetId);
    if (_selectedFeatures.isEmpty) {
      _selectedFeatures
        ..removeWhere((feature) => !selected.attributeNames.contains(feature))
        ..addAll(selected.attributeNames);
    }
  }

  Future<void> _importCsv() async {
    final handler = widget.onImportCsv;
    if (handler != null) {
      handler();
    }
  }

  Future<void> _runAnalysis() async {
    final dataset = _selectedDataset;
    if (dataset == null) return;
    if (_selectedFeatures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one feature for clustering.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final handler = widget.onRunAnalysis;
    if (handler == null) return;

    setState(() => _isRunning = true);
    try {
      await handler(
        ClusterLabAnalysisRequest(
          datasetId: dataset.id,
          featureNames: _selectedFeatures.toList(growable: false),
          scaling: _scaling,
          clusterCount: _clusterCount,
          algorithm: 'K-Means',
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $error'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pages = <Widget>[
      _OverviewScreen(
        datasets: widget.datasets,
        experiments: widget.experiments,
        onImport: _importCsv,
        onNewAnalysis: () => setState(() => _tabIndex = 2),
        onViewAllDatasets: () => setState(() => _tabIndex = 1),
        onViewHistory: () => setState(() => _tabIndex = 3),
        onOpenDataset: (item) {
          widget.onOpenDataset?.call(item);
        },
        onOpenExperiment: (item) {
          widget.onOpenExperiment?.call(item);
        },
      ),
      _DatasetsScreen(
        datasets: widget.datasets,
        search: _datasetSearch,
        onSearchChanged: (value) => setState(() => _datasetSearch = value),
        onImport: _importCsv,
        onOpen: (item) => widget.onOpenDataset?.call(item),
      ),
      _AnalyzeScreen(
        datasets: widget.datasets,
        selectedDataset: _selectedDataset,
        selectedFeatureNames: _selectedFeatures,
        scaling: _scaling,
        clusterCount: _clusterCount,
        isRunning: _isRunning,
        onDatasetChanged: (value) {
          setState(() {
            _selectedDatasetId = value;
            _selectedFeatures.clear();
            final selected = _selectedDataset;
            if (selected != null) {
              _selectedFeatures.addAll(selected.attributeNames);
            }
          });
        },
        onFeatureToggled: (feature, value) {
          setState(() {
            if (value) {
              _selectedFeatures.add(feature);
            } else {
              _selectedFeatures.remove(feature);
            }
          });
        },
        onSelectAllFeatures: () {
          final selected = _selectedDataset;
          if (selected != null) {
            setState(() {
              _selectedFeatures.clear();
              _selectedFeatures.addAll(selected.attributeNames);
            });
          }
        },
        onClearFeatures: () {
          setState(() {
            _selectedFeatures.clear();
          });
        },
        onScalingChanged: (value) => setState(() => _scaling = value),
        onClusterCountChanged: (value) => setState(() => _clusterCount = value),
        onRun: _runAnalysis,
        onImport: _importCsv,
      ),
      _HistoryScreen(
        experiments: widget.experiments,
        onOpen: (item) => widget.onOpenExperiment?.call(item),
        onStartNewAnalysis: () => setState(() => _tabIndex = 2),
      ),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(onHelp: widget.onHelp),
            Expanded(
              child: IndexedStack(index: _tabIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
      ),
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen({
    required this.datasets,
    required this.experiments,
    required this.onImport,
    required this.onNewAnalysis,
    required this.onViewAllDatasets,
    required this.onViewHistory,
    required this.onOpenDataset,
    required this.onOpenExperiment,
  });

  final List<ClusterLabDataset> datasets;
  final List<ClusterLabExperiment> experiments;
  final VoidCallback onImport;
  final VoidCallback onNewAnalysis;
  final VoidCallback onViewAllDatasets;
  final VoidCallback onViewHistory;
  final ValueChanged<ClusterLabDataset> onOpenDataset;
  final ValueChanged<ClusterLabExperiment> onOpenExperiment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalRecords = datasets.fold<int>(0, (sum, item) => sum + item.recordCount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Import CSV datasets to begin clustering analysis.',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                'Import CSV',
                icon: Icons.file_upload_outlined,
                onTap: onImport,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                'New Analysis',
                icon: Icons.play_arrow_rounded,
                onTap: onNewAnalysis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Inline Integrated Stats
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: StatDisplay(
                  value: datasets.length,
                  label: 'DATASETS',
                  icon: Icons.table_chart_outlined,
                ),
              ),
              Container(width: 1, height: 36, color: cs.outlineVariant),
              Expanded(
                child: StatDisplay(
                  value: totalRecords,
                  label: 'RECORDS',
                  icon: Icons.data_usage_outlined,
                ),
              ),
              Container(width: 1, height: 36, color: cs.outlineVariant),
              Expanded(
                child: StatDisplay(
                  value: experiments.length,
                  label: 'EXPERIMENTS',
                  icon: Icons.hub_outlined,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Active Datasets Section
        SectionHeading(
          title: 'Active Datasets',
          actionLabel: datasets.isNotEmpty ? 'View All' : null,
          onAction: datasets.isNotEmpty ? onViewAllDatasets : null,
        ),
        const SizedBox(height: 12),
        if (datasets.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.drive_folder_upload_outlined, size: 36, color: cs.onSurfaceVariant),
                const SizedBox(height: 10),
                Text(
                  'No Datasets Imported',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Import a CSV dataset to view attributes, explore records, and configure clustering.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  'Import CSV File',
                  icon: Icons.file_upload_outlined,
                  onTap: onImport,
                ),
              ],
            ),
          )
        else
          ...datasets.take(3).map((item) {
            return FlushListRow(
              title: item.name,
              subtitle: '${_formatCount(item.recordCount)} records  •  ${item.attributeCount} attributes',
              badgeText: item.isDemo ? 'DEMO' : null,
              icon: Icons.insert_drive_file_outlined,
              onTap: () => onOpenDataset(item),
            );
          }),

        const SizedBox(height: 28),

        // Recent Experiments Section
        SectionHeading(
          title: 'Recent Experiments',
          actionLabel: experiments.isNotEmpty ? 'View History' : null,
          onAction: experiments.isNotEmpty ? onViewHistory : null,
        ),
        const SizedBox(height: 12),
        if (experiments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.scatter_plot_outlined, color: cs.onSurfaceVariant, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No completed clustering runs recorded yet.',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else
          ...experiments.take(3).map((item) {
            return FlushListRow(
              title: item.name,
              subtitle: '${item.algorithm}  •  K=${item.clusterCount}  •  ${_formatCount(item.recordCount)} records',
              badgeText: item.isDemo ? 'DEMO' : item.status.toUpperCase(),
              icon: Icons.scatter_plot_outlined,
              onTap: () => onOpenExperiment(item),
            );
          }),
      ],
    );
  }
}

class _DatasetsScreen extends StatelessWidget {
  const _DatasetsScreen({
    required this.datasets,
    required this.search,
    required this.onSearchChanged,
    required this.onImport,
    required this.onOpen,
  });

  final List<ClusterLabDataset> datasets;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onImport;
  final ValueChanged<ClusterLabDataset> onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = datasets
        .where((item) => item.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datasets Manager',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Inspect attributes and manage imported CSV data.',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onImport,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Import', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onSearchChanged,
          style: TextStyle(fontSize: 14, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Search loaded datasets...',
            hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            prefixIcon: Icon(Icons.search, size: 18, color: cs.onSurfaceVariant),
            isDense: true,
            filled: true,
            fillColor: cs.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${filtered.length} ${filtered.length == 1 ? 'dataset' : 'datasets'} available',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const Spacer(),
            Text('CSV FORMAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.insert_drive_file_outlined, size: 36, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(
                  search.isEmpty ? 'No Datasets Imported' : 'No Matching Datasets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  search.isEmpty
                      ? 'Import a CSV file to begin analysis and dataset exploration.'
                      : 'Try adjusting your search query.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                if (search.isEmpty) ...[
                  const SizedBox(height: 20),
                  PrimaryButton('Import CSV File', icon: Icons.file_upload_outlined, onTap: onImport),
                ],
              ],
            ),
          )
        else
          ...filtered.map((item) => FlushListRow(
                title: item.name,
                subtitle: '${_formatCount(item.recordCount)} records  •  ${item.attributeCount} attributes',
                badgeText: item.isDemo ? 'DEMO' : null,
                icon: Icons.insert_drive_file_outlined,
                onTap: () => onOpen(item),
              )),
      ],
    );
  }
}

class _AnalyzeScreen extends StatelessWidget {
  const _AnalyzeScreen({
    required this.datasets,
    required this.selectedDataset,
    required this.selectedFeatureNames,
    required this.scaling,
    required this.clusterCount,
    required this.isRunning,
    required this.onDatasetChanged,
    required this.onFeatureToggled,
    required this.onSelectAllFeatures,
    required this.onClearFeatures,
    required this.onScalingChanged,
    required this.onClusterCountChanged,
    required this.onRun,
    required this.onImport,
  });

  final List<ClusterLabDataset> datasets;
  final ClusterLabDataset? selectedDataset;
  final Set<String> selectedFeatureNames;
  final String scaling;
  final int clusterCount;
  final bool isRunning;
  final ValueChanged<String?> onDatasetChanged;
  final void Function(String feature, bool selected) onFeatureToggled;
  final VoidCallback onSelectAllFeatures;
  final VoidCallback onClearFeatures;
  final ValueChanged<String> onScalingChanged;
  final ValueChanged<int> onClusterCountChanged;
  final VoidCallback onRun;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dataset = selectedDataset;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              Text(
                'Configure Analysis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Tune clustering parameters, feature dimensions, and normalization.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Step 1: Dataset Selection Card
              _StepCard(
                stepNumber: '01',
                title: 'Dataset Selection',
                badgeText: dataset != null ? '${_formatCount(dataset.recordCount)} rows' : null,
                child: datasets.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No datasets available. Please import a CSV dataset first.', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          SecondaryButton('Import CSV File', icon: Icons.file_upload_outlined, onTap: onImport),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: dataset?.id,
                            isExpanded: true,
                            dropdownColor: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            icon: Icon(Icons.unfold_more_rounded, color: cs.onSurfaceVariant),
                            items: datasets.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Row(
                                  children: [
                                    Icon(Icons.table_chart_outlined, size: 18, color: cs.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${item.attributeCount} attrs',
                                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: onDatasetChanged,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Step 2: Feature Matrix Selection Card
              _StepCard(
                stepNumber: '02',
                title: 'Feature Matrix',
                badgeText: '${selectedFeatureNames.length} Selected',
                headerAction: dataset != null && dataset.attributeNames.isNotEmpty
                    ? GestureDetector(
                        onTap: selectedFeatureNames.length == dataset.attributeNames.length
                            ? onClearFeatures
                            : onSelectAllFeatures,
                        child: Text(
                          selectedFeatureNames.length == dataset.attributeNames.length ? 'Clear All' : 'Select All',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                      )
                    : null,
                child: dataset == null
                    ? Text('Select a dataset first.', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))
                    : dataset.attributeNames.isEmpty
                        ? Text('No numerical attributes available in dataset.', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dataset.attributeNames.map((feature) {
                              final selected = selectedFeatureNames.contains(feature);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: selected ? cs.primaryContainer.withValues(alpha: 0.4) : cs.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: CheckboxListTile(
                                    value: selected,
                                    activeColor: cs.primary,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    title: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    secondary: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('NUMERIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
                                    ),
                                    onChanged: (val) => onFeatureToggled(feature, val ?? false),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ),

              const SizedBox(height: 16),

              // Step 3: Normalization Preprocessing
              _StepCard(
                stepNumber: '03',
                title: 'Preprocessing Scaling',
                child: Column(
                  children: [
                    _ScalingOptionCard(
                      title: 'Min–Max Scaling',
                      subtitle: 'Rescales attributes to [0, 1] interval. Recommended for K-Means.',
                      isSelected: scaling == 'Min-Max',
                      onTap: () => onScalingChanged('Min-Max'),
                    ),
                    const SizedBox(height: 8),
                    _ScalingOptionCard(
                      title: 'Z-Score Standardization',
                      subtitle: 'Standardizes features to zero-mean and unit-variance (μ=0, σ=1).',
                      isSelected: scaling == 'Z-score',
                      onTap: () => onScalingChanged('Z-score'),
                    ),
                    const SizedBox(height: 8),
                    _ScalingOptionCard(
                      title: 'Raw / Unscaled Values',
                      subtitle: 'Preserves original attribute magnitude values without rescaling.',
                      isSelected: scaling == 'Raw',
                      onTap: () => onScalingChanged('Raw'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Step 4: Cluster Count K Tuning Card
              _StepCard(
                stepNumber: '04',
                title: 'Algorithm & Clusters (K)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.hub_outlined, color: cs.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('K-Means++ Engine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface)),
                              Text('Euclidean Distance Metric', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target Clusters (K)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$clusterCount Clusters',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cluster Selector Pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [2, 3, 4, 5, 6, 7, 8].map((kVal) {
                        final isSel = kVal == clusterCount;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              onTap: () => onClusterCountChanged(kVal),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSel ? cs.primary : cs.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? cs.primary : cs.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  '$kVal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? cs.onPrimary : cs.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: PrimaryButton(
              isRunning ? 'Executing K-Means Engine...' : 'Run Clustering Analysis',
              icon: isRunning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
              onTap: (datasets.isEmpty || isRunning) ? () {} : onRun,
            ),
          ),
        ),
      ],
    );
  }
}

/// Clean Step Card Container
class _StepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String? badgeText;
  final Widget? headerAction;
  final Widget child;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    this.badgeText,
    this.headerAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stepNumber,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
              ),
              if (badgeText != null) ...[
                Text(
                  badgeText!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary),
                ),
                const SizedBox(width: 8),
              ],
              if (headerAction != null) headerAction!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Scaling Method Choice Option Card
class _ScalingOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScalingOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer.withValues(alpha: 0.5) : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen({
    required this.experiments,
    required this.onOpen,
    this.onStartNewAnalysis,
  });

  final List<ClusterLabExperiment> experiments;
  final ValueChanged<ClusterLabExperiment> onOpen;
  final VoidCallback? onStartNewAnalysis;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experiment History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: cs.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              'Review previously executed clustering models and results.',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('${experiments.length} runs recorded', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const Spacer(),
            Text('CHRONOLOGICAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: cs.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        if (experiments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 36, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                Text('No Experiments Recorded Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(height: 6),
                Text(
                  'Select a dataset and run clustering to store your first experiment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                if (onStartNewAnalysis != null) ...[
                  const SizedBox(height: 20),
                  PrimaryButton('Configure First Experiment', onTap: onStartNewAnalysis!),
                ],
              ],
            ),
          )
        else
          ...experiments.map((item) => FlushListRow(
                title: item.name,
                subtitle: '${item.algorithm}  •  K=${item.clusterCount}  •  ${_formatCount(item.recordCount)} records',
                badgeText: item.isDemo ? 'DEMO' : item.status.toUpperCase(),
                icon: Icons.scatter_plot_outlined,
                onTap: () => onOpen(item),
              )),
      ],
    );
  }
}

String _formatCount(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
