// Updated MapScreen with reverse geocoding added
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
import '../../CodeReusable/CommonWidgets.dart';
import '../../Constants/Constants.dart';
import '../../../../constants/ConstantVariables.dart';
import '../InnerScreens/MainScreen/MainScreenState.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
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

  void _showOutOfRangeAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Out of Delivery Range"),
        content: const Text("Sorry, we can't deliver to this address. We will come to you soon!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          final parts = [
            place.name,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode
          ];

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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      objCommonWidgets.showLocationSettingsAlert(context);
      return;
    }

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
      _showOutOfRangeAlert();
      return;
    }

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(current, 15));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: objConstantColor.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _adminLocation, zoom: 10),
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
                //fillColor: Colors.blue.withOpacity(0.1),
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              ),
            },
            onTap: (latLng) {
              if (!_isWithinAllowed(latLng)) {
                _showOutOfRangeAlert();
                return;
              }
              _placeSelectedMarker(latLng, _selectedAddress);
            },
          ),

          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Container(
                  height: 50.dp,
                  width: 40.dp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    child: Icon(Icons.arrow_back, color: objConstantColor.navyBlue, size: 24),
                  ),
                ),
                SizedBox(width: 10.dp),

                Expanded(
                  child: Container(
                    height: 50.dp,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                    ),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: 'AIzaSyB_8QIhaq7Md4MpqnrBbdnd6r19ryjUfzg',
                      inputDecoration: InputDecoration(
                        hintText: "Search address",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: objConstantColor.navyBlue),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      debounceTime: 800,
                      countries: ["in"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        final lat = double.parse(prediction.lat!);
                        final lng = double.parse(prediction.lng!);
                        final selected = LatLng(lat, lng);

                        if (!_isWithinAllowed(selected)) {
                          _showOutOfRangeAlert();
                          return;
                        }

                        _placeSelectedMarker(selected, prediction.description);

                        final controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newLatLngZoom(selected, 14));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 15.dp,
            right: 15.dp,
            left: 15.dp,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    FloatingActionButton(
                      onPressed: () => _goToCurrentLocation(context),
                      backgroundColor: objConstantColor.navyBlue,
                      shape: const CircleBorder(),
                      child: Icon(Icons.my_location, color: Colors.white, size: 25.dp),
                    ),
                  ],
                ),
                SizedBox(height: 10.dp),

                if (_selectedLocation != null) ...{
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.white,
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(7.5.dp),
                            child: objCommonWidgets.customText(
                              context,
                              _selectedAddress.isNotEmpty ? _selectedAddress : "Fetching address...",
                              12,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratMedium,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.dp),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.orange,
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.dp),
                            child: objCommonWidgets.customText(
                              context,
                              'Confirm',
                              15,
                              objConstantColor.white,
                              objConstantFonts.montserratSemiBold,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}