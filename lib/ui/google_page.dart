// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

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

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//   }

//   Future<void> getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       currentPosition = position;
//       markers.add(
//         Marker(
//           markerId: const MarkerId('current'),
//           position: LatLng(position.latitude, position.longitude),
//           infoWindow: const InfoWindow(title: 'Current Location'),
//         ),
//       );
//     });

//     mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(position.latitude, position.longitude),
//           zoom: 15,
//         ),
//       ),
//     );
//   }

//   Future<void> searchLocation(String query) async {
//     // Implement location search using Places API
//     // For now, just adding a mock destination
//     setState(() {
//       destination = LatLng(
//           currentPosition!.latitude + 0.01, currentPosition!.longitude + 0.01);
//       markers.add(
//         Marker(
//           markerId: const MarkerId('destination'),
//           position: destination!,
//           infoWindow: InfoWindow(title: query),
//         ),
//       );
//       drawPolyline();
//     });
//   }

//   Future<void> drawPolyline() async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<LatLng> polylineCoordinates = [];

//     PointLatLng origin = PointLatLng(
//       currentPosition!.latitude,
//       currentPosition!.longitude,
//     );
//     PointLatLng dest = PointLatLng(
//       destination!.latitude,
//       destination!.longitude,
//     );

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       'AIzaSyB0sppwm5PsZzrfHd0n2Pv4nSAz188b_Ls', // Replace with your API key
//       origin,
//       dest,
//     );

//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     }

//     setState(() {
//       polylines.add(Polyline(
//         polylineId: const PolylineId('route'),
//         color: Colors.blue,
//         points: polylineCoordinates,
//         width: 3,
//       ));
//     });
//   }

//   String calculateDistance() {
//     if (currentPosition != null && destination != null) {
//       double distanceInMeters = Geolocator.distanceBetween(
//         currentPosition!.latitude,
//         currentPosition!.longitude,
//         destination!.latitude,
//         destination!.longitude,
//       );
//       return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
//     }
//     return '0 km';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Location'),
//         actions: [
//           if (destination != null)
//             IconButton(
//               icon: const Icon(Icons.send),
//               onPressed: () {
//                 // Return location data to chat screen
//                 Navigator.pop(context, {
//                   'origin': {
//                     'lat': currentPosition!.latitude,
//                     'lng': currentPosition!.longitude,
//                   },
//                   'destination': {
//                     'lat': destination!.latitude,
//                     'lng': destination!.longitude,
//                   },
//                   'distance': calculateDistance(),
//                 });
//               },
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search location',
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () => searchLocation(searchController.text),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: currentPosition == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(
//                         currentPosition!.latitude,
//                         currentPosition!.longitude,
//                       ),
//                       zoom: 15,
//                     ),
//                     markers: markers,
//                     polylines: polylines,
//                     onMapCreated: (controller) => mapController = controller,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
