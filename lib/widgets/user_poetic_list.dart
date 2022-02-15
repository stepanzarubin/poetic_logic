import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/widgets/single_poetic.dart';

/// UserPoeticList
class UserPoeticList extends StatefulWidget {
  const UserPoeticList({Key? key}) : super(key: key);

  static const routeName = '/userPoeticList';

  @override
  _UserPoeticListState createState() => _UserPoeticListState();
}

class _UserPoeticListState extends State<UserPoeticList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My list'),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(localDb).listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return const Center(
              child: Text('list is empty'),
            );
          }

          /// TODO
          //var vvv = box.values;
          //var result = box.values.cast<Map<String, dynamic>>();
          // var result = box.toMap().map(
          //       (k, e) => MapEntry(
          //         k.toString(),
          //         Map<String, dynamic>.from(e),
          //       ),
          //     );

          /// factory to generate List of Poetics?

          /// TODO: How is read after deletion
          /// rework
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            //itemCount: result.length,
            itemBuilder: (BuildContext context, int index) {
              /// for keys method is box.put/delete
              /// for indexes method is box.putAt/deleteAt
              /// it's possible to only use index
              var recordKey = box.keyAt(index);
              var recordValue = box.get(recordKey);
              //var recordValue = result[index]!;

              /// TODO if it does not work just save as strings and decode once
              Poetic poetic = Poetic.fromJson(jsonDecode(jsonEncode(recordValue)));

              return Card(
                color: poetic.isPublished ? Colors.yellow : null,
                child: ListTile(
                  onTap: () {
                    SinglePoetic.goHere(context, dbKey: recordKey);
                  },
                  //title: Text(poetic.ifLogic),
                  //subtitle: Text(poetic.thenLogic[0]),
                  title: Text(recordValue['ifLogic']),
                  subtitle: Text(recordValue['thenLogic'][0]),
                  trailing: IconButton(
                    onPressed: () {
                      Hive.box(localDb).delete(recordKey);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Add'),
        onPressed: () => Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName),
      ),
    );
  }
}
