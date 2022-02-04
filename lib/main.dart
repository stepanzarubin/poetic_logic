import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/help.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/widgets/home_drawer.dart';
import 'package:poetic_logic/widgets/poetic_preview.dart';
import 'package:poetic_logic/widgets/user_poetic_list.dart';

import 'models/poetic.dart';

void main() async {
  await Hive.initFlutter();
  Box boxSettings = await Hive.openBox(poeticSettingsDb);

  /// First run: fill db with settings and examples
  if (boxSettings.isEmpty) {
    boxSettings.put('settings', {});
    Box boxPoetics = await Hive.openBox(poeticDb);
    await boxPoetics.add(jsonDecode(beAllOneJson));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poetic logic',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey,
        primarySwatch: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          //contentPadding: EdgeInsets.symmetric(vertical: 2.5),
          errorStyle: TextStyle(
            color: Colors.green,
          ),
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(
            fontSize: 18.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            //foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.green),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PoeticHome(),
        QuickHome.routeName: (context) => const QuickHome(),
        PoeticFormStatefulWidget.routeName: (context) =>
            const PoeticFormStatefulWidget(),
        UserPoeticList.routeName: (context) => const UserPoeticList(),
        Help.routeName: (context) => const Help(),
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
                const Text(
                  'Logic is also poetic because can cure the same.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    // backgroundColor: Colors.grey,
                    // color: Colors.white,
                  ),
                ),
                const Text(
                  'Example',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                PoeticPreview(
                  model: model,
                  addedLimit: 2,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    'Time changes, goes on, the world still exists, '
                    'so we understand in current circumstances. '
                    'Few meaningful words to you. Generated by you.',
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
                      Expanded(
                        child: ElevatedButton(
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
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('Add\n yours'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(90, 90),
                            maximumSize: const Size(180, 180),
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
