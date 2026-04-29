abstract class BuildDataHelper {
  Future<BuildInfo?> getBuildData();
}

class BuildInfo {
  BuildInfo({required this.environment, required this.version, required this.buildNumber});

  final String environment, version, buildNumber;
}
