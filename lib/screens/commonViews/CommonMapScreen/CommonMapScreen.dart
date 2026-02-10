import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../CodeReusable/CommonWidgets.dart';
import '../../../../../constants/ConstantVariables.dart';
import '../../../Utility/Logger.dart';
import '../../../constants/Constants.dart';


class CommonMapScreen extends ConsumerStatefulWidget {
  const CommonMapScreen({super.key});

  @override
  ConsumerState<CommonMapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<CommonMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  final LatLng _adminLocation = const LatLng(10.700282608343603, 76.73939956587711);
  static const double _radiusKm = 60.0;

  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  String _selectedAddress = "";

  @override
  void initState() {
    super.initState();
    getSavedLocation();
  }

  Future<void> getSavedLocation() async {
    /*var prefs = await PreferencesManager.getInstance();
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



        setState(() async {
          _selectedLocation = location;
          _markers = {Marker(markerId: const MarkerId("current"), position: location)};
          _getAddressFromLatLng(location);
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(location, 19));
        });

      } catch (e) {
        print("Reverse geocoding error: $e");
      }
    }*/
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // --- The Map Layer ---
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _adminLocation, zoom: 15),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers.union({}),
              circles: {
                Circle(
                  circleId: const CircleId("radius"),
                  center: _adminLocation,
                  radius: _radiusKm * 1000,
                  fillColor: Colors.transparent, //Radius Color
                  strokeWidth: 1,
                  strokeColor: Colors.black12,
                ),
              },
              onTap: (latLng) {

                if (!_isWithinAllowed(latLng)) {
                  _showOutOfRangeAlert(context);
                  return;
                }
                _placeSelectedMarker(latLng, _selectedAddress);
              },
            ),

            // --- Premium Floating Header ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.dp),
                    bottomRight: Radius.circular(20.dp),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: Row(
                        children: [
                          CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            child:  Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18.dp),
                          ),
                          SizedBox(width: 5.dp),
                          objCommonWidgets.customText(
                            context,
                            'Pickup Location',
                            15,
                            Colors.black,
                            objConstantFonts.montserratSemiBold,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.dp),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: GooglePlaceAutoCompleteTextField(
                        boxDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.dp),
                          border: Border.all(color: Colors.black, width: 0.5.dp),
                        ),
                        textEditingController: _searchController,
                        googleAPIKey: 'YOUR_KEY_HERE',
                        inputDecoration: const InputDecoration(
                          hintText: "Search for a building, street...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        debounceTime: 800,
                        countries: const ["in"],
                        isLatLngRequired: true,

                        getPlaceDetailWithLatLng: (Prediction prediction) async {
                          final lat = double.parse(prediction.lat!);
                          final lng = double.parse(prediction.lng!);
                          final selected = LatLng(lat, lng);

                          if (!_isWithinAllowed(selected)) {
                            _showOutOfRangeAlert(context);
                            return;
                          }

                          _placeSelectedMarker(selected, prediction.description);
                          final controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newLatLngZoom(selected, 19));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Action Area ---
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Locate Me Button
                  FloatingActionButton(
                    onPressed: () => _goToCurrentLocation(context),
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.dp)),
                    child: Icon(Icons.my_location_rounded, color: Colors.black, size: 25.dp,),
                  ),
                  SizedBox(height: 20.dp),

                  // Address Details Card
                  if (_selectedLocation != null)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      decoration: BoxDecoration(
                        color: Colors.white, // Dark Theme Card
                        borderRadius: BorderRadius.circular(15.dp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              objCommonWidgets.customText(context, 'Selected Location', 13, Colors.black, objConstantFonts.montserratSemiBold),
                              Icon(Icons.location_on, size: 15.dp, color: Colors.black,),
                            ],
                          ),
                          SizedBox(height: 5.dp),
                          Divider(color: Colors.black, height: 0.2, thickness: 0.5,),
                          SizedBox(height: 10.dp),
                          objCommonWidgets.customText(
                            context,
                            _selectedAddress.isNotEmpty ? _selectedAddress : "Locating...",
                            11.5,
                            Colors.black,
                            objConstantFonts.montserratMedium,
                          ),
                          SizedBox(height: 35.dp),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CupertinoButton(padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(20.dp)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                                    child: Center(
                                      child: objCommonWidgets.customText(context, 'Confirm', 12, Colors.white, objConstantFonts.montserratMedium),
                                    ),
                                  ), onPressed: (){
                                    Navigator.pop(context, {
                                      'location': _selectedLocation,
                                      'address': _selectedAddress,
                                    });

                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isWithinAllowed(LatLng target) {
    const earthRadius = 6371;
    double dLat = _toRadians(target.latitude - _adminLocation.latitude);
    double dLng = _toRadians(target.longitude - _adminLocation.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(_adminLocation.latitude)) *
            cos(_toRadians(target.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance <= _radiusKm;
  }

  double _toRadians(double deg) => deg * pi / 180;

  void _showOutOfRangeAlert(BuildContext context) {

  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          final parts = [
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode
          ];

          Logger().log('name:${place.name}, street:${place.street}, administrativeArea:${place.administrativeArea}, locality:${place.locality}, subLocality:${place.subLocality}, subThoroughfare:${place.subThoroughfare}');
          Logger().log('$_selectedLocation');
          // remove null or empty values
          final filtered = parts.where((e) => e != null && e.toString().trim().isNotEmpty).toList();

          _selectedAddress = filtered.join(", ");
        });
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
    }
  }

  Future<void> _goToCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }


    if (permission == LocationPermission.deniedForever) {
      await CommonWidgets().showPermissionDialog(context);
      return;
    }

    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng current = LatLng(position.latitude, position.longitude);

    if (!_isWithinAllowed(current)) {
      _showOutOfRangeAlert(context);
      return;
    }

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(current, 19));

    setState(() {
      _selectedLocation = current;
      _markers = {Marker(markerId: const MarkerId("current"), position: current)};
    });

    _getAddressFromLatLng(current);
  }

  void _placeSelectedMarker(LatLng pos, String? desc) {
    setState(() {
      _selectedLocation = pos;
      _markers = {
        Marker(
          markerId: const MarkerId("selected"),
          position: pos,
          infoWindow: InfoWindow(title: desc ?? "Selected Location"),
        ),
      };
    });

    _getAddressFromLatLng(pos);
  }
}

