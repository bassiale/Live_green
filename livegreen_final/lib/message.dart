import 'package:flutter/material.dart';

class messagePage extends StatefulWidget {
  messagePage({Key? key}) : super(key: key);

  @override
  State<messagePage> createState() => _messagePageState();
}

class _messagePageState extends State<messagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("zio")),
      body: Column(children: const <Widget>[
        Text("lallalro"),
        Text("lalla la"),
      ]),
    );
  }
}
