import 'package:flutter/material.dart';
import 'package:poetic_logic/models/poetic.dart';

///todo get rid of code duplication for displaying if/then
class PoeticPreview extends StatelessWidget {
  const PoeticPreview({
    Key? key,
    required this.model,
    this.addedLimit = 0,
  }) : super(key: key);

  final Poetic model;

  /// Display shorter version by limiting number of added logic
  final int addedLimit;

  @override
  Widget build(BuildContext context) {
    List<Widget> addedLogicSection = [];

    if (model.addedLogic.isNotEmpty && addedLimit != 0) {
      addedLogicSection.add(const Divider());
      addedLogicSection.add(const Padding(
        padding: EdgeInsets.only(
          right: 8.0,
        ),
        child: Text(
          'Added logic:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
      ));

      int addedCounter = 0;
      for (var addedLogicMap in model.addedLogic) {
        List<Widget> addedLogicWidgets = [];
        for (var logic in addedLogicMap.thenLogic) {
          addedLogicWidgets.add(
            SelectableText(
              logic,
              textAlign: TextAlign.right,
            ),
          );
        }

        addedLogicWidgets.add(
          Text(
            addedLogicMap.getSignature(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        ///todo 80% right
        ///8/10 scale
        ///and better be of the size of the content, smaller the text
        ///smaller the section per user
        ///          FractionallySizedBox(
        //             alignment: Alignment.topRight,
        //             widthFactor: 0.8,

        if (++addedCounter == addedLimit) {
          addedLogicWidgets.add(const Text(
            '.........',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ));
        }

        /// todo
        /// ConstrainedBox
        addedLogicSection.add(
          Container(
            ///does not work here
            // constraints: const BoxConstraints(
            //   minWidth: 10,
            //   maxWidth: 50,
            // ),
            padding: const EdgeInsets.all(2.0),
            margin: const EdgeInsets.all(4.0),
            //color: Colors.blueGrey.shade100,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              // border: Border.all(
              //   width: 0.1,
              // ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              //direction: Axis.vertical,
              //crossAxisAlignment: WrapCrossAlignment.end,
              //alignment: WrapAlignment.end,
              //spacing: 3,
              children: addedLogicWidgets,
            ),
          ),
        );

        if (addedCounter == addedLimit) {
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'If:',
          style: TextStyle(
            backgroundColor: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SelectableText(model.ifLogic),
        const Text(
          'Based on quote:',
          style: TextStyle(
            backgroundColor: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),

        /// todo Column for 2 widgets? try removing it
        /// ...[widget, widget]
        if (model.quote != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SelectableText(
                model.quote!.text,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              SelectableText(
                '('
                '${model.quote!.title}, '
                '${model.quote!.year}: p. '
                '${model.quote!.pages}'
                ')',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        const Text(
          'Then:',
          style: TextStyle(
            backgroundColor: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var logic in model.thenLogic)
          SelectableText(
            logic,
          ),
        Text(
          model.getSignature(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        ...addedLogicSection,
      ],
    );
  }
}
