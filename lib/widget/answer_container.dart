import 'package:flutter/material.dart';

class WhiteContainerWidget extends StatelessWidget {
  const WhiteContainerWidget({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Center(
            child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        )),
      ),
    );
  }
}
