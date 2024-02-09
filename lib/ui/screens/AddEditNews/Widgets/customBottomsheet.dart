// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/customTextLabel.dart';

Future customBottomsheet({required BuildContext context, required String titleTxt, required int listLength, required NullableIndexedWidgetBuilder listViewChild}) {
  return showModalBottomSheet<dynamic>(
      context: context,
      elevation: 3.0,
      isScrollControlled: true,
      //it will be closed only when user click On Save button & not by clicking anywhere else in screen
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      enableDrag: false,
      builder: (BuildContext context) => Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  ((listLength > 8)
                      ? (0.90)
                      : (listLength > 5)
                          ? (0.62)
                          : (0.32))),
          padding: const EdgeInsetsDirectional.only(bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
          decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: UiUtils.getColorScheme(context).background),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextLabel(text: titleTxt, textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).primaryContainer)),
              Expanded(
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 25.0),
                      itemCount: listLength,
                      itemBuilder: listViewChild)),
            ],
          )));
}
