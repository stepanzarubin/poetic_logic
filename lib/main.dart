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
  AppState appState;

  await Hive.initFlutter();
  Box boxSettings = await Hive.openBox(settingsDb);
  final Box boxPoetics = await Hive.openBox(poeticDb);

  if (!boxSettings.containsKey(settingsKey)) {
    /// default settings
    appState = AppState();
    await boxSettings.put(settingsKey, appState.toJson());
    await boxPoetics.add(jsonDecode(beAllOneJson));
  } else {
    /// load settings
    appState = AppState.fromJson(boxSettings.get(settingsKey));
  }

  runApp(AppSetting(
    data: appState,
    child: const MyApp(),
  ));
}

class AppSetting extends InheritedWidget {
  const AppSetting({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final AppState data;

  static AppSetting of(BuildContext context) {
    final AppSetting? result =
        context.dependOnInheritedWidgetOfExactType<AppSetting>();
    assert(result != null, 'No AppSetting found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppSetting oldWidget) {
    return data != oldWidget.data;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late double _fontSize;

  @override
  Widget build(BuildContext context) {
    _fontSize = AppSetting.of(context).data.fontSize;

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

        // textTheme: TextTheme(
        //   bodyText2: TextStyle(
        //     /// todo affect all font sizes respectively
        //     fontSize: _fontSize,
        //   ),
        // ),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: (_fontSize / Setting.fontSize),
              //fontSizeDelta: 2.0,
            ),
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
