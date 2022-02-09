import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';

part 'app_state.g.dart';

mixin Setting {
  static const fontSizeKey = 'fontSize';
  static const minFontSize = 12.0;
  static const maxFontSize = 20.0;
  static const fontSize = 16.0;

  static int sliderDivisions() {
    var d = (maxFontSize - minFontSize) / 2;
    return d.toInt();
  }
}

@JsonSerializable(explicitToJson: true)
class AppState extends HasUser {
  double fontSize = Setting.fontSize;
  User? user;

  AppState({
    this.fontSize = Setting.fontSize,
    this.user,
  });

  AppState copyWith({
    double? fontSize,
    User? user,
  }) {
    return AppState(
      fontSize: fontSize ?? this.fontSize,
      user: user ?? this.user,
    );
  }

  /// Going to remember user name after first Poetic is submitted
  /// does it make sense to keep user as null?
  AppState formModel() {
    return AppState(
      fontSize: fontSize,
      user: user ?? User(),
    );
  }

  bool isDefault() {
    var _default = AppState();
    // user null and user not null
    //if (jsonEncode(toJson()) == jsonEncode(_default.toJson())) {
    if (_default.fontSize != fontSize) {
      return false;
    }

    // user without credentials is valid empty user
    if (user != null && !user!.isEmpty()) {
      return false;
    }

    return true;
  }

  /// not for Inherited data
  void setDefaults() {
    var _default = AppState();
    fontSize = _default.fontSize;
    user = _default.user;
  }

  @override
  String getSignature() {
    if (user == null) {
      return User.oneOfPeople;
    } else {
      return user!.getSignature();
    }
  }

  Future<void> save() async {
    var box = Hive.box(settingsDb);
    return await box.put(settingsKey, toJson());
  }

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
