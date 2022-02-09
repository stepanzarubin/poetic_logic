import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/app_state.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/help.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/screens/settings.dart';
import 'package:poetic_logic/widgets/home_drawer.dart';
import 'package:poetic_logic/widgets/poetic_preview.dart';
import 'package:poetic_logic/widgets/user_poetic_list.dart';

import 'models/poetic.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Box boxSettings = await Hive.openBox(settingsDb);
  Box boxPoetics = await Hive.openBox(poeticDb);

  if (!boxSettings.containsKey(settingsKey)) {
    /// default settings
    await boxSettings.put(settingsKey, AppState().toJson());

    /// poetic example
    await boxPoetics.add(jsonDecode(beAllOneJson));
  }

  runApp(
    const AppStateWidget(
      child: MyApp(),
    ),
  );
}

class AppStateScope extends InheritedWidget {
  const AppStateScope(
    this.data, {
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final AppState data;

  static AppState of(BuildContext context, {bool rebuild = true}) {
    final AppState? result = rebuild
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.data
        : context.findAncestorWidgetOfExactType<AppStateScope>()!.data;
    assert(result != null, 'No AppSetting found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return data != oldWidget.data;
  }
}

class AppStateWidget extends StatefulWidget {
  const AppStateWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}

class AppStateWidgetState extends State<AppStateWidget> {
  AppState _data = AppState.fromJson(Hive.box(settingsDb).get(settingsKey));

  Future<void> updateFontSize(double fontSize) async {
    if (_data.fontSize != fontSize) {
      _data = _data.copyWith(fontSize: fontSize);
      await _data.save();
      setState(() {});
    }
  }

  Future<void> updateUser(User user) async {
    if (_data.user != user) {
      _data = _data.copyWith(user: user);
      await _data.save();
      setState(() {});
    }
  }

  Future<void> resetToDefaults() async {
    _data = AppState();
    await _data.save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      _data,
      child: widget.child,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final double _fontSize = AppStateScope.of(context).fontSize;
    final double _fontSizeFactor = (_fontSize / Setting.fontSize);
    final double _fontSizeDelta = (_fontSize - Setting.fontSize).abs();

    //MaterialApp materialApp;

    return MaterialApp(
      title: 'Poetic logic',
      theme: ThemeData(
        //scaffoldBackgroundColor: Colors.white70,
        useMaterial3: true,
        colorSchemeSeed: Colors.grey,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: Colors.grey,
        // ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          //contentPadding: EdgeInsets.symmetric(vertical: 2.5),
          errorStyle: TextStyle(
            color: Colors.green,
          ),
        ),

        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: _fontSize,
          ),
        ),
        // textTheme: Theme.of(context).textTheme.apply(
        //       fontSizeFactor: (_fontSize / Setting.fontSize),
        //fontSizeDelta: 2.0,
        //),

        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ButtonStyle(
        //     //foregroundColor: MaterialStateProperty.all(Colors.white),
        //     backgroundColor: MaterialStateProperty.all(Colors.green),
        //   ),
        // ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PoeticHome(),
        QuickHome.routeName: (context) => const QuickHome(),
        PoeticFormStatefulWidget.routeName: (context) =>
            const PoeticFormStatefulWidget(),
        UserPoeticList.routeName: (context) => const UserPoeticList(),
        Help.routeName: (context) => const Help(),
        Settings.routeName: (context) => const Settings(),
      },
    );

    // return ValueListenableBuilder(
    //   valueListenable: Hive.box(settingsDb).listenable(),
    //   builder: (context, Box settingsBox, widget) {
    //     var settings = settingsBox.get(settingsKey);
    //     var appState = AppState.fromJson(settings);
    //
    //     return materialApp;
    //   },
    // );
  }
}

/// Poetic list
class PoeticListWidget extends StatelessWidget {
  const PoeticListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //get data from remote
    return const Text("Explore what's peoples logic");
  }
}

/// Poetic
class PoeticHome extends StatefulWidget {
  const PoeticHome({Key? key}) : super(key: key);

  @override
  _PoeticHomeState createState() => _PoeticHomeState();
}

class _PoeticHomeState extends State<PoeticHome> {
  //late final Box<dynamic> hiveBox;
  //late final Map<dynamic, dynamic> hiveRecords;

  late final Poetic model;

  @override
  void initState() {
    super.initState();

    //hiveBox = Hive.box(poeticsBox);
    //hiveRecords = hiveBox.toMap();

    model = Poetic.fromJson(jsonDecode(beAllOneJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poetic logic'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.add_box_outlined),
        //     onPressed: () => Navigator.pushNamed(
        //         context, PoeticFormStatefulWidget.routeName),
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.list_alt),
        //     onPressed: () =>
        //         Navigator.pushNamed(context, UserPoeticList.routeName),
        //   ),
        // ],
      ),
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: GestureDetector(
          excludeFromSemantics: true,
          onHorizontalDragEnd: (details) {
            Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Text(
                  'Logic is also poetic because can cure the same.',
                  textAlign: TextAlign.center,
                  //fs 17
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                ),
                Text(
                  'Example',
                  textAlign: TextAlign.center,
                  //fs 18
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                PoeticPreview(
                  model: model,
                  addedLimit: 2,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    messageTimeChanges,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          /// checking big font size, text should not go outsize
                          /// the button, button should increase or font remain
                          child: const Text('More\n examples'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(90, 90),
                            maximumSize: const Size(180, 180),
                            shape: const CircleBorder(),
                          ),
                          onPressed: () => Navigator.pushNamed(
                              context, PoeticFormStatefulWidget.routeName),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          child: const Text('Add\n yours'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(110, 110),
                            maximumSize: const Size(200, 200),
                            shape: const CircleBorder(),
                          ),
                          onPressed: () => Navigator.pushNamed(
                              context, PoeticFormStatefulWidget.routeName),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
