import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/common/global.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/widgets/poetic_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SinglePoetic extends StatefulWidget {
  const SinglePoetic({
    Key? key,

    ///TODO: get by dbKey, model is optional
    //this.poetic,
    required this.dbKey,
  }) : super(key: key);

  //final Poetic? poetic;
  final dynamic dbKey;

  static goHere(BuildContext context, {required dynamic dbKey, Poetic? poetic}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinglePoetic(
          //poetic: poetic,
          dbKey: dbKey,
        ),
      ),
    );
  }

  @override
  State<SinglePoetic> createState() => _SinglePoeticState();
}

class _SinglePoeticState extends State<SinglePoetic> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String thenLogic = '';

  late final Poetic poetic;

  Future<bool>? isOnline;

  @override
  void initState() {
    super.initState();

    poetic = Poetic.fromJson(jsonDecode(jsonEncode(Hive.box(localDb).get(widget.dbKey))));

    if (!poetic.isPublished) {
      isOnline = isConnectivityConnected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          poetic.ifLogic,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: poetic.isPublished ? Colors.yellow : null,
        child: ListView(
          children: [
            PoeticView(model: poetic),
            if (!poetic.hasAddedLogic())
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'logic?';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          thenLogic = value.toString();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          await poetic.addLogic(thenLogic, widget.dbKey);
                          _formKey.currentState!.reset();

                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  child: const Text(
                    'delete',
                    style: TextStyle(
                      color: Colors.red,
                      //backgroundColor: Colors.red,
                    ),
                  ),
                  onPressed: () async {
                    await Hive.box(localDb).delete(widget.dbKey);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                if (!poetic.isPublished)
                  ElevatedButton(
                    onPressed: () async {
                      if (!await isConnectivityConnected() || !await hasNetwork()) {
                        scMsg(context, 'Please check internet connection');
                        return;
                      }

                      if (await Publisher().publish(poetic)) {
                        Navigator.pushNamed(context, QuickHome.routeName);
                      } else {
                        scMsg(context, 'Error: not published');
                      }
                    },
                    child: const Text(
                      'publish',
                      style: TextStyle(
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                if (!poetic.isPublished)
                  ElevatedButton(
                    child: const Text(
                      'edit',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoeticFormStatefulWidget(
                            dbKey: widget.dbKey,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
