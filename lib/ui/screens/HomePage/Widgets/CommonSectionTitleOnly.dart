// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/app/routes.dart';
import 'package:news/utils/uiUtils.dart';

Widget commonSectionTitleOnly(FeatureSectionModel model, BuildContext context) {
  return ListTile(
    minVerticalPadding: 5,
    contentPadding: EdgeInsets.zero,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: CustomTextLabel(
                text: model.title!,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ],
    ),
    /*
    subtitle: CustomTextLabel(
        text: model.shortDescription!,
        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
        softWrap: true,
        maxLines: 3,
        overflow: TextOverflow.ellipsis),

     */
  );
}
