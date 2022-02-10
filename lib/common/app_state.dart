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

  /// User as null only to avoid saving empty Maps and Json Maps and Json
  User? user;

  AppState({
    this.fontSize = Setting.fontSize,
    this.user,
  });

  /// Uses this.user
  AppState copyWith({
    double? fontSize,
    User? user,
  }) {
    return AppState(
      fontSize: fontSize ?? this.fontSize,
      user: user ?? this.user,
    );
  }

  /// Creates different copy with new User which is applicable to give values
  /// Reason:
  /// Object/instance is passed by reference, so:
  /// user: user ?? User()
  /// changing receiver updates this.user, what may also trigger
  /// change notification
  AppState giveNewCopy({bool createUser = true}) {
    User? newUser;
    if (user != null) {
      newUser = User.user(user!.firstName, user!.lastName, user!.mm, user!.dd);
    } else if (createUser) {
      newUser = User();
    }

    return AppState(
      fontSize: fontSize,
      user: newUser,
    );
  }

  /// User() and null is the same
  bool isDefault() {
    var _default = AppState();
    if (this == _default || this == _default.giveNewCopy()) {
      return true;
    }
    return false;
  }

  /// not for Inherited data
  // void setDefaults() {
  //   var _default = AppState();
  //   fontSize = _default.fontSize;
  //   user = _default.user;
  // }

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

  @override
  bool operator ==(Object other) {
    return other is AppState &&
        other.fontSize == fontSize &&
        other.user == user;
  }

  @override
  int get hashCode => Object.hash(fontSize, user);

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
