
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitle.dart';
import 'package:news/app/routes.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/HomePage/Widgets/CommonSectionTitleOnly.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

//for quotes and verse
class Style2Section extends StatelessWidget {
  final FeatureSectionModel model;
  final int position;


  const Style2Section({super.key, required this.model, this.position = 0});

  @override
  Widget build(BuildContext context) {
    //return showSingleNews ? style2SingleNews(model, context) : style2Data(model, context);
    return style2SingleNews(model, context);
  }
  Future<void> saveSelectedNewsIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_news_index_$position', index);
    await prefs.setString('selected_news_date_$position', DateTime.now().toIso8601String());
    print("Saved Index: $index at position $position"); // Debugging
  }

  Future<int?> getSavedNewsIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedIndex = prefs.getInt('selected_news_index_$position');
    String? selectedDate = prefs.getString('selected_news_date_$position');
    DateTime? savedDate = selectedDate != null ? DateTime.parse(selectedDate) : null;

    print("Retrieved Index: $savedIndex, Date: $savedDate at position $position"); // Debugging

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? lastSavedDate = savedDate != null ? DateTime(savedDate.year, savedDate.month, savedDate.day) : null;

    // Check if a new calendar day has started since the last save
    if (lastSavedDate == null || today.isAfter(lastSavedDate)) {
      int nextIndex = (savedIndex ?? -1) + 1;
      print("New calendar day. Next index: $nextIndex at position $position"); // Debugging
      await saveSelectedNewsIndex(nextIndex); // Save the updated index immediately
      return nextIndex;
    }
    return savedIndex;
  }



  Widget style2SingleNews(FeatureSectionModel model, BuildContext context) {
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
            return _buildNewsItem(newsList[newsIndex], context);
          } else {
            print("No news items available at position $position"); // Debugging
          }
        }
        return CircularProgressIndicator(); // or a placeholder
      },
    );
  }

  Widget _buildNewsItem(NewsModel news, BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonSectionTitleOnly(model, context), // Include the common section title
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: InkWell(
              onTap: () {
                if (model.newsType == 'news' || model.newsType == "user_choice") {
                  List<NewsModel> newsList = List.from(model.news!); // Create a copy of the news list
                  newsList.remove(news); // Remove the current news item from the list
                  Navigator.of(context).pushNamed(
                      Routes.newsDetails,
                      arguments: {
                        "model": news,
                        "newsList": newsList,
                        "isFromBreak": false,
                        "fromShowMore": false
                      }
                  );
                }
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, darkSecondaryColor.withOpacity(0.9)],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.darken,
                      child: CustomNetworkImage(
                          networkImageUrl: news.image!,
                          fit: BoxFit.cover,
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height / 3.3,
                          isVideo: false // Update this based on whether the news item is a video
                      ),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 10,
                    start: 10,
                    end: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (news.categoryName != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: CustomTextLabel(
                                  text: news.categoryName!,
                                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryColor.withOpacity(0.6)),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        /*
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: CustomTextLabel(
                            text: news.title!,
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor, fontWeight: FontWeight.normal),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),

                         */
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ]);
  }

/*
  Widget style2Data(FeatureSectionModel model, BuildContext context) {
    if (model.breakVideos!.isNotEmpty || model.breakNews!.isNotEmpty || model.videos!.isNotEmpty || model.news!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonSectionTitle(model, context),
          if (model.newsType == 'news' || model.videosType == "news" || model.newsType == "user_choice")
            if ((model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.isNotEmpty : model.videos!.isNotEmpty)
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (model.newsType == 'news' || model.newsType == "user_choice") ? model.news!.length : model.videos!.length,
                  itemBuilder: (context, index) {
                    NewsModel data = (model.newsType == 'news' || model.newsType == "user_choice") ? model.news![index] : model.videos![index];
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 15),
                      child: InkWell(
                        onTap: () {
                          if (model.newsType == 'news' || model.newsType == "user_choice") {
                            List<NewsModel> newsList = [];
                            newsList.addAll(model.news!);
                            newsList.removeAt(index);
                            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": data, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, darkSecondaryColor.withOpacity(0.9)],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.darken,
                                    child: CustomNetworkImage(
                                        networkImageUrl: data.image!,
                                        fit: BoxFit.cover,
                                        width: double.maxFinite,
                                        height: MediaQuery.of(context).size.height / 3.3,
                                        isVideo: model.newsType == 'videos' ? true : false))),
                            if (model.newsType == 'videos')
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                top: MediaQuery.of(context).size.height * 0.12,
                                start: MediaQuery.of(context).size.width / 3,
                                end: MediaQuery.of(context).size.width / 3,
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 1, "model": data});
                                    },
                                    child: UiUtils.setPlayButton(context: context)),
                              ),
                            Positioned.directional(
                                textDirection: Directionality.of(context),
                                bottom: 10,
                                start: 10,
                                end: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (data.categoryName != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: CustomTextLabel(
                                                  text: data.categoryName!,
                                                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryColor.withOpacity(0.6)),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true)),
                                        ),
                                      ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: CustomTextLabel(
                                            text: data.title!,
                                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor, fontWeight: FontWeight.normal),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true)),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  }),
          if (model.newsType == 'breaking_news' || model.videosType == "breaking_news")
            if (model.newsType == 'breaking_news' ? model.breakNews!.isNotEmpty : model.breakVideos!.isNotEmpty)
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: model.newsType == 'breaking_news' ? model.breakNews!.length : model.breakVideos!.length,
                  itemBuilder: (context, index) {
                    BreakingNewsModel data = model.newsType == 'breaking_news' ? model.breakNews![index] : model.breakVideos![index];
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 15),
                      child: InkWell(
                        onTap: () {
                          if (model.newsType == 'breaking_news') {
                            List<BreakingNewsModel> breakList = [];
                            breakList.addAll(model.breakNews!);
                            breakList.removeAt(index);
                            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"breakModel": data, "breakNewsList": breakList, "isFromBreak": true, "fromShowMore": false});
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, darkSecondaryColor.withOpacity(0.9)],
                                    ).createShader(rect);
                                  },
                                  blendMode: BlendMode.darken,
                                  child: CustomNetworkImage(
                                      networkImageUrl: data.image!,
                                      fit: BoxFit.cover,
                                      width: double.maxFinite,
                                      height: MediaQuery.of(context).size.height / 3.3,
                                      isVideo: model.newsType == 'videos' ? true : false),
                                )),
                            if (model.newsType == 'videos')
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                top: MediaQuery.of(context).size.height * 0.12,
                                start: MediaQuery.of(context).size.width / 3,
                                end: MediaQuery.of(context).size.width / 3,
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 3, "breakModel": data});
                                    },
                                    child: UiUtils.setPlayButton(context: context)),
                              ),
                            Positioned.directional(
                                textDirection: Directionality.of(context),
                                bottom: 10,
                                start: 10,
                                end: 10,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: CustomTextLabel(
                                        text: data.title!,
                                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor, fontWeight: FontWeight.normal),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true)))
                          ],
                        ),
                      ),
                    );
                  })
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

 */
}
