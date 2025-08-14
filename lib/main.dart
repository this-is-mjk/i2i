import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i2i/components/common_button.dart';
import 'package:i2i/database/result_database.dart';
import 'package:i2i/screens/quiz_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../screens/settings_screen.dart'; // Import the settings screen

// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primaryColor: Colors.black,
//   scaffoldBackgroundColor: Colors.white,
//   cardColor: Colors.white,
//   textTheme: GoogleFonts.robotoTextTheme().copyWith(
//     titleLarge: TextStyle(
//       fontSize: 20.0,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     ),
//     bodyMedium: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
//   ),
//   inputDecorationTheme: InputDecorationTheme(
//     filled: true,
//     fillColor: Colors.grey[200],
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(12.0),
//       borderSide: BorderSide.none,
//     ),
//   ),
//   iconTheme: IconThemeData(color: Colors.black),
//   chipTheme: ChipThemeData(
//     backgroundColor: Colors.grey[200]!,
//     labelStyle: TextStyle(color: Colors.black),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
//       elevation: 2.0,
//       padding: EdgeInsets.all(20),
//     ),
//   ),
//   textButtonTheme: TextButtonThemeData(
//     style: TextButton.styleFrom(
//       foregroundColor: Colors.black,
//       padding: EdgeInsets.all(20),
//     ),
//   ),
//   floatingActionButtonTheme: FloatingActionButtonThemeData(
//     backgroundColor: Colors.black,
//     foregroundColor: Colors.white,
//     elevation: 2.0,
//   ),
//   appBarTheme: AppBarTheme(
//     backgroundColor: Colors.black,
//     foregroundColor: Colors.white,
//     elevation: 2.0,
//   ),
// );

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey[900],
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[850],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
  ),
  iconTheme: IconThemeData(color: Colors.white),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[800]!,
    labelStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      elevation: 4.0,
      padding: EdgeInsets.all(20),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(20),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 4.0,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 4.0, // gives actual elevation to AppBar
    shadowColor: Colors.white.withValues(
      alpha: .6,
    ), // white shadow glow underneath
    titleTextStyle: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.white, // no text shadow
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.grey[850],
    contentTextStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 6,
  ),
);

void runTest() {
  return;
}

void runBaseLine(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const QuizScreen()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseDir = await getApplicationSupportDirectory();
  databaseDir.create(recursive: true);
  final path = join(databaseDir.path, 'baseline_results.db');

  final database = await $FloorAppDatabase.databaseBuilder(path).build();

  final resultDao = database.resultDao;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I2I',
      theme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'I2I'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final animationWidget = Flexible(
      flex: 4,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: isMobile ? 0.8 : 1,
          child: AspectRatio(
            aspectRatio: 1,
            child: Lottie.asset('assets/animations/home.json'),
          ),
        ),
      ),
    );

    final buttonWidget = Flexible(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 2, 10, 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Let\'s learn about emotions',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.0),
            CommonButton(
              onPressed: runTest,
              text: 'Intervention',
              isOutlined: true,
            ),
            SizedBox(height: 15.0),
            CommonButton(onPressed: () => runBaseLine(context), text: 'Test'),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              height: isMobile ? constraints.maxHeight : 500,
              width: isMobile ? double.infinity : 700,
              padding: isMobile ? EdgeInsets.zero : EdgeInsets.all(16),
              decoration:
                  !isMobile
                      ? BoxDecoration(borderRadius: BorderRadius.circular(12.0))
                      : null,
              child:
                  isMobile
                      ? Column(children: [animationWidget, buttonWidget])
                      : Row(children: [animationWidget, buttonWidget]),
            ),
          );
        },
      ),
    );
  }
}
