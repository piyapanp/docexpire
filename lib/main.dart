// @dart=2.9
import 'package:flutter/material.dart';
import './ui/doclist.dart';

void main() => runApp(DocExpiryApp());

// ignore: use_key_in_widget_constructors
class DocExpiryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpire',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: DocList(),
    );
  }
}
