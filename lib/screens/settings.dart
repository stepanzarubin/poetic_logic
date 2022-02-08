import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/main.dart';
import 'package:poetic_logic/models/app_state.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AppState appState;

  @override
  void initState() {
    super.initState();

    appState = AppState();
  }

  Future<void> _updateSettings() async {}

  @override
  Widget build(BuildContext context) {
    //print(Theme.of(context).textTheme.bodyText2?.fontSize);
    //print(MediaQuery.of(context).textScaleFactor);

    //appState = AppState.fromJson(AppSetting.of(context).data.toJson());

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
                    AppSetting.of(context).data.fontSize.toInt().toString(),
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
                          //todo but better if will update the whole app
                          fontSize: appState.fontSize,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Slider(
                            value: appState.fontSize,
                            min: Setting.minFontSize,
                            max: Setting.maxFontSize,
                            divisions: Setting.sliderDivisions(),
                            label: appState.fontSize.toString(),
                            onChanged: (value) {
                              setState(() {
                                appState.fontSize = value;
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
                                await _updateSettings();
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
                              appState.user!.firstName = value;
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
                              appState.user!.lastName = value;
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
                              appState.user!.mm = value;
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
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'dd',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              appState.user!.dd = value;
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
                            await _updateSettings();
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await appState.save();

                              /// trigger update on inherited
                            }
                          },
                        ),
                      ),
                    ),
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
