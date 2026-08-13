import 'package:yaml/yaml.dart';

/// Coverage floor for one package.
class PackageThreshold {
  const PackageThreshold({
    required this.name,
    required this.path,
    required this.min,
    required this.exclude,
  });

  /// Key used in `coverage_thresholds.yaml`.
  final String name;

  /// Path to the package, relative to the repo root.
  final String path;

  /// Minimum line coverage percentage, as a whole number.
  final int min;

  /// Exclusion patterns specific to this package.
  final List<String> exclude;
}

/// Typed view over `coverage_thresholds.yaml`.
class ThresholdConfig {
  const ThresholdConfig({
    required this.defaultExclude,
    required this.packages,
  });

  factory ThresholdConfig.parse(String yamlSource) {
    final doc = loadYaml(yamlSource);
    if (doc is! YamlMap) {
      return const ThresholdConfig(defaultExclude: [], packages: []);
    }

    final defaults = doc['defaults'];
    final defaultExclude = <String>[
      if (defaults is YamlMap && defaults['exclude'] is YamlList)
        ...(defaults['exclude'] as YamlList).map((e) => e.toString()),
    ];

    final packages = <PackageThreshold>[];
    final rawPackages = doc['packages'];
    if (rawPackages is YamlMap) {
      rawPackages.forEach((key, value) {
        if (value is! YamlMap) return;
        packages.add(
          PackageThreshold(
            name: key.toString(),
            path: value['path'].toString(),
            min: int.parse(value['min'].toString()),
            exclude: <String>[
              if (value['exclude'] is YamlList)
                ...(value['exclude'] as YamlList).map((e) => e.toString()),
            ],
          ),
        );
      });
    }

    return ThresholdConfig(
      defaultExclude: defaultExclude,
      packages: packages,
    );
  }

  final List<String> defaultExclude;
  final List<PackageThreshold> packages;

  /// Every pattern that applies to [package]: the global defaults plus its own.
  List<String> effectiveExclude(PackageThreshold package) =>
      [...defaultExclude, ...package.exclude];
}
