// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/ui/seacrh_page.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'dart:math';

// class MapScreen extends StatefulWidget {
//   final Map<String, dynamic>? receivedLocation;

//   const MapScreen({Key? key, this.receivedLocation, required longitude, required latitude}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   Position? currentPosition;
//   LatLng? destination;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//   TextEditingController searchController = TextEditingController();
//   String? currentAddress;
//   String? destinationAddress;
//   bool isViewingMode = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.receivedLocation != null) {
//       isViewingMode = true;
//       _loadReceivedLocation();
//     } else {
//       _getCurrentLocation();
//     }
//   }

//   Future<void> _loadReceivedLocation() async {
//     final originData = widget.receivedLocation!['origin'];
//     final destData = widget.receivedLocation!['destination'];

//     // Add origin marker
//     _addMarker(
//       LatLng(originData['lat'], originData['lng']),
//       'origin',
//       'Sender\'s Location',
//       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//     );

//     // Add destination marker
//     _addMarker(
//       LatLng(destData['lat'], destData['lng']),
//       'destination',
//       'Destination',
//       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     );

//     // Draw route
//     await _drawPolyline(
//       LatLng(originData['lat'], originData['lng']),
//       LatLng(destData['lat'], destData['lng']),
//     );

//     // Center the map to show both points
//     _fitMapToBounds();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return;
//         }
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       setState(() {
//         currentPosition = position;
//         currentAddress = _getAddressFromPlacemark(placemarks.first);
//         _addMarker(
//           LatLng(position.latitude, position.longitude),
//           'current',
//           'Current Location',
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         );
//       });

//       mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(position.latitude, position.longitude),
//             zoom: 15,
//           ),
//         ),
//       );
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   Future<void> _drawPolyline(LatLng origin, LatLng dest) async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<LatLng> polylineCoordinates = [];

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       'AIzaSyB0sppwm5PsZzrfHd0n2Pv4nSAz188b_Ls',
//       PointLatLng(origin.latitude, origin.longitude),
//       PointLatLng(dest.latitude, dest.longitude),
//     );

//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }

//       setState(() {
//         polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           color: Colors.blue,
//           points: polylineCoordinates,
//           width: 3,
//         ));
//       });
//     }
//   }

//   void _fitMapToBounds() {
//     if (markers.length < 2) return;

//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(
//         markers.map((m) => m.position.latitude).reduce(min),
//         markers.map((m) => m.position.longitude).reduce(min),
//       ),
//       northeast: LatLng(
//         markers.map((m) => m.position.latitude).reduce(max),
//         markers.map((m) => m.position.longitude).reduce(max),
//       ),
//     );

//     mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }

//   String _getAddressFromPlacemark(Placemark placemark) {
//     return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}";
//   }

//   void _addMarker(
//       LatLng position, String id, String title, BitmapDescriptor icon) {
//     setState(() {
//       markers.add(
//         Marker(
//           markerId: MarkerId(id),
//           position: position,
//           infoWindow: InfoWindow(title: title),
//           icon: icon,
//         ),
//       );
//     });
//   }

//   Future<void> _searchLocation(String query) async {
//     try {
//       List<Location> locations = await locationFromAddress(query);
//       if (locations.isNotEmpty) {
//         Location location = locations.first;
//         LatLng newDestination = LatLng(location.latitude, location.longitude);

//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           location.latitude,
//           location.longitude,
//         );

//         setState(() {
//           destination = newDestination;
//           destinationAddress = _getAddressFromPlacemark(placemarks.first);
//           markers
//               .removeWhere((marker) => marker.markerId.value == 'destination');
//           _addMarker(
//             newDestination,
//             'destination',
//             'Destination',
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           );
//         });

//         if (currentPosition != null) {
//           await _drawPolyline(
//             LatLng(currentPosition!.latitude, currentPosition!.longitude),
//             newDestination,
//           );
//           _fitMapToBounds();
//         }
//       }
//     } catch (e) {
//       print("Error searching location: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Location not found')),
//       );
//     }
//   }

//   String _calculateDistance() {
//     if (currentPosition != null && destination != null) {
//       double distanceInMeters = Geolocator.distanceBetween(
//         currentPosition!.latitude,
//         currentPosition!.longitude,
//         destination!.latitude,
//         destination!.longitude,
//       );
//       return (distanceInMeters / 1000).toStringAsFixed(2);
//     }
//     return "0";
//   }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     return Scaffold(
//         body: SafeArea(
//       child: Column(
//         children: [
//           SizedBox(
//             height: height * 0.6,
//             child: Container(
//               child: Column(
//                 children: [
//                   if (!isViewingMode)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextField(
//                         controller: searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search destination',
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => Placesapigoogle()));
//                             },
//                             icon: const Icon(Icons.search),
//                             // onPressed: () => _searchLocation(searchController.text),
//                           ),
//                         ),
//                       ),
//                     ),
//                   Expanded(
//                     child: Stack(
//                       children: [
//                         GoogleMap(
//                           initialCameraPosition: CameraPosition(
//                             target: widget.receivedLocation != null
//                                 ? LatLng(
//                                     widget.receivedLocation!['origin']['lat'],
//                                     widget.receivedLocation!['origin']['lng'],
//                                   )
//                                 : const LatLng(0, 0),
//                             zoom: 15,
//                           ),
//                           markers: markers,
//                           polylines: polylines,
//                           onMapCreated: (controller) =>
//                               mapController = controller,
//                           myLocationEnabled: !isViewingMode,
//                           myLocationButtonEnabled: !isViewingMode,
//                         ),
//                         if (destination != null || isViewingMode)
//                           Positioned(
//                             bottom: 16,
//                             left: 16,
//                             right: 16,
//                             child: Card(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       'Distance: ${isViewingMode ? widget.receivedLocation!['distance'] : _calculateDistance()} km',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                         'From: ${isViewingMode ? widget.receivedLocation!['origin']['address'] : currentAddress}'),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                         'To: ${isViewingMode ? widget.receivedLocation!['destination']['address'] : destinationAddress}'),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             height: height * 0.03,
//           ),
//           Card(
//             child: Container(
//               height: 50,
//               width: width,
//               decoration: BoxDecoration(),
//               child: Center(
//                   child: Text(
//                 "Send your curent location to the user",
//                 style: TextStyle(fontSize: 17),
//               )),
//             ),
//           ),
//           SizedBox(
//             height: height * 0.03,
//           ),
//           Card(
//             child: Container(
//               height: 50,
//               width: width,
//               decoration: BoxDecoration(),
//               child: Center(
//                   child: Text(
//                 "Send your mark location to the user",
//                 style: TextStyle(fontSize: 17),
//               )),
//             ),
//           )
//         ],
//       ),
//     ));
//   }
// }
