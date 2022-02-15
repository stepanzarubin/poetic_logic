import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:poetic_logic/common/app_state.dart';
import 'package:poetic_logic/common/app_state_scope.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/common/global.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/widgets/poetic_view.dart';
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
  State<PoeticFormStatefulWidget> createState() => _PoeticFormStatefulWidgetState();
}

class _PoeticFormStatefulWidgetState extends State<PoeticFormStatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool updateNotFoundScenario = false;
  Poetic formModel = Poetic.form();
  late final PreviewNotifier previewNotifier;

  @override
  void initState() {
    super.initState();

    // on update
    if (widget.dbKey != null) {
      var box = Hive.box(localDb);
      var record = box.get(widget.dbKey);
      if (record == null) {
        updateNotFoundScenario = true;
      } else {
        updateNotFoundScenario = false;

        /// TODO: user is null
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
      /// user removed all items, them I am keeping one field
      /// and not showing remove button for empty row
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
                hintText: formModel.thenLogic.length == 1 ? 'Poetic logic' : null,
              ),
              onChanged: (value) {
                formModel.thenLogic[index] = value.toString();
                // if (value.isEmpty) {
                //   formModel.thenLogic[index] = '';
                // } else {
                //   formModel.thenLogic[index] = value;
                // }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  /// At least one record is required
                  /// it is possible not to fill the first but it's ok
                  if (index == 0) {
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

  /// For new record prefill user from [AppState]
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
                    formModel.ifLogic = value.toString();
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
                          formModel.quote!.text = value.toString();
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
                          formModel.quote!.title = value.toString();
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
                          formModel.quote!.year = value.toString();
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
                          formModel.quote!.pages = value.toString();
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
                          /// TODO: user is null on edit
                          formModel.user!.firstName = value.toString();
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

              /// Buttons
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
                          'clear',
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
                        ),
                        onPressed: () {
                          previewNotifier.changeMyData(Poetic.fromJson(jsonDecode(beAllOneJson)));
                        },
                      ),
                    ElevatedButton(
                      child: const Text(
                        'preview',
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          previewNotifier.changeMyData(formModel);
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'save',
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await formModel.save(widget.dbKey);
                            SinglePoetic.goHere(context, poetic: formModel, dbKey: formModel.dbKey);
                            //Navigator.pushNamed(context, UserPoeticList.routeName);
                          } catch (e) {
                            scMsg(context, 'Error occurred.');
                          } finally {}
                        }
                      },
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
                  return PoeticView(
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
