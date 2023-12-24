import 'package:flutter/material.dart';

/// By Gemini and me :)
class KeyboardView extends StatefulWidget {
  final Function(String) onKeyPressed;
  final BoxDecoration boxDecoration;

  const KeyboardView({super.key,
    required this.onKeyPressed,
    this.boxDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      color: Colors.white,
    ),
  });

  @override
  _KeyboardViewState createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  final List<List<String>> qwertyKeys = [
    ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Backspace'],
    ['Tab', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\'],
    ['Caps Lock', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'Enter'],
    ['Shift', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'Shift'],
    ['Ctrl', 'Win', 'Alt', 'Space', 'Alt', 'Ctrl'],
  ];

  final List<List<String>> arrowKeys = [
    ['Ins', 'Home', 'PgUp'],
    ['End', 'PgDn', 'Del'],
    ['', '▲', ''],
    ['◄', '↓', '►'],
  ];

  final List<List<String>> numpadKeys = [
    ['Num Lock', '/', '*', '-', '+'],
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['0', '.', 'Enter'],
  ];

  List<List<bool>> qwertyKeyToggledStates = [];
  List<List<bool>> arrowKeyToggledStates = [];
  List<List<bool>> numpadKeyToggledStates = [];

  @override
  void initState() {
    super.initState();
    qwertyKeyToggledStates = List.generate(
      qwertyKeys.length,
          (_) => List.filled(qwertyKeys[0].length, false),
    );
    arrowKeyToggledStates = List.generate(
      arrowKeys.length,
          (_) => List.filled(arrowKeys[0].length, false),
    );
    numpadKeyToggledStates = List.generate(
      numpadKeys.length,
          (_) => List.filled(numpadKeys[0].length, false),
    );
  }

  void toggleQwertyKeyState(int row, int col, {bool clear = false}) {
    // Deselect all other QWERTY keys except Ctrl, Shift, and Alt
    if (qwertyKeys[row][col] != 'Ctrl' && qwertyKeys[row][col] != 'Shift' && qwertyKeys[row][col] != 'Alt') {
      for (int i = 0; i < qwertyKeys.length; i++) {
        for (int j = 0; j < qwertyKeys[i].length; j++) {
          if (i != row || j != col) {
            if (qwertyKeys[i][j] != 'Ctrl' && qwertyKeys[i][j] != 'Shift' &&
                qwertyKeys[i][j] != 'Alt') {
              qwertyKeyToggledStates[i][j] = false;
            }
          }
        }
      }
    }

    if (!clear) {
      toggleArrowKeyState(0, 0, clear: true);
      toggleNumpadKeyState(0, 0, clear: true);
    }

    // Toggle the state of the selected key
    setState(() {
      if (!clear) {
        qwertyKeyToggledStates[row][col] = !qwertyKeyToggledStates[row][col];
      }
    });
  }

  void toggleArrowKeyState(int row, int col, {bool clear = false}) {
    // Deselect all other arrow keys except Ctrl, Shift, and Alt
    for (int i = 0; i < arrowKeys.length; i++) {
      for (int j = 0; j < arrowKeys[i].length; j++) {
        if (i != row || j != col) {
          if (arrowKeys[i][j] != 'Ctrl' && arrowKeys[i][j] != 'Shift' && arrowKeys[i][j] != 'Alt') {
            arrowKeyToggledStates[i][j] = false;
          }
        }
      }
    }

    if (!clear) {
      toggleQwertyKeyState(0, 0, clear: true);
      toggleNumpadKeyState(0, 0, clear: true);
    }

    // Toggle the state of the selected key
    setState(() {
      if (!clear) {
        arrowKeyToggledStates[row][col] = !arrowKeyToggledStates[row][col];
      }
    });
  }
  void toggleNumpadKeyState(int row, int col, {bool clear = false}) {
    // Deselect all other numpad keys except Ctrl, Shift, and Alt
    for (int i = 0; i < numpadKeys.length; i++) {
      for (int j = 0; j < numpadKeys[i].length; j++) {
        if (i != row || j != col) {
          if (numpadKeys[i][j] != 'Ctrl' && numpadKeys[i][j] != 'Shift' && numpadKeys[i][j] != 'Alt') {
            numpadKeyToggledStates[i][j] = false;
          }
        }
      }
    }

    if (!clear) {
      toggleArrowKeyState(0, 0, clear: true);
      toggleQwertyKeyState(0, 0, clear: true);
    }

    // Toggle the state of the selected key
    setState(() {
      if (!clear) {
        numpadKeyToggledStates[row][col] = !numpadKeyToggledStates[row][col];
      }
    });
  }
  Widget buildKey(
      List<List<String>> keys,
      List<List<bool>> toggledStates,
      int row,
      int col,
      Function(int, int) toggleKeyState,
      ) {
    final key = keys[row][col];
    final isToggled = toggledStates[row][col];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          toggleKeyState(row, col);
          widget.onKeyPressed(key);
        },
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: widget.boxDecoration.copyWith(
            color: isToggled ? Colors.grey[300] : Colors.white,
          ),
          child: Center(
            child: Text(
              key,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: qwertyKeys.asMap().entries.map((entry) {
                final row = entry.key;
                final keys = entry.value;

                return Expanded(
                  child: Row(
                    children: keys.asMap().entries.map((keyEntry) {
                      final col = keyEntry.key;

                      return buildKey(
                        qwertyKeys,
                        qwertyKeyToggledStates,
                        row,
                        col,
                        toggleQwertyKeyState,
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: arrowKeys.asMap().entries.map((entry) {
                final row = entry.key;
                final keys = entry.value;

                return Expanded(
                  child: Row(
                    children: keys.asMap().entries.map((keyEntry) {
                      final col = keyEntry.key;

                      return buildKey(
                        arrowKeys,
                        arrowKeyToggledStates,
                        row,
                        col,
                        toggleArrowKeyState,
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: numpadKeys.asMap().entries.map((entry) {
                final row = entry.key;
                final keys = entry.value;

                return Expanded(
                  child: Row(
                    children: keys.asMap().entries.map((keyEntry) {
                      final col = keyEntry.key;

                      return buildKey(
                        numpadKeys,
                        numpadKeyToggledStates,
                        row,
                        col,
                        toggleNumpadKeyState,
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}