import 'package:flutter/material.dart';
// import 'package:flutter_ebook/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

var _list = ['smile', 'icon', 'normal'];

class LoadingCustom extends StatelessWidget {
  const LoadingCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _show(),
        child: const Text("click me"),
      ),
    );
  }

  void _show() async {
    SmartDialog.show(
        alignment: Alignment.centerRight, builder: (_) => playRecord());
  }

  Widget playRecord() {
    return Row(
      children: [
        Text(
          'data',
          selectionColor: Colors.white,
        )
      ],
    );
  }
}
