import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../CodeReusable/CodeReusability.dart';
import '../../CodeReusable/CommonWidgets.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../Utility/CyclingText.dart';
import '../../Utility/Logger.dart';
import '../../Utility/PreferencesManager.dart';
import '../../constants/Constants.dart';
import '../InnerScreens/ContainerScreen/EditProfileScreen/EditProfileModel.dart';
import '../InnerScreens/ContainerScreen/EditProfileScreen/EditProfileRepository.dart';
import '../InnerScreens/MainScreen/MainScreenState.dart';
import 'DeliveryRestrictionPopup.dart';
import 'dart:ui' as ui;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();

  final LatLng _adminLocation = const LatLng(10.700282608343603, 76.73939956587711);
  static const double _radiusKm = 60.0;
  static const double _minZoomLevel = 17.7;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  Timer? _locationPollingTimer;

  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();

  String _selectedAddress = "";
  String _selectedTownAddress = "";
  double _currentZoom = 15.0;
  bool _isLocationServiceEnabled = true;
  bool _isMoving = false;

  late AnimationController _borderAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize the running border animation
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initializeMap();

    // --- FIX: REAL-TIME LISTENER ---

    // A. Initial check
    _checkLocationService();

    // B. Stream Listener (Standard way)
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      _handleServiceStatus(status == ServiceStatus.enabled);
    });

    // C. Polling Fallback (Reliable way)
    // Check every 2 seconds in case the stream is delayed by the OS
    _locationPollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkLocationService();
    });
  }

  @override
  void dispose() {
    // --- FIX: CLEANUP ---
    _serviceStatusStream?.cancel();
    _locationPollingTimer?.cancel();
    _borderAnimationController.dispose();
    super.dispose();
  }

  // Helper to handle status changes in one place
  void _handleServiceStatus(bool isEnabled) {
    if (_isLocationServiceEnabled != isEnabled) {
      setState(() {
        _isLocationServiceEnabled = isEnabled;
      });

      if (isEnabled) {
        Logger().log("Location turned ON - Snapping to current position");
        _goToCurrentLocation(context);
      } else {
        Logger().log("Location turned OFF");
      }
    }
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _handleServiceStatus(serviceEnabled);
  }

  Future<void> _initializeMap() async {
    await getSavedLocation();
  }

  Future<void> getSavedLocation() async {
    var prefs = await PreferencesManager.getInstance();
    String position = prefs.getStringValue(PreferenceKeys.userAddress) ?? '';
    if (position.isNotEmpty) {
      try {
        final parts = position.split(',');
        if (parts.length == 2) {
          final latitude = double.parse(parts[0].trim());
          final longitude = double.parse(parts[1].trim());
          final location = LatLng(latitude, longitude);

          _selectedLocation = location;
          _getAddressFromLatLng(location);
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(location, 19));
        }
      } catch (e) {
        print("Error loading saved location: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: objConstantColor.white,
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _adminLocation, zoom: _currentZoom),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: (position) {
                setState(() {
                  _isMoving = true;
                  _currentZoom = position.zoom;
                  _selectedLocation = position.target;
                  Logger().log('_minZoomLevel =----> ${position.zoom}');
                });
              },
              onCameraIdle: () {
                setState(() => _isMoving = false);
                if (_selectedLocation != null) {
                  /*if (!_isWithinAllowed(_selectedLocation!)) {
                    _showOutOfRangeAlert(context);
                  } else {*/
                    _getAddressFromLatLng(_selectedLocation!);
                  //}
                }
              },
            ),

            // CENTER MARKER (SWIGGY STYLE)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35), // Offset for pin point
                child: Image.asset(objConstantAssest.locFour, width: 50.dp, height: 50.dp),
              ),
            ),

            // HEADER AND SEARCH
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF)
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.dp),
                        bottomRight: Radius.circular(20.dp),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 2,
                          offset: const Offset(2, 5),
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
                                child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 15.dp),
                              ),
                              SizedBox(width: 5.dp),
                              objCommonWidgets.customText(context, 'Delivery Location', 14, Colors.black, objConstantFonts.montserratSemiBold),
                              const Spacer(),

                            ],
                          ),
                        ),
                        SizedBox(height: 10.dp),
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

                              /*if (!_isWithinAllowed(selected)) {
                                _showOutOfRangeAlert(context);
                                return;
                              }*/

                              final controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.newLatLngZoom(selected, 19));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.dp),

                  if (!_isLocationServiceEnabled)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildLocationSwitch(),
                        SizedBox(width: 10.dp)
                      ],
                    ),
                ],
              ),
            ),


            // BOTTOM INFO & CONFIRM
            Positioned(
              bottom: 15.dp,
              right: 15.dp,
              left: 15.dp,
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        SizedBox(
                          width: 48.dp,
                          height: 48.dp,
                          child: FloatingActionButton(
                            elevation: 6,
                            onPressed: () => _goToCurrentLocation(context),
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            child: Icon(
                              Icons.my_location_rounded,
                              color: objConstantColor.black,
                              size: 22.dp,
                            ),
                          ),
                        ),


                      ],
                    ),
                    SizedBox(height: 10.dp),
                    _buildBottomActionArea(userScreenNotifier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSwitch() {
    return AnimatedBuilder(
      animation: _borderAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.dp),
            gradient: SweepGradient(
              // Adding multiple stops prevents the "flicker" at the start/end point
              colors: [
                Colors.white,
                Colors.deepOrange,
                Colors.deepOrange.withAlpha(80),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_borderAnimationController.value * 2 * 3.141592653589793),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 5.dp),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.dp)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                objCommonWidgets.customText(
                  context,
                  'Turn on location',
                  8,
                  Colors.black,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(width: 5.dp),
                SizedBox(
                  width: 35.dp,
                  height: 23.dp,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CupertinoSwitch(
                      value: false,
                      activeTrackColor: CupertinoColors.activeGreen,
                      inactiveTrackColor: CupertinoColors.systemGrey5,
                      onChanged: (change) async {
                        _goToCurrentLocation(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildBottomActionArea(dynamic userScreenNotifier) {
    // If zoom is too low or moving, show shimmer for precision requirement
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
            color: objConstantColor.white,
            borderRadius: BorderRadius.circular(10.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 2,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.dp, top: 4.dp, right: 4.dp),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 10.dp),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F1F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.dp),
                    topRight: Radius.circular(8.dp),
                  ),

                ),
                child: const CyclingText(),
              ),
            ),

            if (_isMoving)...{
              _buildShimmerArea()
            } else...{
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.dp, horizontal: 15.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(objConstantAssest.locFour, width: 18.dp),
                          SizedBox(width: 5.dp),
                          Flexible(
                            child: objCommonWidgets.customText(context, _selectedTownAddress, 17,
                                Colors.black, objConstantFonts.montserratBold),
                          )
                        ],
                      ),
                      objCommonWidgets.customText(context, _selectedAddress, 12,
                          Colors.black, objConstantFonts.montserratRegular)
                    ],
                  ),
                ),
              )
            },

            if (_currentZoom >= _minZoomLevel && !_isMoving && _selectedAddress.isNotEmpty)...{
              CupertinoButton(
                padding: EdgeInsets.only(
                    bottom: 10.dp, left: 15.dp, right: 15.dp),
                onPressed: () {
                  final screenNotifier = ref.read(
                      MapScreenGlobalStateProvider.notifier);
                  screenNotifier.callEditProfileAPI(
                      context, userScreenNotifier, _selectedAddress,
                      '${_selectedLocation?.latitude},${_selectedLocation
                          ?.longitude}');
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(10.dp)),
                  padding: EdgeInsets.symmetric(
                      vertical: 13.dp, horizontal: 15.dp),
                  child: Center(child: objCommonWidgets.customText(
                      context, 'Confirm Location', 14, Colors.white,
                      objConstantFonts.montserratSemiBold)),
                ),
              ),
            }else...{
              if(!_isMoving)
              Padding(
                padding: EdgeInsets.only(left: 15.dp, right: 15.dp, bottom: 10.dp),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                  decoration: BoxDecoration(
                      color: Colors.red.withAlpha(15),
                      borderRadius: BorderRadius.circular(10.dp),
                    border: Border.all(color: Colors.red)
                  ),
                  child: objCommonWidgets.customText(context,
                      'Zoom in to place the pin at exact delivery location',
                      10, Colors.red, objConstantFonts.montserratMedium),
                ),
              )
            }
          ],
        ),
      ),
    );
  }


  Widget _buildShimmerArea() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Shimmer for the Icon
                  Container(
                    width: 18.dp,
                    height: 18.dp,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.dp),
                    ),
                  ),
                  SizedBox(width: 5.dp),
                  // Shimmer for 'Chittur' text
                  Container(
                    width: 80.dp,
                    height: 17.dp,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 8.dp),
              // Shimmer for the address line
              Container(
                width: 200.dp,
                height: 12.dp,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isWithinAllowed(LatLng target) {
    const earthRadius = 6371;
    double dLat = _toRadians(target.latitude - _adminLocation.latitude);
    double dLng = _toRadians(target.longitude - _adminLocation.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(_adminLocation.latitude)) * cos(_toRadians(target.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    double distance = earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
    return distance <= _radiusKm;
  }

  double _toRadians(double deg) => deg * pi / 180;

  void _showOutOfRangeAlert(BuildContext context) {
    PreferencesManager.getInstance().then((pref) {
      pref.setBooleanValue(PreferenceKeys.isDialogOpened, true);
      showDialog(barrierDismissible: false, context: context, builder: (_) => const DeliveryRestrictionPopup());
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placeMarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;

        setState(() {
          final parts = [
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode
          ];

          final filtered = parts
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .toList();

          _selectedAddress = filtered.join(", ");

          // ✅ Proper fallback logic
          _selectedTownAddress =
          (place.subLocality != null && place.subLocality!.isNotEmpty)
              ? place.subLocality!
              : (place.locality ?? "");
        });
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
    }
  }



  Future<void> _goToCurrentLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await CommonWidgets().showPermissionDialog(context);
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng current = LatLng(position.latitude, position.longitude);

    /*if (!_isWithinAllowed(current)) {
      _showOutOfRangeAlert(context);
      return;
    }*/

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(current, 19));
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
    Navigator.pop(context);
  }


}


final MapScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    MapScreenGlobalStateNotifier, MapScreenGlobalState>((ref) {
  var notifier = MapScreenGlobalStateNotifier();
  return notifier;
});



