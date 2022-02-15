// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poetic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      mm: json['mm'] as String? ?? '',
      dd: json['dd'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'mm': instance.mm,
      'dd': instance.dd,
    };

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
      text: json['text'] as String? ?? '',
      title: json['title'] as String? ?? '',
      year: json['year'] as String? ?? '',
      pages: json['pages'] as String? ?? '',
    );

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'text': instance.text,
      'title': instance.title,
      'year': instance.year,
      'pages': instance.pages,
    };

AddedLogic _$AddedLogicFromJson(Map<String, dynamic> json) => AddedLogic(
      thenLogic: (json['thenLogic'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddedLogicToJson(AddedLogic instance) =>
    <String, dynamic>{
      'thenLogic': instance.thenLogic,
      'user': instance.user?.toJson(),
    };

Poetic _$PoeticFromJson(Map<String, dynamic> json) => Poetic(
      ifLogic: json['ifLogic'] as String? ?? '',
      quote: json['quote'] == null
          ? null
          : Quote.fromJson(json['quote'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..dbKey = json['dbKey']
      ..remoteId = json['remoteId']
      ..thenLogic =
          (json['thenLogic'] as List<dynamic>).map((e) => e as String).toList()
      ..isPublished = json['isPublished'] as bool
      ..addedLogic = (json['addedLogic'] as List<dynamic>)
          .map((e) => AddedLogic.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PoeticToJson(Poetic instance) => <String, dynamic>{
      'dbKey': instance.dbKey,
      'remoteId': instance.remoteId,
      'ifLogic': instance.ifLogic,
      'quote': instance.quote?.toJson(),
      'thenLogic': instance.thenLogic,
      'user': instance.user?.toJson(),
      'isPublished': instance.isPublished,
      'addedLogic': instance.addedLogic.map((e) => e.toJson()).toList(),
    };
