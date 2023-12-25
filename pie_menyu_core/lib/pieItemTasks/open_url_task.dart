library pie_menyu_core;

import 'package:pie_menyu_core/db/pie_item_task.dart';

import '../executor/executable.dart';

class OpenUrlTask extends PieItemTask with Executable {
  OpenUrlTask() : super(taskType: PieItemTaskType.openUrl) {
    _fieldCheck();
  }

  OpenUrlTask.from(PieItemTask pieItemTask) : super.from(pieItemTask) {
    _fieldCheck();
  }

  _fieldCheck() {
    if (arguments.length != 1) {
      arguments = [""];
    }
    taskType = PieItemTaskType.openUrl;
  }

  set url(String value) {
    arguments = [value];
  }

  String get url => arguments[0];

  @override
  Future<void> execute() async {
    // TODO: implement execute
  }
}
