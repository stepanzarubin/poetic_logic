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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mmController = TextEditingController();
  final TextEditingController ddController = TextEditingController();

  AppState? _appStateFormModel;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mmController.dispose();
    ddController.dispose();
    super.dispose();
  }

  Future<void> _handleChangeFontSize(BuildContext context) async {
    await AppStateWidget.of(context)
        .updateFontSize(_appStateFormModel!.fontSize);
  }

  Future<void> _handleUpdateUser(
    BuildContext context,
    AppState appState,
  ) async {
    if (_isUserChanged(appState)) {
      await AppStateWidget.of(context).updateUser(_appStateFormModel!.user);
    }
  }

  Future<void> _handleResetToDefaults(BuildContext context) async {
    /// important, this clears controllers
    /// form should have this feature but it can only clear to default value
    _appStateFormModel = null;
    await AppStateWidget.of(context).resetToDefaults();
  }

  bool _isFontChanged(AppState appState) {
    if (_appStateFormModel!.fontSize != appState.fontSize) {
      return true;
    } else {
      return false;
    }
  }

  bool _isUserChanged(AppState appState) {
    if (appState.user == null && _appStateFormModel!.user!.isEmpty()) {
      return false;
    }
    if (_appStateFormModel!.user != appState.user) {
      return true;
    } else {
      return false;
    }
  }

  void scMsg(BuildContext context, msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.center)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context, rebuild: true);
    _appStateFormModel ??= appState.giveNewCopy();
    firstNameController.text = _appStateFormModel!.user!.firstName;
    lastNameController.text = _appStateFormModel!.user!.lastName;
    mmController.text = _appStateFormModel!.user!.mm;
    ddController.text = _appStateFormModel!.user!.dd;

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
                            onPressed: !_isFontChanged(appState)
                                ? null
                                : () async {
                                    try {
                                      /// to guarantee has to be carefully checked
                                      await _handleChangeFontSize(context);
                                      scMsg(context, 'Font saved');
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
                            controller: firstNameController,
                            //initialValue: _appStateFormModel!.user!.firstName,
                            decoration: const InputDecoration(
                              hintText: 'First name',
                            ),
                            validator: (value) {
                              return null;
                            },
                            onChanged: (value) {
                              _appStateFormModel!.user!.firstName = value;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.firstName =
                                  value.toString().trim();
                            },
                          ),
                        ),
                        const Text(
                          ' ',
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: lastNameController,
                            //initialValue: _appStateFormModel!.user!.lastName,
                            decoration: const InputDecoration(
                              hintText: 'Last name',
                            ),
                            onChanged: (value) {
                              _appStateFormModel!.user!.lastName = value;
                            },
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.lastName =
                                  value.toString().trim();
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
                            controller: mmController,
                            //initialValue: _appStateFormModel!.user!.mm,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'mm',
                            ),
                            onChanged: (value) {
                              _appStateFormModel!.user!.mm = value;
                            },
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.mm =
                                  value.toString().trim();
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
                            controller: ddController,
                            //initialValue: _appStateFormModel!.user!.dd,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'dd',
                            ),
                            onChanged: (value) {
                              _appStateFormModel!.user!.dd = value;
                            },
                            validator: (value) {
                              return null;
                            },
                            onSaved: (value) {
                              _appStateFormModel!.user!.dd =
                                  value.toString().trim();
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
                          if (!_isUserChanged(appState)) {
                            scMsg(context, 'Nothing to update');
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              await _handleUpdateUser(context, appState);
                              scMsg(context, 'User saved');
                            } catch (e) {
                              scMsg(context, 'error occurred');
                            } finally {}
                          }
                        },
                      ),
                    ),
                    OutlinedButton(
                      child: const Text('Reset to defaults'),
                      onPressed: appState.isDefault()
                          ? null
                          : () async {
                              await _handleResetToDefaults(context);
                              scMsg(context, 'Reset');
                            },
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
