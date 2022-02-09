import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poetic_logic/common/app_state_scope.dart';
import 'package:poetic_logic/common/app_state.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppState? _appStateFormModel;

  Future<void> _handleChangeFontSize(BuildContext context) async {
    await AppStateWidget.of(context)
        .updateFontSize(_appStateFormModel!.fontSize);
  }

  Future<void> _handleUpdateUser(BuildContext context) async {
    await AppStateWidget.of(context).updateUser(_appStateFormModel!.user);
  }

  Future<void> _handleResetToDefaults(BuildContext context) async {
    /// subscribe once to refresh, but then how to unsubscribe?
    /// final AppState appState = AppStateScope.of(context, rebuild: true);
    /// does this refresh from above without subscription?

    //todo does not work
    _formKey.currentState!.reset();
    _appStateFormModel = null;
    await AppStateWidget.of(context).resetToDefaults();
    // setState(() {
    //   _appStateFormModel!.setDefaults();
    // });
  }

  void scMsg(BuildContext context, msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.center)),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print(Theme.of(context).textTheme.bodyText2?.fontSize);
    //print(MediaQuery.of(context).textScaleFactor);
    final AppState appState = AppStateScope.of(context, rebuild: true);
    _appStateFormModel ??= appState.formModel();

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
                    /// current value
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
                          fontSize: _appStateFormModel!.fontSize,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Slider(
                            value: _appStateFormModel!.fontSize,
                            min: Setting.minFontSize,
                            max: Setting.maxFontSize,
                            divisions: Setting.sliderDivisions(),
                            label: _appStateFormModel!.fontSize.toString(),
                            onChanged: (value) {
                              setState(() {
                                _appStateFormModel!.fontSize = value;
                              });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            child: const Text('Save'),
                            onPressed: () async {
                              try {
                                /// to guarantee has to be carefully checked
                                await _handleChangeFontSize(context);
                                scMsg(context, 'Saved');
                              } catch (e) {
                                scMsg(context, 'Error occurred');
                              } finally {}
                            },
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
                            initialValue: _appStateFormModel!.user!.firstName,
                            decoration: const InputDecoration(
                              hintText: 'First name',
                            ),
                            validator: (value) {
                              return null;
                            },
                            //onChanged: ,
                            onSaved: (value) {
                              _appStateFormModel!.user!.firstName = value;
                            },
                          ),
                        ),
                        const Text(
                          ' ',
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: _appStateFormModel!.user!.lastName,
                            decoration: const InputDecoration(
                              hintText: 'Last name',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.lastName = value;
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
                            initialValue: _appStateFormModel!.user!.mm,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'mm',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.mm = value;
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
                            initialValue: _appStateFormModel!.user!.dd,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'dd',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.dd = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        child: const Text('Save'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              /// to guarantee has to be carefully checked
                              await _handleUpdateUser(context);
                              scMsg(context, 'Saved');
                            } catch (e) {
                              scMsg(context, 'error occurred');
                            } finally {}
                          }
                        },
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
                          onPressed: _appStateFormModel!.isDefault()
                              ? null
                              : () async {
                                  await _handleResetToDefaults(context);
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
