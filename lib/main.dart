import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetic_logic/common/app_state_scope.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/common/app_state.dart';
import 'package:poetic_logic/common/global.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/help.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/screens/settings.dart';
import 'package:poetic_logic/widgets/home_drawer.dart';
import 'package:poetic_logic/widgets/poetic_view.dart';
import 'package:poetic_logic/widgets/user_poetic_list.dart';

import 'models/poetic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  /// Init app
  await Hive.initFlutter();
  Box boxSettings = await Hive.openBox(settingsDb);
  await Hive.openBox(localDb);
  Box publishedBox = await Hive.openBox(publishedDb);
  if (!boxSettings.containsKey(settingsKey)) {
    /// default settings
    await boxSettings.put(settingsKey, AppState().toJson());

    /// Fill db with poetic example
    /// TODO: Json or Map, everywhere
    var poetic = Poetic.fromJson(jsonDecode(beAllOneJson));
    await poetic.save();
  }

  /// TODO: Connect only on first load and on manual/auto sync
  /// no need to check internet connection?
  /// Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Sync data on startup
  if (await isConnectivityConnected() && await hasNetwork()) {
    DatabaseReference ref = FirebaseDatabase.instance.ref(publishedRemoteCollection);
    DatabaseEvent event = await ref.once();
    var json = event.snapshot.value as Map<dynamic, dynamic>;
    if (json.isNotEmpty) {
      publishedBox.putAll(json);
    }
  }

  runApp(
    const AppStateWidget(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poetic logic',
      theme: ThemeData(
        //scaffoldBackgroundColor: Colors.white70,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          //contentPadding: EdgeInsets.symmetric(vertical: 2.5),
          errorStyle: TextStyle(
            color: Colors.green,
          ),
        ),

        /// control all fonts
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: (AppStateScope.of(context).fontSize / Setting.fontSize),
              //fontSizeDelta: (_fontSize - Setting.fontSize).abs(),
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
        PoeticFormStatefulWidget.routeName: (context) => const PoeticFormStatefulWidget(),
        UserPoeticList.routeName: (context) => const UserPoeticList(),
        Help.routeName: (context) => const Help(),
        Settings.routeName: (context) => const Settings(),
      },
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poetic logic'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pushNamed(context, UserPoeticList.routeName),
          ),
        ],
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
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                ),
                Text(
                  'Example',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  child: PoeticView(
                    model: Poetic.fromJson(jsonDecode(beAllOneJson)),
                    addedDisplayLimit: 2,
                  ),
                ),
                Text(
                  'example end',
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flexible(
                      //   child: ElevatedButton(
                      //     child: const Text('More\n examples'),
                      //     style: ElevatedButton.styleFrom(
                      //       minimumSize: const Size(90, 60),
                      //       maximumSize: const Size(180, 180),
                      //     ),
                      //     onPressed: () =>
                      //         Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName),
                      //   ),
                      // ),
                      Flexible(
                        child: ElevatedButton(
                          child: const Text('\u261A Add\n yours \u261B'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(110, 80),
                            maximumSize: const Size(200, 200),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName),
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
