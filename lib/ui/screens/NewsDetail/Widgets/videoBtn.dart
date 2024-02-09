// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/app/routes.dart';
import 'package:url_launcher/url_launcher.dart';


Widget videoBtn({
  required BuildContext context,
  required bool isFromBreak,
  NewsModel? model,
  BreakingNewsModel? breakModel,
}) {
  // Define Amazon logo color
  Color amazonLogoColor = Color(0xFFFF9900); // Amazon logo color
  String? audibleLink = isFromBreak ? breakModel?.contentValue : model?.contentValue;

  if ((breakModel != null && breakModel.contentValue != "") ||
      (model != null && model.contentValue != "")) {
    return InkWell(
      // InkWell properties
        onTap: () async {
          if (await canLaunch(audibleLink!)) {
            await launch(audibleLink);
          } else {
            print('Could not launch $audibleLink');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0), // Padding inside the container
          height: 50, // Height of the button
          decoration: BoxDecoration(
            color: amazonLogoColor, // Amazon logo color
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // To fit the content size
            children: [
              Icon(
                Icons.book_outlined, // Icon for Audible
                color: Colors.white, // Icon color
                size: 24, // Icon size
              ),
              SizedBox(width: 8), // Spacing between icon and text
              Text(
                "Open in Audible",
                style: TextStyle(
                  fontSize: 14, // Font size for the text
                  color: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
    );
  } else {
    return const SizedBox.shrink();
  }
}
