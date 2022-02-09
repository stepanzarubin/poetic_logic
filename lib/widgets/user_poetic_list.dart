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
  late final Box<dynamic> hiveBox;
  late final Map<dynamic, dynamic> hiveRecords;

  @override
  void initState() {
    super.initState();

    hiveBox = Hive.box(poeticDb);
    hiveRecords = hiveBox.toMap();
    //var boxValues = box.values;
  }

  void _handleDelete(dbKey) {
    //setState(() {
    hiveBox.delete(dbKey);
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My list'),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(poeticDb).listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return const Center(
              child: Text('list is empty'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (BuildContext context, int index) {
              var recordKey = box.keyAt(index);
              var recordValue = box.get(recordKey);
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinglePoetic(
                          poetic: Poetic.fromJson(recordValue),
                          dbKey: recordKey,
                        ),
                      ),
                    );
                  },

                  //leading: Text(index.toString()),
                  //title: Text('Key: ${recordKey.toString()}'),
                  //subtitle: Text('Value: ${recordValue.toString()}'),

                  title: Text(recordValue['ifLogic']),
                  // first logic
                  subtitle: Text(recordValue['thenLogic'][0]),
                  trailing: IconButton(
                    onPressed: () {
                      _handleDelete(recordKey);
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
        onPressed: () =>
            Navigator.pushNamed(context, PoeticFormStatefulWidget.routeName),
      ),
    );
  }
}

class PoeticUserListOpt extends StatefulWidget {
  const PoeticUserListOpt({Key? key}) : super(key: key);

  @override
  _PoeticUserListOptState createState() => _PoeticUserListOptState();
}

class _PoeticUserListOptState extends State<PoeticUserListOpt> {
  @override
  Widget build(BuildContext context) {
    return Container();

    // Scaffold(
    //   body: hiveRecords.isNotEmpty
    //       ? ListView.builder(
    //           padding: const EdgeInsets.all(8),
    //           itemCount: hiveRecords.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return ListTile(
    //               onTap: () {
    //                 return;
    //                 Navigator.pushNamed(
    //                   context,
    //                   '/singlePoetic',
    //                   arguments: {'index': index, 'model': hiveRecords[index]},
    //                 );
    //               },
    //               leading: Text(index.toString()),
    //               //title: Text(hiveRecords.toString()),
    //               title: Text('Key: ${hiveRecords[index].key}'),
    //               subtitle: Text('Value: ${hiveRecords[index].value}'),
    //
    //               //title: Text(hiveRecords[index]['poeticLogic']['citation']),
    //               //subtitle: Text(hiveRecords[index]['poeticLogic']['poetics'][0]),
    //               trailing: IconButton(
    //                 onPressed: () {
    //                   _handleDelete(index);
    //                 },
    //                 icon: const Icon(Icons.delete),
    //               ),
    //             );
    //           },
    //         )
    //       : const Center(
    //           child: Text(
    //             'No items',
    //           ),
    //         ),
    // );
  }
}
