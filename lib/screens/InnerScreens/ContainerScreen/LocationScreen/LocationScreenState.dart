import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:botaniqmicrogreens/screens/commonViews/MapScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../Constants/Constants.dart';
import '../../../../Utility/PreferencesManager.dart';

class LocationScreenState {
  final bool isLoading;
  final LatLng? selectedLocation;
  final String selectPickupAddress;

  LocationScreenState({
    this.isLoading = false,
    required this.selectedLocation,
    this.selectPickupAddress = '',

  });


  LocationScreenState copyWith({
    bool? isLoading,
    LatLng? selectedLocation,
    String? selectPickupAddress,
  }) {
    return LocationScreenState(
      isLoading: isLoading ?? this.isLoading,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectPickupAddress: selectPickupAddress ?? this.selectPickupAddress,
    );
  }
}

class LocationScreenStateNotifier extends StateNotifier<LocationScreenState> {
  LocationScreenStateNotifier() : super(LocationScreenState(selectedLocation: null
  ));

  Future<void> loadLocation() async {
    var prefs = await PreferencesManager.getInstance();
    String position = prefs.getStringValue(PreferenceKeys.userAddress) ?? '';



    if (position.isNotEmpty){
      try {
        // Split the string and extract latitude & longitude
        final parts = position.split(',');
        if (parts.length != 2) {
          throw const FormatException("Invalid position format. Expected 'lat, lng'");
        }

        final latitude = double.parse(parts[0].trim());
        final longitude = double.parse(parts[1].trim());
        final location = LatLng(latitude, longitude);
        String address = '';

        List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude);

        if (placeMarks.isNotEmpty) {
          final place = placeMarks.first;


            final parts = [
              place.subLocality,
              place.locality,
              place.administrativeArea,
              place.postalCode
            ];

            Logger().log('name:${place.name}, street:${place.street}, administrativeArea:${place.administrativeArea}, locality:${place.locality}, subLocality:${place.subLocality}, subThoroughfare:${place.subThoroughfare}');
            // remove null or empty values
            final filtered = parts.where((e) => e != null && e.toString().trim().isNotEmpty).toList();

          address = filtered.join(", ");
        }

        Logger().log('exactAddress --------->$exactAddress');

        state = state.copyWith(selectPickupAddress: address, selectedLocation: location);

      } catch (e) {
        Logger().log("Reverse geocoding error: $e");
      }
    }

  }



  void callMapPopup(BuildContext context) async {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const MapScreen(
        ),
      ),
    );
  }

  /// Call this when location is selected from map/autocomplete
  void setSelectedLocation(LatLng location, String address) {
    state = state.copyWith(selectedLocation: location, selectPickupAddress: address);
  }

}











final locationScreenStateProvider =
StateNotifierProvider.autoDispose<LocationScreenStateNotifier, LocationScreenState>((ref) {
  return LocationScreenStateNotifier();
});