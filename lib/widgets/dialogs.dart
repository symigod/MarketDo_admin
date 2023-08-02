import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Widget confirmDialog(
        context, String title, String message, void Function() onPressed) =>
    AlertDialog(title: Text(title), content: Text(message), actions: [
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('NO', style: TextStyle(color: Colors.red))),
      TextButton(
          onPressed: onPressed,
          child: Text('YES', style: TextStyle(color: Colors.green.shade900)))
    ]);

Widget errorDialog(BuildContext context, String message) =>
    AlertDialog(title: const Text('ERROR'), content: Text(message), actions: [
      TextButton(
          onPressed: () => Navigator.pop(context), child: const Text('OK'))
    ]);

Widget successDialog(BuildContext context, String message) =>
    AlertDialog(title: Text(message), actions: [
      TextButton(
          onPressed: () => Navigator.pop(context), child: const Text('OK'))
    ]);

String generateToken() => String.fromCharCodes(
    List.generate(100, (index) => Random().nextInt(33) + 89));

String numberToString(double number) => number < 1
    ? NumberFormat('0.00').format(number)
    : NumberFormat('#,###.00').format(number);

String dateTimeToString(Timestamp timestamp) =>
    DateFormat('MMM dd, yyyy').format(timestamp.toDate()).toString();

Future<void> openURL(context, String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => errorDialog(context, 'Cannot open "$url"'));
  }
}

FaIcon categoryIcon(category) {
  switch (category) {
    case 'Clothing and Accessories':
      category = FontAwesomeIcons.shirt;
      break;

    case 'Food and Beverages':
      category = FontAwesomeIcons.utensils;
      break;

    case 'Household Items':
      category = FontAwesomeIcons.couch;
      break;

    case 'Personal Care':
      category = FontAwesomeIcons.handSparkles;
      break;

    case 'School and Office Supplies':
      category = FontAwesomeIcons.folderOpen;
      break;

    case 'Others':
      category = FontAwesomeIcons.ellipsis;
      break;
  }
  return FaIcon(category);
}

DataColumn dataColumn(String label) => DataColumn(
    label: Expanded(child: Text(label, textAlign: TextAlign.center)));
