import 'package:flutter/material.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/screens/form.dart';
import 'package:poetic_logic/widgets/poetic_preview.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            PoeticPreview(model: widget.poetic),
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
                          thenLogic = value!;
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'back',
                  ),
                ),
                if (!widget.poetic.hasAddedLogic())
                  ElevatedButton(
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
                    child: const Text(
                      'edit',
                    ),
                  )
                // publish
                // else
                //   const ElevatedButton(
                //     onPressed: null,
                //     child: Text(
                //       'publish',
                //     ),
                //   )
              ],
            )
          ],
        ),
      ),
    );
  }
}
