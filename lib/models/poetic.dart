import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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

  String getSignature([bool short = false]) {
    if (isEmpty()) {
      return User.oneOfPeople;
    } else if (short) {
      return '$firstName ${lastName.substring(0, 1)}.';
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

  /// Should be used for custom format, overriding (Title, year: pages)
  String title = '';
  String year = '';
  String pages = '';

  /// Uri or something else
  ///String? source;

  Quote({
    this.text = '',
    this.title = '',
    this.year = '',
    this.pages = '',
  });

  bool isEmpty() {
    return text.isEmpty && title.isEmpty && year.isEmpty && pages.isEmpty;
  }

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

  factory AddedLogic.fromJson(Map<String, dynamic> json) => _$AddedLogicFromJson(json);
  Map<String, dynamic> toJson() => _$AddedLogicToJson(this);
}

/// Poetic itself is If-then combination
@JsonSerializable(explicitToJson: true)
class Poetic extends HasUser {
  //@JsonKey(ignore: true)
  /// Db key for local database
  /// localId
  dynamic dbKey;

  /// Db key for remote database
  dynamic remoteId;

  String ifLogic = '';
  Quote? quote = Quote();

  /// TODO: Makes sense to use Set<String>
  //Set<String> thenLogic = {};
  List<String> thenLogic = [];
  User? user;
  bool isPublished = false;
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

  factory Poetic.fromJson(Map<String, dynamic> json) => _$PoeticFromJson(json);
  Map<String, dynamic> toJson() => _$PoeticToJson(this);

  /// Adds or updates record
  Future<dynamic> save([dynamic dbK]) async {
    var box = Hive.box(localDb);
    // next index, hive stars with 0
    dbKey = dbKey ?? (dbK ?? box.length);

    /// Remove empty strings
    thenLogic.removeWhere((element) => element.isEmpty);
    for (var added in addedLogic) {
      added.thenLogic.removeWhere((element) => element.isEmpty);
    }

    /// Do not record empty user
    if (user != null && user!.isEmpty()) {
      user = null;
    }

    await box.put(dbKey, toJson());
    //return await box.add(toJson());

    /// Update record with dbKey/index (optionally)
    /// Possible to go with indexes only
    /// and for poetics this is applicable
    /// index = key until key is not provided
    //return await box.put(dbKey, toJson());

    return dbKey;
  }

  Future<dynamic> addLogic(String logic, [dynamic dbK]) async {
    if (dbK == null && dbKey == null) {
      throw Exception('Impossible to identify db record.');
    }

    try {
      var box = Hive.box(localDb);
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
        var box = Hive.box(localDb);
        return box.put(dbK ?? dbKey, toJson());
      }
    } catch (e) {
      return e.toString();
    }
  }
}

class Publisher {
  Future<dynamic> publish(Poetic model) async {
    if (model.isPublished) {
      throw Exception('Poetic ${model.ifLogic} already published.');
    }

    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference _ref = database.ref(publishedRemoteCollection);
    try {
      model.isPublished = true;
      await _ref.push().set(model.toJson());
      //model.remoteId = ;
      _moveToPublished(model);
    } on FirebaseException catch (e) {
      //print(e.message);
    }
  }

  /// Move to local published db and delete
  _moveToPublished(Poetic model) {
    var box = Hive.box(publishedDb);
    box.put(box.length, model.toJson());
    Hive.box(localDb).delete(model.dbKey);
  }
}
