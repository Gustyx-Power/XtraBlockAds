class AppData {
  final String appName;
  final String packageName;
  final bool isSystemApp;
  bool isChecked;

  AppData({
    required this.appName,
    required this.packageName,
    this.isSystemApp = false,
    this.isChecked = false,
  });
}
