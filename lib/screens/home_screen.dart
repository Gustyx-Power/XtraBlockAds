import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../models/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AppData> installedApps = [];
  bool selectAll = false; 

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
    _loadSelectedApps(); 
  }

  Future<void> _getInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: false, 
      includeSystemApps: true, 
    );

    setState(() {
      installedApps = apps
          .map((app) => AppData(
                appName: app.appName,
                packageName: app.packageName,
                isSystemApp: app.systemApp,
              ))
          .toList();
    });
  }

  Future<void> _saveSelectedApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedApps = installedApps
        .where((app) => app.isChecked)
        .map((app) => app.packageName)
        .toList();
    await prefs.setStringList('selectedApps', selectedApps);
  }

  Future<void> _loadSelectedApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedApps = prefs.getStringList('selectedApps');
    if (selectedApps != null) {
      setState(() {
        for (var app in installedApps) {
          app.isChecked = selectedApps.contains(app.packageName);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XtraBlocksAds'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: installedApps.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    'Pilih Semua Aplikasi',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: selectAll,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAll = value ?? false;
                      for (var app in installedApps) {
                        app.isChecked = selectAll;
                      }
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: installedApps.length,
                    itemBuilder: (context, index) {
                      final app = installedApps[index];
                      return CheckboxListTile(
                        title: Text(
                          app.appName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: TextStyle(color: Colors.grey),
                        ),
                        value: app.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            app.isChecked = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveSelectedApps();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved')),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.save),
      ),
    );
  }
}
