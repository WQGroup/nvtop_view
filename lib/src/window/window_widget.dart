//自定义右侧 最小化 最大化和关闭按钮
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  final buttonColors = WindowButtonColors(
      iconNormal: Colors.grey[600], mouseOver: Colors.grey[400], mouseDown: Colors.grey[400], iconMouseOver: Colors.grey[600], iconMouseDown: Colors.grey[600]);

  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: WindowButton(
            iconBuilder: (buttonContext) => const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 10,
                child: Icon(
                  Icons.settings,
                  color: Colors.grey,
                ),
              ),
            ),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: MinimizeWindowButton(colors: buttonColors),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: appWindow.isMaximized
              ? RestoreWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                )
              : MaximizeWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: CloseWindowButton(colors: buttonColors),
        )
      ],
    );
  }
}
