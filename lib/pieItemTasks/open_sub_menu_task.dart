import 'package:pie_menyu/db/pie_item_task.dart';

class OpenSubMenuTask extends PieItemTask {
  OpenSubMenuTask();

  set subMenuId(int pieMenuId) {
    arguments = [pieMenuId.toString()];
  }

  int get subMenuId => int.parse(arguments[0]);
}