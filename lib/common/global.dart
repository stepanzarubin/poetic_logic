import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<bool> isConnectivityConnected() async {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

void scMsg(BuildContext context, msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, textAlign: TextAlign.center)),
  );
}
