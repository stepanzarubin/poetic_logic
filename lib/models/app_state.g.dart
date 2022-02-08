// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    )..fontSize = (json['fontSize'] as num).toDouble();

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'user': instance.user?.toJson(),
      'fontSize': instance.fontSize,
    };
