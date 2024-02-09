// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SectionByIdRemoteDataSource {
  Future<dynamic> getSectionById({required String userId, required String langId, required String sectionId, String? latitude, String? longitude}) async {
    try {
      final body = {USER_ID: userId, LANGUAGE_ID: langId, SECTION_ID: sectionId}; //lazy loading - so No need to pass offset and limit
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.post(body: body, url: Api.getFeatureSectionByIdApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
