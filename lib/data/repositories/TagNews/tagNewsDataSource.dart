// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class TagNewsRemoteDataSource {
  Future<dynamic> getTagNews({required BuildContext context, required String tagId, required String userId, required String langId, String? latitude, String? longitude}) async {
    try {
      final body = {TAG_ID: tagId, USER_ID: userId, LANGUAGE_ID: langId};
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.post(body: body, url: Api.getNewsByTagApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
