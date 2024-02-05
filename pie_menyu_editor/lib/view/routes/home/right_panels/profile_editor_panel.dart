import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pie_menyu_core/db/db.dart';
import 'package:pie_menyu_core/db/pie_menu.dart';
import 'package:pie_menyu_core/db/profile.dart';
import 'package:pie_menyu_editor/view/widgets/flat_button.dart';
import 'package:pie_menyu_editor/view/widgets/key_press_recorder.dart';
import 'package:pie_menyu_editor/view/widgets/minimal_text_field.dart';
import 'package:pie_menyu_editor/view/widgets/outlined_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pie_menu_editor/pie_menu_editor_route.dart';
import '../home_page_view_model.dart';

class ProfileEditorPanel extends StatefulWidget {
  const ProfileEditorPanel({super.key});

  @override
  State<ProfileEditorPanel> createState() => _ProfileEditorPanelState();
}

class _ProfileEditorPanelState extends State<ProfileEditorPanel> {
  final double tableRowGap = 10;

  @override
  Widget build(BuildContext context) {
    final homePageViewModel = context.watch<HomePageViewModel>();
    final activeProfile = context
        .select<HomePageViewModel, Profile>((value) => value.activeProfile);
    final allPieMenuExceptInProfile =
        homePageViewModel.getAllPieMenusExceptIn(activeProfile);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(homePageViewModel, activeProfile),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: SingleChildScrollView(
                child: buildPieMenuList(homePageViewModel, activeProfile),
              ),
            ),
          ),
          ExpansionTile(
            shape: Border.all(color: Colors.transparent),
            title: Text("title-add-pie-menu-from-other-profiles".tr()),
            children: [
              Wrap(
                children: [
                  for (PieMenu pm in allPieMenuExceptInProfile)
                    TextButton(
                      onPressed: () {
                        homePageViewModel.addPieMenuTo(activeProfile, pm);
                      },
                      child: Text("${pm.name} (id: ${pm.id})"),
                    )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  void setPieMenuName(String name, PieMenu pieMenu) async {
    setState(() {
      pieMenu.name = name;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text("pie-menu-name-saved".tr())));

    await context.read<HomePageViewModel>().putPieMenu(pieMenu);
  }

  HotKey? getPieMenuHotkey(PieMenu pieMenu, Profile profile) {
    try {
      HotkeyToPieMenuId htpm = profile.hotkeyToPieMenuIdList
          .firstWhere((element) => element.pieMenuId == pieMenu.id);

      return HotKey(htpm.keyCode, modifiers: htpm.keyModifiers);
    } catch (e) {
      return null;
    }
  }

  addHotkeyToProfile(Profile profile, HotKey hotKey, int pieMenuId) async {
    List<HotkeyToPieMenuId> hotkeyToPieMenuIdList = profile
        .hotkeyToPieMenuIdList
        .where((element) => element.pieMenuId != pieMenuId)
        .toList();
    hotkeyToPieMenuIdList.add(HotkeyToPieMenuId.fromHotKey(hotKey, pieMenuId));

    profile.hotkeyToPieMenuIdList = hotkeyToPieMenuIdList;
    context.read<HomePageViewModel>().putProfile(profile);
  }

  removeHotkeyFromProfile(Profile profile, HotKey hotKey) async {
    List<HotkeyToPieMenuId> hotkeyToPieMenuIdList = profile
        .hotkeyToPieMenuIdList
        .where((element) =>
            element.keyCode != hotKey.keyCode ||
            element.keyModifiers.contains(KeyModifier.shift) !=
                hotKey.modifiers?.contains(KeyModifier.shift) ||
            element.keyModifiers.contains(KeyModifier.control) !=
                hotKey.modifiers?.contains(KeyModifier.control) ||
            element.keyModifiers.contains(KeyModifier.alt) !=
                hotKey.modifiers?.contains(KeyModifier.alt))
        .toList();

    profile.hotkeyToPieMenuIdList = hotkeyToPieMenuIdList;
    context.read<HomePageViewModel>().putProfile(profile);
  }

  buildHeader(HomePageViewModel homePageViewModel, Profile activeProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          activeProfile.name,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        Expanded(child: Container()),
        IconButton(
          onPressed: () async {
            bool result = await homePageViewModel.toggleActiveProfile();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                content: Text((result
                        ? "message-profile-enabled"
                        : "message-profile-disabled")
                    .tr())));

            launchUrl(Uri.parse("piemenyu://reload"));
          },
          icon: Icon(
            activeProfile.enabled ? Icons.pause : Icons.play_arrow_outlined,
            size: 22,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FlatButton(
            onPressed: () => homePageViewModel.createPieMenuIn(activeProfile),
            icon: FontAwesomeIcons.plus,
            label: Text("button-new-pie-menu".tr()),
          ),
        )
      ],
    );
  }

  buildPieMenuList(HomePageViewModel homePageViewModel, Profile activeProfile) {
    final allPieMenuInProfile = homePageViewModel.getPieMenusOf(activeProfile);

    return Table(
      columnWidths: const {
        0: FractionColumnWidth(0.07),
        1: FractionColumnWidth(0.51),
        2: FractionColumnWidth(0.26),
        3: FractionColumnWidth(0.16),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Text('', style: Theme.of(context).textTheme.labelMedium),
            Text("table-header-name".tr(),
                style: Theme.of(context).textTheme.labelMedium),
            Text("table-header-hotkey".tr(),
                style: Theme.of(context).textTheme.labelMedium),
            Text("table-header-actions".tr(),
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        for (var pieMenu in allPieMenuInProfile)
          TableRow(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Draggable(
                  data: pieMenu.id,
                  feedback: Text(
                    pieMenu.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: const Size(32, 32),
                    ),
                    onPressed: () {
                      homePageViewModel.makePieMenuUniqueIn(
                          activeProfile, pieMenu);
                    },
                    child: Text(pieMenu.profiles.length.toString()),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 25, 0),
                child: MinimalTextField(
                  key: ValueKey(pieMenu.id),
                  onSubmitted: (String? name) {
                    setPieMenuName(name ?? "", pieMenu);
                  },
                  content: pieMenu.name,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 8, 0),
                child: KeyPressRecorder(
                  key: ValueKey(pieMenu.id),
                  initialHotkey: getPieMenuHotkey(pieMenu, activeProfile),
                  onHotKeyRecorded: (newHotkey) => {
                    addHotkeyToProfile(activeProfile, newHotkey, pieMenu.id)
                  },
                  onClear: (prevHotkey) =>
                      removeHotkeyFromProfile(activeProfile, prevHotkey),
                  validation: (hotkey) {
                    for (var htpm in activeProfile.hotkeyToPieMenuIdList) {
                      if (htpm.keyCode == hotkey.keyCode &&
                          htpm.keyModifiers.contains(KeyModifier.shift) ==
                              hotkey.modifiers?.contains(KeyModifier.shift) &&
                          htpm.keyModifiers.contains(KeyModifier.control) ==
                              hotkey.modifiers?.contains(KeyModifier.control) &&
                          htpm.keyModifiers.contains(KeyModifier.alt) ==
                              hotkey.modifiers?.contains(KeyModifier.alt)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red[400],
                            content: Text("message-hotkey-is-used".tr())));
                        return false;
                      }
                    }
                    return true;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedIconButton(
                      icon: FontAwesomeIcons.pencil,
                      onPressed: () async {
                        final db = context.read<Database>();
                        final pm = (await db.getPieMenus(ids: [pieMenu.id]))
                            .firstOrNull;

                        if (pm == null || !context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PieMenuEditorRoute(pm),
                          ),
                        );
                      },
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    OutlinedIconButton(
                      icon: FontAwesomeIcons.trash,
                      onPressed: () {
                        homePageViewModel.removePieMenuFrom(
                            activeProfile, pieMenu);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        // Allow delete up to a single level.
                        scaffoldMessenger.clearSnackBars();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text("message-pie-menu-deleted".tr()),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            action: SnackBarAction(
                              label: "label-undo".tr(),
                              onPressed: () {
                                homePageViewModel.cancelDelete();
                              },
                            ),
                          ),
                        );
                      },
                      color: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
