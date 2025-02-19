import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:rive_animated_icon/rive_animated_icon.dart';

Widget AnimationIcons_activity() {
  return AnimateIcon(
    key: UniqueKey(),
    onTap: () {},
    iconType: IconType.continueAnimation,
    height: 24,
    width: 24,
    color: Colors.red,
    animateIcon: AnimateIcons.activity,
  );
}

// Widget AnimationIcons_home() {
//   return RiveAnimatedIcon(
//     riveIcon: RiveIcon.sound,
//     width: 50,
//     height: 50,
//     color: Colors.green,
//     strokeWidth: 3,
//     loopAnimation: false,
//     onTap: () {},
//     onHover: (value) {},
//   );
// }

class AnimationIconsWidget extends StatefulWidget {
  const AnimationIconsWidget({super.key});

  @override
  State<AnimationIconsWidget> createState() => _AnimationIconsWidgetState();
}

class _AnimationIconsWidgetState extends State<AnimationIconsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Animated Icons")),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Adjust as needed
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: AnimateIcons.values.length,
        itemBuilder: (context, index) {
          return AnimateIcon(
            key: UniqueKey(),
            onTap: () {},
            iconType: IconType.continueAnimation,
            height: 48,
            width: 48,
            color: Colors.red,
            animateIcon: AnimateIcons.values[index],
          );
        },
      ),
    );
  }
}
