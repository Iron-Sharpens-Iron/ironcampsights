// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/locationCityModel.dart';

abstract class LocationCityState {}

class LocationCityInitial extends LocationCityState {}

class LocationCityFetchInProgress extends LocationCityState {}

class LocationCityFetchSuccess extends LocationCityState {
  final List<LocationCityModel> locationCity;
  final String totalLocations;

  LocationCityFetchSuccess({required this.locationCity, required this.totalLocations});
}

class LocationCityFetchFailure extends LocationCityState {
  final String errorMessage;

  LocationCityFetchFailure(this.errorMessage);
}

class LocationCityCubit extends Cubit<LocationCityState> {
  LocationCityCubit() : super(LocationCityInitial());

  void getLocationCity() async {
    try {
      final result = await Api.post(body: {}, url: Api.getLocationCityApi);
      emit(LocationCityFetchSuccess(totalLocations: result['total'], locationCity: (result['data'] as List).map((e) => LocationCityModel.fromJson(e)).toList()));
    } catch (e) {
      emit(LocationCityFetchFailure(e.toString()));
    }
  }

  List<LocationCityModel> getLocationCityList() {
    if (state is LocationCityFetchSuccess) {
      return (state as LocationCityFetchSuccess).locationCity;
    }
    return [];
  }

  int getLocationIndex({required String locationName}) {
    if (state is LocationCityFetchSuccess) {
      return (state as LocationCityFetchSuccess).locationCity.indexWhere((element) => element.locationName == locationName);
    }
    return 0;
  }
}
