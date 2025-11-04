/***import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;

  // Your fixed location (shop location, e.g. Palakkad)
  final LatLng _myLocation = const LatLng(10.7867, 76.6548);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Delivery Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _myLocation,
              zoom: 12,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (LatLng position) {
              setState(() {
                _pickedLocation = position;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId("shop"),
                position: _myLocation,
                infoWindow: const InfoWindow(title: "Our Location"),
              ),
              if (_pickedLocation != null)
                Marker(
                  markerId: const MarkerId("picked"),
                  position: _pickedLocation!,
                  infoWindow: const InfoWindow(title: "Your Pick"),
                ),
            },
          ),

          // Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _pickedLocation == null ? null : _confirmLocation,
              child: const Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLocation() {
    if (_pickedLocation == null) return;

    final distance = Geolocator.distanceBetween(
      _myLocation.latitude,
      _myLocation.longitude,
      _pickedLocation!.latitude,
      _pickedLocation!.longitude,
    ) / 1000; // convert to km

    if (distance <= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Location accepted (within ${distance.toStringAsFixed(1)} km)")),
      );
      Navigator.pop(context, _pickedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Sorry, location is ${distance.toStringAsFixed(1)} km away (limit 60 km)")),
      );
    }
  }
}*///
