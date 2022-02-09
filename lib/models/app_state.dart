import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';

part 'app_state.g.dart';

@JsonSerializable(explicitToJson: true)
class AppState extends HasUser {
  final double fontSize;
  final User? user;

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
