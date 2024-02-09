// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news/app/routes.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitleOnly.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/descView.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Style3Section extends StatelessWidget {
  final FeatureSectionModel model;
  final int position;

  const Style3Section({super.key, required this.model, this.position = 0});

  @override
  Widget build(BuildContext context) {
    return style3Data(model, context);
  }
  Future<void> saveSelectedNewsIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_challenge_index_$position', index);
    await prefs.setString('selected_challenge_date_$position', DateTime.now().toIso8601String());
    print("Saved Index: $index at position $position"); // Debugging
  }

  Future<int?> getSavedNewsIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedIndex = prefs.getInt('selected_challenge_index_$position');
    String? selectedDate = prefs.getString('selected_challenge_date_$position');
    DateTime? savedDate = selectedDate != null ? DateTime.parse(selectedDate) : null;

    print("Retrieved Index: $savedIndex, Date: $savedDate at position $position"); // Debugging

    DateTime now = DateTime.now();

    // Check if 7 days have passed since the last save
    if (savedDate == null || now.difference(savedDate).inDays >= 7) {
      int nextIndex = (savedIndex ?? -1) + 1;
      print("7 days passed. Next index: $nextIndex at position $position"); // Debugging
      await saveSelectedNewsIndex(nextIndex); // Save the updated index immediately
      return nextIndex;
    }
    return savedIndex;
  }



  Widget style3Data(FeatureSectionModel model, BuildContext context) {
    // News section
    if (model.newsType == 'news' || model.newsType == "user_choice") {
      if (model.news!.isNotEmpty) {
        return FutureBuilder<int?>(
          future: getSavedNewsIndex(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {

              List<NewsModel> newsList = model.news ?? [];
              int newsIndex = snapshot.data ?? 0;
              if (newsIndex >= newsList.length) {
                newsIndex = 0; // Reset to start if we've reached the end of the list
                saveSelectedNewsIndex(newsIndex);
                print("Resetting news index to 0 at position $position"); // Debugging
              }

              if (newsList.isNotEmpty) {
                print("Displaying news item at index: $newsIndex at position $position"); // Debugging
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonSectionTitleOnly(model, context),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.34,
                        child: _buildChallengeItem(newsList[newsIndex], context),
                      ),
                    ]
                );
              } else {
                print("No news items available at position $position"); // Debugging
              }



            }
            return CircularProgressIndicator();
          },
        );
      }
    }
      return const SizedBox.shrink();
    }


  Widget _buildChallengeItem(NewsModel news, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        // add a border with BorderSide
        side: BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
      elevation: 3,
      // align the child to the center
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: descView(desc: news.desc.toString(), fontValue: 15, context: context)
      ),
    );
  }

}
