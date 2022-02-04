import 'package:flutter/material.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/help.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/widgets/user_poetic_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 220,
        //width: MediaQuery.of(context).size.width * 0.5,
        child: Drawer(
          child: ListView(
            //padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(
                height: 60,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      //color: Colors.brown,
                      ),
                  child: Text(
                    'Menu',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Main'),
                onTap: () => Navigator.pushNamed(context, '/'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Quick home'),
                onTap: () => Navigator.pushNamed(context, QuickHome.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Add logic'),
                onTap: () => Navigator.pushNamed(
                    context, PoeticFormStatefulWidget.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('My list'),
                onTap: () =>
                    Navigator.pushNamed(context, UserPoeticList.routeName),
              ),
              const ListTile(
                leading: Icon(Icons.list_alt),
                title: Text('Examples'),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help'),
                onTap: () => Navigator.pushNamed(context, Help.routeName),
              ),
              SafeArea(
                child: AboutListTile(
                  child: const Text(
                    'About',
                  ),
                  icon: const Icon(Icons.info),
                  //applicationIcon: FlutterLogo(),
                  applicationName: 'Poetic logic',
                  applicationVersion: 'v1.0.0',
                  applicationLegalese: '\u{a9} 2022 Stepan Zarubin',
                  aboutBoxChildren: <Widget>[
                    TextButton(
                      child: const Text('github: stepanzarubin/poetic_logic'),
                      onPressed: () async {
                        try {
                          await launch(
                              'https://github.com/stepanzarubin/poetic_logic');
                        } finally {}
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share app'),
                      onTap: () async {
                        try {
                          await Share.share(
                              'Check out the app https://play.google.com/store');
                        } finally {}
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star_half),
                      title: const Text('Rate app'),
                      onTap: () async {
                        try {
                          await launch('https://play.google.com/store');
                        } finally {}
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}