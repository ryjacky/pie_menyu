import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';
import 'package:gap/gap.dart';
import 'package:localization/localization.dart';
import 'package:pie_menyu_core/pieItemTasks/mouse_click_task.dart';
import 'package:pie_menyu_editor/view/routes/pie_menu_editor/pie_menu_state.dart';
import 'package:provider/provider.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'pie_item_task_card.dart';

class MouseClickTaskCard extends StatefulWidget {
  final MouseClickTask mouseClickTask;
  final int order;
  final VoidCallback? onDelete;

  const MouseClickTaskCard(
      {super.key,
      required this.mouseClickTask,
      required this.order,
      this.onDelete});

  @override
  State<MouseClickTaskCard> createState() => _MouseClickTaskCardState();
}

class _MouseClickTaskCardState extends State<MouseClickTaskCard> {
  final List<bool> _isSelected = [true, false, false];
  bool _isListening = false;

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(handleEnter);

    switch (widget.mouseClickTask.mouseButton) {
      case MouseButton.left:
        _isSelected[0] = true;
        _isSelected[1] = false;
        _isSelected[2] = false;
        break;
      case MouseButton.middle:
        _isSelected[0] = false;
        _isSelected[1] = true;
        _isSelected[2] = false;
        break;
      case MouseButton.right:
        _isSelected[0] = false;
        _isSelected[1] = false;
        _isSelected[2] = true;
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PieItemTaskCard(
      onDelete: widget.onDelete,
      label: "label-mouse-click-task".i18n(),
      children: [
        ListTile(
          leading: Text("label-position".i18n()),
          title:
              Text("(${widget.mouseClickTask.x}, ${widget.mouseClickTask.y})"),
          trailing: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.background),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  content: Text("hint-select-mouse-pos".i18n())));
              setState(() {
                _isListening = !_isListening;
              });
            },
            child: Text(
                (_isListening ? "label-listening" : "label-listen").i18n()),
          ),
        ),
        ListTile(
          leading: Text(
            "label-button".i18n(),
          ),
          trailing: ToggleButtons(
            borderRadius: BorderRadius.circular(10),
            isSelected: _isSelected,
            onPressed: (index) {
              setState(
                () {
                  for (int i = 0; i < _isSelected.length; i++) {
                    _isSelected[i] = (i == index);
                  }

                  MouseButton btn = MouseButton.left;
                  if (index == 1) {
                    btn = MouseButton.middle;
                  } else if (index == 2) {
                    btn = MouseButton.right;
                  }

                  final state = context.read<PieMenuState>();
                  final pieItem = state.activePieItem;
                  if (pieItem != null) {
                    state.updateTaskIn(
                        pieItem, widget.mouseClickTask..mouseButton = btn);
                  }
                },
              );
            },
            children: [
              Text("label-left-short".i18n()),
              Text("label-middle-short".i18n()),
              Text("label-right-short".i18n()),
            ],
          ),
        ),
        const Gap(10),
      ],
    );
  }

  bool handleEnter(KeyEvent event) {
    if (!_isListening || event.logicalKey != LogicalKeyboardKey.enter) {
      return false;
    }

    screenRetriever.getCursorScreenPoint().then((mousePos) {
      widget.mouseClickTask
        ..x = mousePos.dx.toInt()
        ..y = mousePos.dy.toInt();

      final state = context.read<PieMenuState>();
      final pieItem = state.activePieItem;
      if (pieItem != null) {
        state.updateTaskIn(pieItem, widget.mouseClickTask);
      }

      setState(() {
        _isListening = false;
      });
    });

    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(handleEnter);
    super.dispose();
  }
}
