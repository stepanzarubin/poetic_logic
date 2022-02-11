import 'package:flutter/material.dart';
import 'package:poetic_logic/models/poetic.dart';

class PoeticPreview extends StatelessWidget {
  const PoeticPreview({
    Key? key,
    required this.model,
    this.addedDisplayLimit = 0,
  }) : super(key: key);

  final Poetic model;

  /// Shorter version by limiting number of displayed records
  /// 0 - unlimited
  final int addedDisplayLimit;

  @override
  Widget build(BuildContext context) {
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
        if (model.quote != null)
          QuoteWidget(
            model: model.quote!,
          ),
        const Text(
          'Then:',
          style: TextStyle(
            backgroundColor: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var logic in model.thenLogic)
          if (logic.isNotEmpty)
            SelectableText(
              logic,
            ),
        Text(
          model.getSignature(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        if (model.addedLogic.isNotEmpty) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(
              right: 8.0,
            ),
            child: Text(
              'Added:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          AddedLogicList(
            addedLogic: model.addedLogic,
            addedDisplayLimit: addedDisplayLimit,
          )
        ],

        /// TODO: Add your to this poetic
        /// for preview can be show as a disabled button
      ],
    );
  }
}

class QuoteWidget extends StatelessWidget {
  const QuoteWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final Quote model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SelectableText(
          model.text,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        SelectableText(
          '('
          '${model.title}, '
          '${model.year}: p. '
          '${model.pages}'
          ')',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class AddedLogicList extends StatelessWidget {
  const AddedLogicList({
    Key? key,
    required this.addedLogic,
    this.addedDisplayLimit = 0,
  }) : super(key: key);

  /// 0 - unlimited
  final int addedDisplayLimit;
  final List<AddedLogic> addedLogic;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.end,
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var i = 0;
            i <
                ((addedDisplayLimit != 0 &&
                        addedDisplayLimit < addedLogic.length)
                    ? addedDisplayLimit
                    : addedLogic.length);
            i++)
          AddedLogicWidget(
            addedLogic: addedLogic[i],
          )
      ],
    );
  }
}

class AddedLogicWidget extends StatelessWidget {
  const AddedLogicWidget({
    Key? key,
    required this.addedLogic,
  }) : super(key: key);

  final AddedLogic addedLogic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Container(
        // constraints: const BoxConstraints(
        //   minWidth: 350,
        //   maxWidth: 350,
        //   minHeight: 50,
        //   maxHeight: 50,
        // ),
        //padding: const EdgeInsets.all(2.0),
        //margin: const EdgeInsets.all(4.0),
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
          children: [
            for (var logic in addedLogic.thenLogic)
              SelectableText(
                logic,
                textAlign: TextAlign.right,
              ),
            Text(
              addedLogic.getSignature(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
