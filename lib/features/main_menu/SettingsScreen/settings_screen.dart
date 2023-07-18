import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import screens
import 'settings_screen_controller.dart';
//

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final controller = SettingsScreenController(context: context);

    return WillPopScope(
        onWillPop: () async {
          return controller.handleOnWillPop();
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Image.asset(
                  // this is where the background goes
                  "resources/images/backgrounds/not_zen.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                _SettingsScreenMainColumnWidget(
                    controller: controller, screenSize: screenSize),
              ],
            ),
          ),
        ));
  }
}

class _SettingsScreenMainColumnWidget extends StatelessWidget {
  final SettingsScreenController controller;
  final Size screenSize;
  const _SettingsScreenMainColumnWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: screenSize.width,
          color: Colors.pink.withOpacity(0.5),
          height: screenSize.height / 8,
          child: Text("settings toolbar goes here"),
        ),
        Expanded(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              width: screenSize.width,
              color: Colors.grey.withOpacity(0.25),
              child: Column(
                children: [
                  //
                  //Main column here
                  //
                  Container(
                    padding: EdgeInsets.all(screenSize.width / 15),
                    width: screenSize.width,
                    color: Colors.lime.withOpacity(0.5),
                    child: _SettingsScreenCupertinoSlider(
                      controller: controller,
                      allocatedHeight: 100,
                      allocatedWidth: screenSize.width * 13 / 15,
                      description: "Blitz Duration (seconds)",
                      sliderValueListenable: controller.blitzDurationNotifier,
                      onValueChanged:
                          controller.handleBlitzDurationSliderChanged,
                      onValueChangedEnd:
                          controller.handleBlitzDurationSliderChangedEnd,
                      min: 10,
                      max: 180,
                      divisions: 17,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenSize.width / 15),
                    width: screenSize.width,
                    color: Colors.blueGrey.withOpacity(0.5),
                    child: _SettingsScreenSwitch(
                        controller: controller,
                        allocatedWidth: screenSize.width * 13 / 15,
                        allocatedHeight: 50,
                        description: "Night Mode",
                        switchValueListenable:
                        controller.isNightModeNotifier,
                        onValueChanged: controller.handleNightModeChanged,
                    ),
                  ),
                  Container(
                    width: screenSize.width,
                    color: Colors.green.withOpacity(0.5),
                    padding: EdgeInsets.all(screenSize.width / 15),
                    child: _SettingsScreenOptionPicker(
                      controller: controller,
                      allocatedWidth: screenSize.width * 13 / 15,
                      allocatedHeight: null,
                      description: "settings 1 with no height param",
                      optionPickerValueListenable:
                          controller.dropdown1ValueNotifier,
                      optionPickerOnChanged: controller.handleDropdown1Changed,
                      optionPickerItems: ["item1", "item2", "item3", "item4"],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenSize.width / 15),
                    width: screenSize.width,
                    color: Colors.brown.withOpacity(0.5),
                    child: _SettingsScreenOptionPicker(
                      controller: controller,
                      allocatedWidth: screenSize.width * 13 / 15,
                      allocatedHeight: 200,
                      description:
                          "settingu two 1 with very long description ipsum lorem dolor sit amet ipsum lorem dolor sit amet ipsum lorem dolor sit amet ipsum lorem dolor sit amet ipsum lorem dolor sit amet ipsum lorem dolor sit amet ",
                      optionPickerValueListenable:
                          controller.dropdown1ValueNotifier,
                      optionPickerOnChanged: controller.handleDropdown1Changed,
                      optionPickerItems: ["item1", "item2", "item3", "item4"],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenSize.width / 15),
                    width: screenSize.width,
                    color: Colors.purple.withOpacity(0.5),
                    child: _SettingsScreenSwitch(
                        controller: controller,
                        allocatedWidth: screenSize.width * 13 / 15,
                        allocatedHeight: 200,
                        description: "test switcheerooooo",
                        switchValueListenable:
                            controller.switchTestBoolNotifier,
                        onValueChanged: controller.handleTestSwitchChanged),
                  )
                  //
                  // Main column here
                  //
                ],
              ),
            ),
          ),
        ))
      ],
    );
  }
}

class _SettingsScreenSwitch extends StatelessWidget {
  final SettingsScreenController controller;
  final double? allocatedHeight;
  final double? allocatedWidth;
  final String description;
  final ValueNotifier<bool> switchValueListenable;
  final void Function(bool) onValueChanged;
  const _SettingsScreenSwitch({
    required this.controller,
    this.allocatedHeight,
    this.allocatedWidth,
    required this.description,
    required this.switchValueListenable,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: allocatedHeight,
          width: allocatedWidth != null ? allocatedWidth! * 4 / 9 : null,
          color: Colors.black.withOpacity(0.1),
          child: Center(child: Text(description)),
        ),
        const VerticalDivider(color: Colors.black),
        ValueListenableBuilder(
            valueListenable: switchValueListenable,
            builder: (context, switchValue, _) {
              return Container(
                height: allocatedHeight,
                width: allocatedWidth != null ? allocatedWidth! * 4 / 9 : null,
                color: Colors.black.withOpacity(0.1),
                child: Switch(value: switchValue, onChanged: onValueChanged),
              );
            }
        ),
      ],
    );
  }
}

class _SettingsScreenCupertinoSlider extends StatelessWidget {
  final SettingsScreenController controller;
  final double? allocatedHeight;
  final double? allocatedWidth;
  final String description;
  final ValueNotifier<double> sliderValueListenable;
  final void Function(double) onValueChanged;
  final void Function(double)? onValueChangedEnd;
  final double? min;
  final double? max;
  final int? divisions;
  const _SettingsScreenCupertinoSlider({
    required this.controller,
    this.allocatedHeight,
    this.allocatedWidth,
    required this.description,
    required this.sliderValueListenable,
    required this.onValueChanged,
    this.onValueChangedEnd,
    this.min,
    this.max,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: sliderValueListenable,
        builder: (context, sliderValue, _) {
          return SizedBox(
            height: allocatedHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$description : $sliderValue"),
                Container(
                  width: allocatedWidth,
                  child: CupertinoSlider(
                    value: sliderValue,
                    onChanged: onValueChanged,
                    onChangeEnd: onValueChangedEnd,
                    min: min ?? 0,
                    max: max ?? 1,
                    divisions: divisions,
                  ),
                )
              ],
            ),
          );
        });
  }
}

class _SettingsScreenOptionPicker extends StatelessWidget {
  final SettingsScreenController controller;
  final double? allocatedHeight;
  final double? allocatedWidth;
  final String description;
  final ValueNotifier<String?> optionPickerValueListenable;
  final List<String> optionPickerItems;
  final Function optionPickerOnChanged;
  const _SettingsScreenOptionPicker({
    required this.controller,
    this.allocatedHeight,
    this.allocatedWidth,
    required this.description,
    required this.optionPickerValueListenable,
    required this.optionPickerItems,
    required this.optionPickerOnChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: allocatedHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: allocatedHeight,
            width: allocatedWidth != null ? allocatedWidth! * 4 / 9 : null,
            color: Colors.black.withOpacity(0.1),
            child: Text(description),
          ),
          const VerticalDivider(color: Colors.black),
          ValueListenableBuilder(
              valueListenable: optionPickerValueListenable,
              builder: (context, currentValue, _) {
                return Container(
                  height: allocatedHeight,
                  width:
                      allocatedWidth != null ? allocatedWidth! * 4 / 9 : null,
                  color: Colors.black.withOpacity(0.1),
                  child: DropdownButton(
                    isExpanded: true,
                    onChanged: (value) {
                      optionPickerOnChanged(value);
                    },
                    items: optionPickerItems
                        .map((item) =>
                            DropdownMenuItem(child: Text(item), value: item))
                        .toList(),
                    value: currentValue,
                  ),
                );
              }),
        ],
      ),
    );
  }
}
