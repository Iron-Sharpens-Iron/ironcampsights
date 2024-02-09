// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class GetUserNewsRemoteDataSource {
  Future<dynamic> getGetUserNews({required String limit, required String offset, required String userId, required String langId, String? latitude, String? longitude}) async {
    try {
      final body = {LIMIT: limit, OFFSET: offset, USER_ID: userId, USER_NEWS: userId};
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;
      final result = await Api.post(body: body, url: Api.getNewsApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
