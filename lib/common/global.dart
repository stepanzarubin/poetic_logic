import 'package:flutter/material.dart';

void scMsg(BuildContext context, msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, textAlign: TextAlign.center)),
  );
}
