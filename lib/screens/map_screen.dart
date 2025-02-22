import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final bool isViewer;

  const MapScreen({
    Key? key,
    this.latitude,
    this.longitude,
    this.isViewer = false,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  String? currentAddress;
  TextEditingController searchController = TextEditingController();
  LatLng? searchedLocation;
  String? searchedAddress;
  List<Map<String, dynamic>> searchHistory = [];
  List<dynamic> placesSuggestions = [];
  String sessionToken = const Uuid().v4();
  static const String googlePlacesApiKey =
      'AIzaSyB0sppwm5PsZzrfHd0n2Pv4nSAz188b_Ls';

  @override
  void initState() {
    super.initState();
    if (widget.isViewer) {
      _showReceivedLocation();
    } else {
      _getCurrentLocation();
    }
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        getSuggestions(searchController.text);
      } else {
        setState(() {
          placesSuggestions = [];
        });
      }
    });
  }

  void _showReceivedLocation() {
    if (widget.latitude != null && widget.longitude != null) {
      _addMarker(
        LatLng(widget.latitude!, widget.longitude!),
        'shared',
        'Shared Location',
        BitmapDescriptor.defaultMarker,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentPosition = position;
        currentAddress =
            "${placemarks.first.street}, ${placemarks.first.locality}";
        _addMarker(
          LatLng(position.latitude, position.longitude),
          'current',
          'Current Location',
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _searchLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(searchController.text);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        final searchData = {
          'location': LatLng(location.latitude, location.longitude),
          'address': "${placemarks.first.street}, ${placemarks.first.locality}",
        };

        setState(() {
          searchedLocation = searchData['location'] as LatLng;
          searchedAddress = searchData['address'] as String;

          // Add to search history if not already present
          if (!searchHistory
              .any((item) => item['address'] == searchData['address'])) {
            searchHistory.insert(0, searchData);
          }

          // Update marker
          markers.removeWhere((marker) => marker.markerId.value == 'searched');
          _addMarker(
            searchedLocation!,
            'searched',
            'Searched Location',
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(searchedLocation!, 15),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found')),
      );
    }
  }

  void _addMarker(
      LatLng position, String id, String title, BitmapDescriptor icon) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: icon,
        ),
      );
    });
  }

  void getSuggestions(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$googlePlacesApiKey&sessiontoken=$sessionToken';

    try {
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          placesSuggestions = jsonDecode(response.body)['predictions'];
        });
      }
    } catch (e) {
      print('Error getting suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Stack(
        children: [
          Column(
            children: [
              if (!widget.isViewer)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchLocation,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.4,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.isViewer && widget.latitude != null
                                ? LatLng(widget.latitude!, widget.longitude!)
                                : const LatLng(0, 0),
                            zoom: 15,
                          ),
                          markers: markers,
                          onMapCreated: (controller) =>
                              mapController = controller,
                          myLocationEnabled: !widget.isViewer,
                          myLocationButtonEnabled: !widget.isViewer,
                        ),
                      ),
                      if (!widget.isViewer) ...[
                        const SizedBox(height: 8),
                        if (searchHistory.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Search History',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: searchHistory.length,
                            itemBuilder: (context, index) {
                              final location = searchHistory[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(location['address'] as String),
                                  onTap: () {
                                    Navigator.pop(context, {
                                      'latitude': location['location'].latitude,
                                      'longitude':
                                          location['location'].longitude,
                                      'address': location['address'],
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (currentPosition != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.my_location),
                              title: const Text('Send current location'),
                              subtitle: Text(currentAddress ?? ''),
                              onTap: () {
                                Navigator.pop(context, {
                                  'latitude': currentPosition!.latitude,
                                  'longitude': currentPosition!.longitude,
                                  'address': currentAddress,
                                });
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!widget.isViewer && placesSuggestions.isNotEmpty)
            Positioned(
              top: 60,
              left: 8,
              right: 8,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: placesSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(placesSuggestions[index]['description']),
                      onTap: () {
                        searchController.text =
                            placesSuggestions[index]['description'];
                        setState(() {
                          placesSuggestions = [];
                        });
                        _searchLocation();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
