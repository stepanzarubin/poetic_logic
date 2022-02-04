import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  static const routeName = '/help';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: const [
            Text(
                'Navigation: swipe right or left on Home page to switch to the form.'),
            Text(''),
            Text('Form:'),
            Text(''),
          ],
        ),
      ),
    );
  }
}
