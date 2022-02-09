import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/main.dart';
import 'package:poetic_logic/models/app_state.dart';
import 'package:poetic_logic/models/poetic.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  User user = User();
  double fontSize = 0;

  Future<void> _handleChangeFontSize(
      double fontSize, BuildContext context) async {
    await AppStateWidget.of(context).updateFontSize(fontSize);
  }

  Future<void> _handleUpdateUser(User user, BuildContext context) async {
    await AppStateWidget.of(context).updateUser(user);
  }

  Future<void> _handleResetToDefaults(BuildContext context) async {
    /// subscribe to refresh
    //final AppState appState = AppStateScope.of(context, rebuild: true);
    await AppStateWidget.of(context).resetToDefaults();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //print(Theme.of(context).textTheme.bodyText2?.fontSize);
    //print(MediaQuery.of(context).textScaleFactor);
    final AppState appState = AppStateScope.of(context, rebuild: false);
    // todo should not affect buttons etc, only titles and body text
    // interface stick with 16
    if (fontSize == 0) {
      fontSize = appState.fontSize;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Font size',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    appState.fontSize.toInt().toString(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              Container(
                //padding: const EdgeInsets.all(2.0),
                //color: Colors.blueGrey.shade100,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Text(
                        'Time changes, goes on, the world still exists, '
                        'so we understand in current circumstances. ',
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Slider(
                            value: fontSize,
                            min: Setting.minFontSize,
                            max: Setting.maxFontSize,
                            divisions: Setting.sliderDivisions(),
                            label: fontSize.toString(),
                            onChanged: (value) {
                              setState(() {
                                fontSize = value;
                              });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 70,
                            child: OutlinedButton(
                              child: const Text('Save'),
                              onPressed: () async {
                                try {
                                  /// to guarantee has to be carefully checked
                                  await _handleChangeFontSize(
                                      fontSize, context);
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content: Center(child: Text('saved')),
                                  //   ),
                                  // );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Center(child: Text('error occurred')),
                                    ),
                                  );
                                } finally {}
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'User',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                //color: Colors.blueGrey.shade100,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: appState.user?.firstName,
                            decoration: const InputDecoration(
                              hintText: 'First name',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              user.firstName = value;
                            },
                          ),
                        ),
                        const Text(
                          ' ',
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: appState.user?.lastName,
                            decoration: const InputDecoration(
                              hintText: 'Last name',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              user.lastName = value;
                            },
                          ),
                        ),
                        const Text(
                          ' ',
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: TextFormField(
                            initialValue: appState.user?.mm,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'mm',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              user.mm = value;
                            },
                          ),
                        ),
                        const Text(
                          '/ ',
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: TextFormField(
                            initialValue: appState.user?.dd,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'dd',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              user.dd = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 70,
                        child: OutlinedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                /// to guarantee has to be carefully checked
                                await _handleUpdateUser(user, context);
                                //todo fix, remove
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Center(child: Text('saved')),
                                //   ),
                                // );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Center(child: Text('error occurred')),
                                  ),
                                );
                              } finally {}
                            }
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //todo check it updates if not saved and returned
                        // OutlinedButton(
                        //   child: const Text('Undo changes'),
                        //   onPressed: () async {
                        //     //_formKey.currentState!.reset();
                        //   },
                        // ),
                        OutlinedButton(
                          child: const Text('Reset to defaults'),
                          onPressed: () async {
                            _handleResetToDefaults(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
