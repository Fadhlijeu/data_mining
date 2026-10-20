import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/clustering_provider.dart';
import 'providers/dataset_provider.dart';
import 'screens/clusterlab_redesign_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClusterLabApp());
}

class ClusterLabApp extends StatelessWidget {
  const ClusterLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatasetProvider()),
        ChangeNotifierProvider(create: (_) => ClusteringProvider()),
      ],
      child: MaterialApp(
        title: 'ClusterLab - Data Mining & Clustering Workspace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme, // Default to White Theme
        themeMode: ThemeMode.light,
        home: const ClusterLabRedesignWrapper(),
      ),
    );
  }
}
