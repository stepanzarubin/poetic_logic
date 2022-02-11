import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:poetic_logic/common/app_state.dart';
import 'package:poetic_logic/common/app_state_scope.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/widgets/poetic_preview.dart';
import 'package:poetic_logic/widgets/single_poetic.dart';

class PreviewNotifier extends ValueNotifier<Poetic> {
  PreviewNotifier(Poetic value) : super(value);

  void changeMyData(Poetic value) {
    this.value = value;
    notifyListeners();
  }
}

class PoeticFormStatefulWidget extends StatefulWidget {
  const PoeticFormStatefulWidget({
    Key? key,
    this.dbKey,
  }) : super(key: key);

  static const routeName = '/poeticForm';
  final dynamic dbKey;

  @override
  State<PoeticFormStatefulWidget> createState() =>
      _PoeticFormStatefulWidgetState();
}

class _PoeticFormStatefulWidgetState extends State<PoeticFormStatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool updateNotFoundScenario = false;

  // this checks if value has changed, I just need update each time on button press
  // final ValueNotifier<Poetic> _defaultNotifier =
  //     ValueNotifier<Poetic>(Poetic(poeticLogic: PoeticLogic()));

  Poetic formModel = Poetic.form();

  late final PreviewNotifier previewNotifier;

  @override
  void initState() {
    super.initState();

    // on update
    if (widget.dbKey != null) {
      var box = Hive.box(poeticDb);
      var record = box.get(widget.dbKey);
      if (record == null) {
        updateNotFoundScenario = true;
      } else {
        updateNotFoundScenario = false;
        formModel = Poetic.fromJson(record);
      }
    }

    previewNotifier = PreviewNotifier(formModel);
    //previewNotifier.changeMyData(formModel);
  }

  _removeThenLogic(int index) {
    setState(() {
      formModel.thenLogic.removeAt(index);
    });
  }

  _addThenLogic() {
    setState(() {
      formModel.thenLogic.add('');
    });
  }

  /// Widgets
  List<Widget> _thenLogicSection() {
    List<Widget> rows = [];
    if (formModel.thenLogic.isEmpty) {
      //the only scenario - user removed all items, them I am keeping one field
      //and now showing remove button for empty row
      return rows;
    }
    //excluding empty string row
    for (int index = 0; index < formModel.thenLogic.length; index++) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 9,
            child: TextFormField(
              key: UniqueKey(),
              initialValue: formModel.thenLogic[index],
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(
                hintText:
                    formModel.thenLogic.length == 1 ? 'Poetic logic' : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  formModel.thenLogic[index] = '';
                } else {
                  formModel.thenLogic[index] = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (index == 0) {
                    /// show error for the first row (at least one is required)
                    return 'logic?';
                  }
                }
                return null;
              },
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  formModel.thenLogic[index] = value;
                }
              },
            ),
          ),
          if (index != (formModel.thenLogic.length - 1))
            SizedBox(
              width: 55,
              height: 40,
              child: IconButton(
                onPressed: () => _removeThenLogic(index),
                icon: const Icon(Icons.remove_circle_outlined),
              ),
            )
          else
            SizedBox(
              width: 55,
              height: 58,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  onPressed: () => _addThenLogic(),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ),
            ),
        ],
      ));
    }

    return rows;
  }

  /// For new record prefill user from app state
  void _userFromAppState(BuildContext context) {
    if (widget.dbKey == null) {
      final AppState appState = AppStateScope.of(context, rebuild: false);
      if (appState.user != null) {
        formModel.user = User.fromJson(appState.user!.toJson());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _userFromAppState(context);

    if (updateNotFoundScenario) {
      return Scaffold(
        appBar: AppBar(title: const Text('Poetic form')),
        body: Center(
          child: Text('Record not found: dbKey=${widget.dbKey}'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Poetic form')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text(
                '* If:',
                style: TextStyle(
                  backgroundColor: Colors.grey,
                ),
              ),
              TextFormField(
                initialValue: formModel.ifLogic,
                minLines: 1,
                maxLines: 10,

                /// does it work without it?
                onChanged: (value) {
                  formModel.ifLogic = value.toString();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'logic?';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    formModel.ifLogic = value;
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 2),
                child: Text(
                  'Referencing quote:',
                  //'I proved by Reference/Quotation:',
                  style: TextStyle(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  const FittedBox(
                    child: Text(
                      '<<',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: formModel.quote?.text,
                      minLines: 2,
                      maxLines: 5,
                      //maxLength: 100,
                      decoration: const InputDecoration(
                          //border: OutlineInputBorder(),
                          ),

                      /// how happens that on setState this if preserved and
                      /// user.firstName is not?
                      onChanged: (value) {
                        formModel.quote!.text = value.toString();
                      },
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          formModel.quote!.text = value;
                        }

                        ///option to send model by model
                        ///Quote qw = Quote();
                        ///qw.text = value;
                      },
                    ),
                  ),
                  const LimitedBox(
                    //alignment: Alignment.topLeft,
                    child: Text(
                      '>>',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '( ',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        initialValue: formModel.quote?.title,
                        minLines: 1,
                        maxLines: 3,
                        //maxLength: 255,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          //helperText: 'for specific notation use just title',
                        ),
                        onChanged: (value) {
                          formModel.quote!.title = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.quote!.title = value;
                        },
                      ),
                    ),
                    const Text(
                      ' , ',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        initialValue: formModel.quote?.year,
                        //can be specifics
                        //maxLength: 4,
                        decoration: const InputDecoration(
                          hintText: 'year',
                        ),
                        onChanged: (value) {
                          formModel.quote!.year = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.quote!.year = value;
                        },
                      ),
                    ),
                    const Text(
                      ' : p. ',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        initialValue: formModel.quote?.pages,
                        //can be specifics
                        //maxLength: 5,
                        decoration: const InputDecoration(
                          hintText: 'pages',
                        ),
                        onChanged: (value) {
                          formModel.quote!.pages = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.quote!.pages = value;
                        },
                      ),
                    ),
                    const Text(
                      ')',
                      style: TextStyle(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  '* Then:',
                  style: TextStyle(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
              ..._thenLogicSection(),
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'By, ${User.oneOfPeople}, or, specify:',
                  style: TextStyle(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: formModel.user?.firstName,
                        decoration: const InputDecoration(
                          hintText: 'First name',
                        ),
                        onChanged: (value) {
                          formModel.user!.firstName = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.firstName;
                        },
                      ),
                    ),
                    const Text(
                      ' ',
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: formModel.user?.lastName,
                        decoration: const InputDecoration(
                          hintText: 'Last name',
                        ),
                        onChanged: (value) {
                          formModel.user!.lastName = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.lastName = value.toString();
                        },
                      ),
                    ),
                    // const Text(
                    //   'mm/dd',
                    //   style: TextStyle(
                    //     backgroundColor: Colors.grey,
                    //   ),
                    // ),
                    const Text(
                      ' ',
                      style: TextStyle(
                          //backgroundColor: Colors.grey,
                          ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: TextFormField(
                        initialValue: formModel.user?.mm,
                        //?
                        //keyboardType: TextInputType.datetime,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        //minLength: 2,
                        //maxLength: 2,
                        decoration: const InputDecoration(
                          hintText: 'mm',
                        ),
                        onChanged: (value) {
                          formModel.user!.mm = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.mm = value.toString();
                        },
                      ),
                    ),
                    const Text(
                      '/ ',
                      style: TextStyle(
                          //backgroundColor: Colors.grey,
                          ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: TextFormField(
                        initialValue: formModel.user?.dd,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        //minLength: 2,
                        //maxLength: 2,
                        decoration: const InputDecoration(
                          hintText: 'dd',
                        ),
                        onChanged: (value) {
                          formModel.user!.dd = value.toString();
                        },
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.dd = value.toString();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '* required fields',
                style: Theme.of(context).textTheme.caption,
              ),

              /// clean, show example, preview
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.dbKey != null)
                      ElevatedButton(
                        child: const Text(
                          'back',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    if (widget.dbKey == null)
                      ElevatedButton(
                        child: const Text(
                          'clean',
                          style: TextStyle(
                              //color: Colors.white,
                              ),
                        ),
                        onPressed: () {
                          setState(() {
                            formModel = Poetic.form();
                            _formKey.currentState!.reset();
                          });
                        },
                      ),
                    if (widget.dbKey == null)
                      ElevatedButton(
                        child: const Text(
                          'show example',
                          style: TextStyle(
                            color: Colors.lime,
                          ),
                        ),
                        onPressed: () {
                          previewNotifier.changeMyData(
                              Poetic.fromJson(jsonDecode(beAllOneJson)));
                        },
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        /// todo
                        /// preview and saving in one place doesn't make sense
                        /// 2 step form or preview button
                        previewNotifier.changeMyData(formModel);

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            var key = await formModel.save(widget.dbKey);
                            SinglePoetic.goHere(context,
                                poetic: formModel, dbKey: key);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error occurred.')),
                            );
                          } finally {}

                          //Navigator.pushNamed(
                          //context, UserPoeticList.routeName);
                        }
                      },
                      child: const Text(
                        'save',
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),

                      ///todo Preview should be here, on the same screen
                      ///and save button right after it
                      ///2 Wraps form
                    ),
                  ],
                ),
              ),

              ///Preview
              ValueListenableBuilder<Poetic>(
                ///keeping for other possible changes
                ///valueListenable: _defaultNotifier,
                valueListenable: previewNotifier,
                builder: (context, Poetic value, _) {
                  return PoeticPreview(
                    model: value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
