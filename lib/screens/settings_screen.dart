import 'package:flutter/material.dart';
import 'package:i2i/database/result.dart';
import 'package:i2i/database/result_database.dart';
import 'package:path/path.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double interventionlineTime = 2.0;
  String imagePattern = 'ABAB';
  int level = 1;
  int numImages = 4;
  bool smartDist = true;
  String userName = '';
  String userId = '';
  int baselineQuestionNumber = 5;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<String> getExportPath() async {
    Directory? exportDir = await getDownloadsDirectory();

    if (exportDir?.path == null) {
      throw UnsupportedError("Export not supported on this platform.");
    }

    return exportDir!.path;
  }

  // Function to load saved values from SharedPreferences
  Future<void> _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      interventionlineTime = prefs.getDouble("interventionlineTime") ?? 2.0;
      imagePattern = prefs.getString("imagePattern") ?? 'ABAB';
      level = prefs.getInt("level") ?? 1;
      numImages = prefs.getInt("numImages") ?? 4;
      smartDist = prefs.getBool("smartDist") ?? true;
      userName = prefs.getString("userName") ?? '';
      userId = prefs.getString("userId") ?? '';
      baselineQuestionNumber = prefs.getInt("baselineQuestionNumber") ?? 5;
    });
  }

  // Function to save a specific value to SharedPreferences
  Future<void> _saveValue(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('User Details'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('Name'),
                value: Text(userName.isNotEmpty ? userName : 'Not set'),
                onPressed: (_) async {
                  final controller = TextEditingController(text: userName);
                  final result = await showDialog<String>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Enter Name'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Your Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _saveValue('userName', controller.text);
                                Navigator.pop(ctx, controller.text);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                  );
                  if (result != null) setState(() => userName = result);
                },
              ),
              SettingsTile.navigation(
                title: const Text('ID'),
                value: Text(userId.isNotEmpty ? userId : 'Not set'),
                onPressed: (_) async {
                  final controller = TextEditingController(text: userId);
                  final result = await showDialog<String>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Enter ID'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Your ID',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _saveValue('userId', controller.text);
                                Navigator.pop(ctx, controller.text);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                  );
                  if (result != null) setState(() => userId = result);
                },
              ),

              SettingsTile.navigation(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete User Data'),
                onPressed: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                            'Are you sure you want to delete all data of the user? This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete All',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmed != true) return;
                  try {
                    final databaseDir = await getApplicationSupportDirectory();
                    databaseDir.create(recursive: true);
                    final dbpath = join(
                      databaseDir.path,
                      'baseline_results.db',
                    );

                    final database =
                        await $FloorAppDatabase.databaseBuilder(dbpath).build();

                    final resultDao = database.resultDao;

                    await resultDao.deleteAllResultsForUser(userId);

                    // Notify user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All data for the user has been deleted.',
                        ),
                        backgroundColor: Colors.green[300],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting data: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: const Text('Export User Data as CSV'),
                onPressed: (_) async {
                  try {
                    final databaseDir = await getApplicationSupportDirectory();
                    databaseDir.create(recursive: true);
                    final dbpath = join(
                      databaseDir.path,
                      'baseline_results.db',
                    );

                    final database =
                        await $FloorAppDatabase.databaseBuilder(dbpath).build();

                    final resultDao = database.resultDao;

                    final results = await resultDao.findAllResultsForUser(
                      userId,
                    );

                    final dataList = [
                      [
                        "id",
                        "userId",
                        "userName",
                        "answered",
                        "correctAnswer",
                        "level",
                        "isCorrect",
                        "timeTaken",
                      ],
                    ];

                    for (Result e in results) {
                      dataList.add([
                        e.id.toString(),
                        e.userId.toString(),
                        e.userName.toString(),
                        e.answered.toString(),
                        e.correctAnswer.toString(),
                        e.level.toString(),
                        e.isCorrect.toString(),
                        e.timeTaken.toString(),
                      ]);
                    }

                    // Convert to CSV string
                    String csvData = const ListToCsvConverter().convert(
                      dataList,
                    );

                    // Request permissions
                    if (Platform.isAndroid || Platform.isIOS) {
                      var status = await Permission.storage.request();
                      if (!status.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Storage permission denied'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    }
                    // Get Downloads directory
                    final exportDir = await getExportPath();
                    final exportFileName = join(
                      exportDir,
                      'quiz_results_export.csv',
                    );
                    final exportFile = File(exportFileName);

                    // Write the file
                    await exportFile.writeAsString(csvData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exported to ${exportFile.path}'),
                        backgroundColor: Colors.green[300],
                      ),
                    );
                  } catch (e) {
                    debugPrint('Error exporting data: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to export data'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Intervention settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('Per Image Time'),
                value: Text('${interventionlineTime.toStringAsFixed(2)} sec'),
                onPressed: (_) async {
                  double? result = await showDialog<double>(
                    context: context,
                    builder: (context) {
                      TextEditingController controller = TextEditingController(
                        text: interventionlineTime.toStringAsFixed(2),
                      );
                      String? errorText;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Set Time (sec)'),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Time in seconds',
                                errorText: errorText,
                                hintText: 'Enter a value between 0 and 10',
                              ),
                              onChanged: (value) {
                                final val = double.tryParse(value);
                                if (val == null || val < 0 || val > 10) {
                                  setState(() {
                                    errorText =
                                        'Please enter a number between 0 and 10';
                                  });
                                } else {
                                  setState(() {
                                    errorText = null;
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final val = double.tryParse(controller.text);
                                  if (val != null && val > 0 && val <= 10) {
                                    _saveValue("interventionlineTime", val);
                                    Navigator.pop(context, val);
                                  } else {
                                    setState(() {
                                      errorText =
                                          'Please enter a valid number between 0 and 10';
                                    });
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );

                  if (result != null)
                    setState(() => interventionlineTime = result);
                },
              ),

              SettingsTile.navigation(
                title: const Text('Image Pattern'),
                value: Text(imagePattern),
                onPressed: (_) async {
                  String? result = await showDialog(
                    context: context,
                    builder: (context) {
                      String selected = imagePattern;
                      return AlertDialog(
                        title: const Text('Choose Pattern'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              ['ABAB', 'AABB', 'ABBA']
                                  .map(
                                    (e) => RadioListTile(
                                      title: Text(e),
                                      value: e,
                                      groupValue: selected,
                                      onChanged: (val) {
                                        setState(() => selected = val!);
                                        Navigator.pop(context, val);
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    },
                  );
                  if (result != null) {
                    setState(() => imagePattern = result);
                    _saveValue("imagePattern", result);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Baseline Survey'),
            tiles: <SettingsTile>[
              // SettingsTile.switchTile(
              //   title: const Text('Smart Distribution'),
              //   initialValue: smartDist,
              //   onToggle: (val) {
              //     setState(() => smartDist = val);
              //     _saveValue("smartDist", val);
              //   },
              // ),
              SettingsTile.navigation(
                title: const Text('Level'),
                value: Text(level.toString()),
                onPressed: (_) async {
                  int? result = await showDialog(
                    context: context,
                    builder: (context) {
                      int selectedLevel = level;
                      return AlertDialog(
                        title: const Text('Choose level'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              [1, 2, 3]
                                  .map(
                                    (e) => RadioListTile(
                                      title: Text(e.toString()),
                                      value: e,
                                      groupValue: selectedLevel,
                                      onChanged: (val) {
                                        setState(() => (selectedLevel = val!));
                                        Navigator.pop(context, val);
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    },
                  );
                  if (result != null) {
                    setState(() => level = result);
                    _saveValue("level", result);
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('Number of Images'),
                value: Text(baselineQuestionNumber.toStringAsFixed(0)),
                onPressed: (_) async {
                  int? result = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      TextEditingController controller = TextEditingController(
                        text: baselineQuestionNumber.toStringAsFixed(0),
                      );
                      String? errorText;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Number of Images'),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: false,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'to show in the baseline survey',
                                errorText: errorText,
                                hintText: 'Enter a value between 1 and 35',
                              ),
                              onChanged: (value) {
                                final val = int.tryParse(value);
                                if (val == null || val < 1 || val > 35) {
                                  setState(() {
                                    errorText =
                                        'Please enter a number between 1 and 35';
                                  });
                                } else {
                                  setState(() {
                                    errorText = null;
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final val = int.tryParse(controller.text);
                                  if (val != null && val >= 1 && val <= 34) {
                                    _saveValue("baselineQuestionNumber", val);
                                    Navigator.pop(context, val);
                                  } else {
                                    setState(() {
                                      errorText =
                                          'Please enter a valid number between 1 and 34';
                                    });
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (result != null) {
                    setState(() => baselineQuestionNumber = result);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Data Management'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete All Data'),
                onPressed: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                            'Are you sure you want to delete all data? This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete All',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmed != true) return;
                  try {
                    // Delete all data from your SQLite tables
                    final databaseDir = await getApplicationSupportDirectory();
                    databaseDir.create(recursive: true);
                    final dbpath = join(
                      databaseDir.path,
                      'baseline_results.db',
                    );

                    final database =
                        await $FloorAppDatabase.databaseBuilder(dbpath).build();

                    final resultDao = database.resultDao;

                    await resultDao.deleteAllResults();

                    // Notify user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('All data has been deleted.'),
                        backgroundColor: Colors.green[300],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting data: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: const Text('Export All Data as CSV'),
                onPressed: (_) async {
                  try {
                    final databaseDir = await getApplicationSupportDirectory();
                    databaseDir.create(recursive: true);
                    final dbpath = join(
                      databaseDir.path,
                      'baseline_results.db',
                    );

                    final database =
                        await $FloorAppDatabase.databaseBuilder(dbpath).build();

                    final resultDao = database.resultDao;

                    final results = await resultDao.findAllResults();

                    final dataList = [
                      [
                        "id",
                        "userId",
                        "userName",
                        "answered",
                        "correctAnswer",
                        "level",
                        "isCorrect",
                        "timeTaken",
                      ],
                    ];

                    for (Result e in results) {
                      dataList.add([
                        e.id.toString(),
                        e.userId.toString(),
                        e.userName.toString(),
                        e.answered.toString(),
                        e.correctAnswer.toString(),
                        e.level.toString(),
                        e.isCorrect.toString(),
                        e.timeTaken.toString(),
                      ]);
                    }

                    // Convert to CSV string
                    String csvData = const ListToCsvConverter().convert(
                      dataList,
                    );

                    // Request permissions
                    if (Platform.isAndroid || Platform.isIOS) {
                      var status = await Permission.storage.request();
                      if (!status.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Storage permission denied'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    }
                    // Get Downloads directory
                    final exportDir = await getExportPath();
                    final exportFileName = join(
                      exportDir,
                      'quiz_results_export.csv',
                    );
                    final exportFile = File(exportFileName);

                    // Write the file
                    await exportFile.writeAsString(csvData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exported to ${exportFile.path}'),
                        backgroundColor: Colors.green[300],
                      ),
                    );
                  } catch (e) {
                    debugPrint('Error exporting data: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to export data'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
