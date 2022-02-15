import 'package:flutter/material.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/screens/quick_home.dart';
import 'package:poetic_logic/widgets/poetic_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SinglePoetic extends StatefulWidget {
  const SinglePoetic({
    Key? key,
    required this.poetic,
    this.dbKey,
  }) : super(key: key);

  final Poetic poetic;
  final dynamic dbKey;

  static goHere(BuildContext context, {required Poetic poetic, dynamic dbKey}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinglePoetic(
          poetic: poetic,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.poetic.ifLogic,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: widget.poetic.isPublished ? Colors.yellow : null,
        child: ListView(
          children: [
            PoeticView(model: widget.poetic),
            if (!widget.poetic.hasAddedLogic())
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

                          await widget.poetic.addLogic(thenLogic, widget.dbKey);
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
                if (!widget.poetic.isPublished)
                  ElevatedButton(
                    onPressed: () async {
                      //UserPoeticList
                      var publisher = Publisher();
                      await publisher.publish(widget.poetic);
                      Navigator.pushNamed(context, QuickHome.routeName);
                      //scMsg(context, err);
                      setState(() {});
                    },
                    child: const Text(
                      'publish',
                      style: TextStyle(
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                if (!widget.poetic.isPublished)
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
            )
          ],
        ),
      ),
    );
  }
}
