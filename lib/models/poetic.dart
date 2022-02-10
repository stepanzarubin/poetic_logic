import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poetic_logic/common/const.dart';
part 'poetic.g.dart';

@JsonSerializable()
class User {
  static const String oneOfPeople = 'one of people';
  String firstName = '';
  String lastName = '';
  String mm = '';
  String dd = '';

  User({
    this.firstName = '',
    this.lastName = '',
    this.mm = '',
    this.dd = '',
  });

  User.user(
    this.firstName,
    this.lastName,
    this.mm,
    this.dd,
  );

  bool isEmpty() {
    return firstName.isEmpty && lastName.isEmpty && mm.isEmpty && dd.isEmpty;
  }

  String getSignature() {
    if (isEmpty()) {
      return User.oneOfPeople;
    } else {
      return '$firstName $lastName, $mm/$dd';
    }
  }

  @override
  bool operator ==(Object other) {
    return other is User &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.mm == mm &&
        other.dd == dd;
  }

  @override
  int get hashCode => Object.hash(firstName, lastName, mm, dd);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

abstract class HasUser {
  String getSignature() {
    return User.oneOfPeople;
  }
}

@JsonSerializable()
class Quote {
  String text = '';

  /// should be used for custom format, overriding (Title, year: pages)
  String? title;
  String? year;
  String? pages;

  /// Uri or something else
  ///String? source;

  Quote({
    this.text = '',
    this.title = '',
    this.year,
    this.pages,
  });

  Quote.quote(
    this.text,
    this.title,
    this.year,
    this.pages,
  );

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}

/// Reworked PoeticLogic
@JsonSerializable(explicitToJson: true)
class AddedLogic extends HasUser {
  List<String> thenLogic = [];
  User? user;

  AddedLogic({
    this.thenLogic = const [],
    this.user,
  });

  @override
  String getSignature() {
    if (user == null) {
      return User.oneOfPeople;
    } else {
      return user!.getSignature();
    }
  }

  factory AddedLogic.fromJson(Map<String, dynamic> json) =>
      _$AddedLogicFromJson(json);
  Map<String, dynamic> toJson() => _$AddedLogicToJson(this);
}

/// Poetic itself is If-then combination
@JsonSerializable(explicitToJson: true)
class Poetic extends HasUser {
  //@JsonKey(ignore: true)
  dynamic dbKey;

  String ifLogic = '';
  Quote? quote = Quote(); //todo what is does if does not set the default?
  List<String> thenLogic = [];
  User? user;
  List<AddedLogic> addedLogic = [];

  Poetic({
    this.ifLogic = '',
    this.quote,
    this.user,
  });

  Poetic.form() {
    thenLogic.add('');
    quote = Quote();
    user = User();
  }

  @override
  String getSignature() {
    if (user == null) {
      return User.oneOfPeople;
    } else {
      return user!.getSignature();
    }
  }

  bool hasAddedLogic() {
    return addedLogic.isNotEmpty;
  }

  bool isPublished() {
    /// todo temporary, added logic can be added only after publishing
    /// after which original record become not editable, author can update
    /// until somebody adds his first logic
    return hasAddedLogic();
  }

  factory Poetic.fromJson(Map<String, dynamic> json) => _$PoeticFromJson(json);
  Map<String, dynamic> toJson() => _$PoeticToJson(this);

  /// Adds or updates record
  Future<dynamic> save(dynamic dbK) async {
    var box = Hive.box(poeticDb);

    /// remove empty strings
    thenLogic.removeWhere((element) => element.isEmpty);
    for (var added in addedLogic) {
      added.thenLogic.removeWhere((element) => element.isEmpty);
    }

    /// do not record empty user
    if (user != null && user!.isEmpty()) {
      user = null;
    }

    if (dbK != null) {
      // update
      await box.put(dbK, toJson());
      return dbK;
    } else {
      // create
      return await box.add(toJson());

      /// Update record with dbKey/index (optionally)
      /// Possible to go with indexes only
      /// and for poetics this is applicable
      /// index = key until key is not provided
      //return await box.put(dbKey, toJson());
    }
  }

  Future<dynamic> addLogic(String logic, [dynamic dbK]) async {
    if (dbK == null && dbKey == null) {
      throw Exception('Impossible to identify db record.');
    }

    try {
      var box = Hive.box(poeticDb);
      thenLogic.add(logic);
      return await box.put(dbK ?? dbKey, toJson());
    } catch (e) {
      return e.toString();
    }
  }

  Future<dynamic> removeLogic(String logic, [dynamic dbK]) async {
    if (dbK == null && dbKey == null) {
      throw Exception('Impossible to identify db record.');
    }

    try {
      if (thenLogic.remove(logic)) {
        var box = Hive.box(poeticDb);
        return box.put(dbK ?? dbKey, toJson());
      }
    } catch (e) {
      return e.toString();
    }
  }
}
