import 'package:flutter/material.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/widgets/user_poetic_list.dart';

/// Only necessary buttons
/// Setting
///   one your familiar switch to Quick home screen
///
///   Buttons
///   User list
///
/// As an option
///   Hide example button on main screen
///   Quick form: if-then
///
class QuickHome extends StatefulWidget {
  const QuickHome({Key? key}) : super(key: key);

  static const routeName = '/quick';

  @override
  _QuickHomeState createState() => _QuickHomeState();
}

class _QuickHomeState extends State<QuickHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poetic logic')),
      body: Center(
        child: ListView(
          children: [
            Row(
              children: [
                // Expanded(
                //   child: ElevatedButton(
                //     child: const Text('My list'),
                //     style: ElevatedButton.styleFrom(
                //       minimumSize: const Size(90, 90),
                //       maximumSize: const Size(180, 180),
                //       shape: const CircleBorder(),
                //     ),
                //     onPressed: () =>
                //         Navigator.pushNamed(context, UserPoeticList.routeName),
                //   ),
                // ),
                // Expanded(
                //   child: ElevatedButton(
                //     child: const Text('Examples'),
                //     style: ElevatedButton.styleFrom(
                //       minimumSize: const Size(90, 90),
                //       maximumSize: const Size(180, 180),
                //       shape: const CircleBorder(),
                //     ),
                //     onPressed: () => Navigator.pushNamed(
                //         context, PoeticFormStatefulWidget.routeName),
                //   ),
                // ),
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
            const UserPoeticList()
          ],
        ),
      ),
    );
  }
}
