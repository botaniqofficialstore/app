import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../CodeReusable/CodeReusability.dart';
import '../../CodeReusable/CommonWidgets.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../Utility/Logger.dart';
import '../../Utility/PreferencesManager.dart';
import '../../constants/Constants.dart';
import '../InnerScreens/ContainerScreen/EditProfileScreen/EditProfileModel.dart';
import '../InnerScreens/ContainerScreen/EditProfileScreen/EditProfileRepository.dart';
import '../InnerScreens/MainScreen/MainScreenState.dart';
import 'DeliveryRestrictionPopup.dart';

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
    getSavedLocation();
  }

  Future<void> getSavedLocation() async {
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
    }
  }


  @override
  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      backgroundColor: objConstantColor.white,
      body: Stack(
        children: [
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
                //fillColor: Colors.blue.withOpacity(0.1),
                strokeWidth: 0,
                strokeColor: Colors.transparent,
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

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.dp, vertical: 15.dp),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [

                    Color(0xFFFF8000),
                    Color(0xFFFF4D00),
                    Color(0xFFFF3D00),


                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.dp),
                  bottomRight: Radius.circular(20.dp),
                ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ]
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    Row(
                      children: [
                        SizedBox(width: 10.dp),
                        CupertinoButton(
                          minimumSize: const Size(0, 0),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (userFrom == ScreenName.home){
                              userScreenNotifier.callNavigation(ScreenName.home);
                            } else if (userFrom == ScreenName.productDetail) {
                              userScreenNotifier.callNavigation(ScreenName.productDetail);
                            } else if (userFrom == ScreenName.profile) {
                              userScreenNotifier.callNavigation(ScreenName.profile);
                            } else{
                              userScreenNotifier.callNavigation(ScreenName.editProfile);
                            }
                          },
                          child: Icon(Icons.arrow_back, color: objConstantColor.white, size: 25.dp),
                        ),

                        SizedBox(width: 10.dp),
                        objCommonWidgets.customText(
                          context,
                          'Update Delivery Address',
                          15,
                          objConstantColor.white,
                          objConstantFonts.montserratSemiBold,
                        )
                      ],
                    ),
                
                    SizedBox(height: 10.dp),
                
                
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            // Opening quote
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Transform.translate(
                                  offset: const Offset(0, -2),
                                  child: Transform.rotate(
                                    angle: 3.14,
                                    child: Image.asset(
                                      objConstantAssest.quote,
                                      width: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                            ),
                            
                            // Main text
                            TextSpan(
                              text: " Choose where you want us to deliver and confirm your exact location. ",
                              style: TextStyle(
                                fontFamily: objConstantFonts.montserratSemiBold,
                                fontSize: 15,
                                color: objConstantColor.white,
                              ),
                            ),
                
                            // Ending quote (flipped)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.bottom,
                              child: Transform.translate(
                                offset: const Offset(0, -2),
                                child: Image.asset(
                                  objConstantAssest.quote,
                                  width: 15,
                                  color: Colors.white,
                                ),
                              )
                            ),
                          ],
                        ),
                      )
                
                
                    ),
                
                    SizedBox(height: 15.dp),
                
                    Row(
                      children: [
                
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.dp),
                            child: GooglePlaceAutoCompleteTextField(
                              boxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50.dp),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5.dp, offset: const Offset(0, 2))],
                              ),
                              textEditingController: _searchController,
                              googleAPIKey: 'AIzaSyBj448jygDcUrpUtXtmynTluoxWFbKP6Gk',
                              inputDecoration: InputDecoration(
                                hintText: "Search your location here...",
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search, color: objConstantColor.navyBlue),
                                contentPadding: EdgeInsets.symmetric(vertical: 10.dp),
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
                        ),
                
                
                      ],
                    ),
                    SizedBox(height: 2.dp)
                  ],
                ),
              ),
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
                      backgroundColor: objConstantColor.orange,
                      shape: const CircleBorder(),
                      child: Icon(Icons.my_location, color: Colors.white, size: 28.dp),
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
                            color: objConstantColor.navyBlue,
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 10.dp),
                            child: objCommonWidgets.customText(
                              context,
                              _selectedAddress.isNotEmpty ? _selectedAddress : "Fetching address...",
                              12,
                              objConstantColor.white,
                              objConstantFonts.montserratMedium,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.dp),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final screenNotifier = ref.read(MapScreenGlobalStateProvider.notifier);
                          screenNotifier.callEditProfileAPI(context, userScreenNotifier, _selectedAddress, '${_selectedLocation?.latitude},${_selectedLocation?.longitude}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.white,
                            borderRadius: BorderRadius.circular(5.dp),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(150),
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 10.dp),
                            child: objCommonWidgets.customText(
                              context,
                              'Confirm',
                              15,
                              objConstantColor.orange,
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
    PreferencesManager.getInstance().then((pref) {
      pref.setBooleanValue(PreferenceKeys.isDialogOpened, true);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => const DeliveryRestrictionPopup(),
      );
    });
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


//Map Screen State
class MapScreenGlobalState {
  final ScreenName currentModule;

  MapScreenGlobalState({
    this.currentModule = ScreenName.home,
  });

  MapScreenGlobalState copyWith({
    ScreenName? currentModule,
  }) {
    return MapScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
    );
  }
}

class MapScreenGlobalStateNotifier extends StateNotifier<MapScreenGlobalState> {
  MapScreenGlobalStateNotifier() : super(MapScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }


  ///This method used to call Edit Profile PUT API
  void callEditProfileAPI(BuildContext context, MainScreenGlobalStateNotifier notifier, String address, String latLon) {
    if (!context.mounted) return;

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'address' : latLon
        };

        final manager = await PreferencesManager.getInstance();
        String? userID = manager.getStringValue(PreferenceKeys.userID);
        String url = '${ConstantURLs.updateCustomerUrl}$userID';

        CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
        EditProfileRepository().callEditProfileApi(url, requestBody, (statusCode, responseBody) async {
          EditProfileResponse response = EditProfileResponse.fromJson(responseBody);

          if (statusCode == 200 || statusCode == 201) {
            exactAddress = address;
            var prefs = await PreferencesManager.getInstance();
            prefs.setStringValue(PreferenceKeys.userAddress, requestBody['address']);
            CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
            callNavigation(context, notifier);
          } else {
            CommonWidgets().showLoadingBar(false, context);
            CodeReusability().showAlert(context, response.message ?? "something Went Wrong");
          }
        });


      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });

  }

  void callNavigation(BuildContext context, MainScreenGlobalStateNotifier notifier){
    CodeReusability().showAlert(context, 'Delivery location updated successfully');
    if (userFrom == ScreenName.home){
      notifier.callNavigation(ScreenName.home);
    } else if (userFrom == ScreenName.productDetail){
    notifier.callNavigation(ScreenName.productDetail);
    } else if (userFrom == ScreenName.profile){
      notifier.callNavigation(ScreenName.profile);
    } else {
      notifier.callNavigation(ScreenName.editProfile);
    }
  }


}


final MapScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    MapScreenGlobalStateNotifier, MapScreenGlobalState>((ref) {
  var notifier = MapScreenGlobalStateNotifier();
  return notifier;
});
