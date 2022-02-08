import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:poetic_logic/common/const.dart';
import 'package:poetic_logic/models/poetic.dart';
import 'package:poetic_logic/widgets/poetic_preview.dart';

class PreviewNotifier extends ValueNotifier<Poetic> {
  PreviewNotifier(Poetic value) : super(value);

  void changeMyData(Poetic value) {
    //todo is this correct?
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

  late final bool updateScenario;
  bool updateNotFoundScenario = false;

  // this checks if value has changed, I just need update each time on button press
  // final ValueNotifier<Poetic> _defaultNotifier =
  //     ValueNotifier<Poetic>(Poetic(poeticLogic: PoeticLogic()));

  Poetic formModel = Poetic(
    ifLogic: '',
    quote: Quote(),
    thenLogic: [],
    user: User(),
  );

  /// todo sense to have?
  Poetic previewModel = Poetic(
    ifLogic: 'Something.',
    quote: Quote.quote('Quote text (exactly)', 'Source title', '1675', '245'),
    thenLogic: ['Something else.'],
    user: User.user('First name', 'Last name', '01', '01'),
  );

  late final PreviewNotifier previewNotifier;

  @override
  void initState() {
    super.initState();

    if (widget.dbKey != null) {
      updateScenario = true;
      var box = Hive.box(poeticDb);
      var record = box.get(widget.dbKey);
      if (record == null) {
        updateNotFoundScenario = true;
      } else {
        updateNotFoundScenario = false;
        formModel = Poetic.fromJson(record);
        previewModel = Poetic.fromJson(record);
      }
    } else {
      updateScenario = false;
    }

    //new empty row for form
    formModel.thenLogic.add('');

    previewNotifier = PreviewNotifier(previewModel);
    previewNotifier.changeMyData(previewModel);
  }

  ///logic
  _removeThenLogic(int index) {
    setState(() {
      formModel.thenLogic.removeAt(index);

      //todo preview
      //do main form also listenable?
      //previewModel.thenLogic.removeAt(index);
    });
  }

  _addThenLogic() {
    setState(() {
      formModel.thenLogic.add('');
      previewModel.thenLogic.add('');
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
        //todo only add for row?
        //key: UniqueKey(),
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
                  previewModel.thenLogic[index] = '';
                } else {
                  formModel.thenLogic[index] = value;
                  previewModel.thenLogic[index] = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  previewModel.thenLogic[index] = '';
                } else {
                  previewModel.thenLogic[index] = value;
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
              child: Align(
                /// todo good only for small screens
                //alignment: index.isEven ? Alignment.bottomLeft : Alignment.topRight,
                child: IconButton(
                  onPressed: () => _removeThenLogic(index),
                  icon: const Icon(Icons.remove_circle_outlined),
                ),
              ),
            )
          else
            SizedBox(
              width: 55,
              height: 58,
              child: Align(
                //todo move even lover to avoid clicking previous remove button
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

  @override
  Widget build(BuildContext context) {
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
                //on first launch keyboard is overlapping part of a screen
                //autofocus: true,
                initialValue: formModel.ifLogic,
                minLines: 1,
                maxLines: 10,
                validator: (value) {
                  previewModel.ifLogic = value ?? '';
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
                          //isDense: true,
                          //border: OutlineInputBorder(),
                          ),

                      validator: (value) {
                        previewModel.quote!.text = value ?? '';
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
                          //isDense: true,
                          //helperText: 'for specific notation use just title',
                        ),
                        validator: (value) {
                          previewModel.quote!.title = value ?? '';
                          return null;
                        },
                        onSaved: (value) {
                          //todo can be null? if Quote is not defined
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
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.quote!.year = value ?? '';
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
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.quote!.pages = value ?? '';
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
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.user!.firstName = value;
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.firstName = value;
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
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.user!.lastName = value;
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.lastName = value;
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
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.user!.mm = value;
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.mm = value;
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
                        //keyboardType: TextInputType.numberWithOptions(),
                        textAlign: TextAlign.center,
                        //minLength: 2,
                        //maxLength: 2,
                        decoration: const InputDecoration(
                          hintText: 'dd',
                          //isDense: true,
                        ),
                        validator: (value) {
                          previewModel.user!.dd = value;
                          return null;
                        },
                        onSaved: (value) {
                          formModel.user!.dd = value;
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
                    if (updateScenario)
                      ElevatedButton(
                        child: const Text(
                          '[back]',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    if (!updateScenario)
                      ElevatedButton(
                        child: const Text(
                          '[clean]',
                          style: TextStyle(
                              //color: Colors.white,
                              ),
                        ),
                        onPressed: () {
                          setState(() {
                            formModel.thenLogic.clear();
                            formModel.thenLogic.add('');
                            _formKey.currentState!.reset();
                          });
                        },
                      ),
                    if (!updateScenario)
                      ElevatedButton(
                        child: const Text(
                          '[show example]',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          previewNotifier.changeMyData(
                              Poetic.fromJson(jsonDecode(beAllOneJson)));
                        },
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        //showing preview and saving doesn't make sense
                        previewNotifier.changeMyData(previewModel);

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await formModel.save(widget.dbKey);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved.')),
                            );
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
                        '[save]',
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
