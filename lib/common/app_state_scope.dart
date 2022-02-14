import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetic_logic/common/app_state.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';

class AppStateScope extends InheritedWidget {
  const AppStateScope(
    this.data, {
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final AppState data;

  static AppState of(BuildContext context, {bool rebuild = true}) {
    final AppState? result = rebuild
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.data
        : context.findAncestorWidgetOfExactType<AppStateScope>()!.data;
    assert(result != null, 'No AppSetting found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return data != oldWidget.data;
  }
}

class AppStateWidget extends StatefulWidget {
  const AppStateWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}

class AppStateWidgetState extends State<AppStateWidget> {
  /// Works, but prefer using Map type directly
  /// after writing Man<String, dynamic> hive gives in return Man<dynamic, dynamic>
  /// which throws Exception
  /// .mapFrom
  AppState _data = AppState.fromJson(jsonDecode(jsonEncode(Hive.box(settingsDb).get(settingsKey))));

  //AppState _data = AppState.fromJson(Hive.box(settingsDb).get(settingsKey));

  Future<void> updateFontSize(double fontSize) async {
    if (_data.fontSize != fontSize) {
      setState(() {
        _data = _data.copyWith(fontSize: fontSize);
      });
      await _data.save();
    }
  }

  Future<void> updateUser(User? user) async {
    if (_data.user != user) {
      setState(() {
        _data = _data.copyWith(user: user);
      });
      await _data.save();
    }
  }

  Future<void> resetToDefaults() async {
    /// faster update UI and then safe to the database
    /// otherwise user would need to await
    setState(() {
      _data = AppState();
    });
    await _data.save();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      _data,
      child: widget.child,
    );
  }
}
