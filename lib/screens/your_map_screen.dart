import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../widgets/events_bottom_sheet.dart';
import '../widgets/side_menu.dart';
import '../widgets/filters/distance_filter.dart';
import '../widgets/filters/time_filter.dart';
import '../widgets/filters/recurrence_filter.dart';
import '../widgets/filters/type_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/gestures.dart' as gestures;
import 'package:geolocator/geolocator.dart';

import 'map/components/map_filters.dart';


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(31.7683, 35.2137);
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<Marker> _markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _locationEnabled = false;
  Map<String, BitmapDescriptor> _markerIcons = {};
  bool _iconsLoaded = false;

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      // Request permissions using permission_handler
      await Permission.locationWhenInUse.request();
      await Permission.locationAlways.request();

      LocationPermission geoPermission = await Geolocator.checkPermission();
      if (geoPermission == LocationPermission.denied) {
        geoPermission = await Geolocator.requestPermission();
        if (geoPermission == LocationPermission.denied) {
          print('Location permissionsard denied');
          return;
        }
      }

      setState(() {
        _locationEnabled = true;
      });
      await _getCurrentLocation();
      await _loadMarkers();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error requesting location permission: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // First try to get last known location for faster response
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        setState(() {
          _currentPosition = lastKnownPosition;
        });
        _updateCamera(lastKnownPosition);
      }

      // Then get precise current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 10),
      );
      
      print('Current position: ${position.latitude}, ${position.longitude}');
      
      setState(() {
        _currentPosition = position;
      });
      
      _updateCamera(position);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateCamera(Position position) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
          bearing: 0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Add this method to handle initialization
  Future<void> _initialize() async {
    try {
      // First load marker icons
      await _loadMarkerIcons();
      print('Marker icons loaded: ${_markerIcons.length}');
      
      // Then request location permission and load markers
      await _requestLocationPermission();
    } catch (e) {
      print('Error in initialization: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the _loadMarkerIcons method
  Future<void> _loadMarkerIcons() async {
    if (_iconsLoaded) return; // Skip if already loaded
    
    try {
      final markerTypes = ['sale', 'performance', 'party', 'art', 'sports', 'specialoffer'];
      
      for (var type in markerTypes) {
        try {
          print('Attempting to load marker icon for: $type');
          final String assetPath = 'assets/images/markers/${type}_marker.png';
          print('Asset path: $assetPath');
          
          final icon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(128, 128)),
            assetPath,
          );
          _markerIcons[type] = icon;
          print('Successfully loaded marker icon for: $type');
        } catch (e) {
          print('Error loading marker icon for $type: $e');
        }
      }
      _iconsLoaded = true;
    } catch (e) {
      print('Error in _loadMarkerIcons: $e');
    }
  }

  // Update _getMarkerIcon method
  BitmapDescriptor _getMarkerIcon(String eventType) {
    String normalizedType = eventType.toLowerCase().trim();
    
    // Handle similar types
    if (normalizedType.contains('culinary') || 
        normalizedType.contains('food') || 
        normalizedType.contains('social')) {
      normalizedType = 'party';
    } else if (normalizedType.contains('sport')) {
      normalizedType = 'sports';
    } else if (normalizedType.contains('show') || 
               normalizedType.contains('demonstration')) {
      normalizedType = 'performance';
    }

    // Try to get custom icon first
    if (_markerIcons.containsKey(normalizedType)) {
      print('Using custom icon for: $normalizedType');
      return _markerIcons[normalizedType]!;
    }

    // Fallback to colored markers if custom icon not found
    print('Using fallback colored marker for: $normalizedType');
    switch (normalizedType) {
      case 'sale':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'performance':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'party':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
      case 'art':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'sports':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'specialoffer':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        print('No icon match for type: $normalizedType'); // Debug print
        return BitmapDescriptor.defaultMarker;
    }
  }

  // Update _loadMarkers to wait for icons
  Future<void> _loadMarkers() async {
    if (!_iconsLoaded) {
      print('Icons not loaded yet, loading now...');
      await _loadMarkerIcons();
    }
    
    try {
      final QuerySnapshot snapshot = await _firestore.collection('posts').get();
      print('Loaded ${snapshot.docs.length} posts from Firestore');
      
      final newMarkers = <Marker>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final location = data['lat_long'];
        final eventType = data['event_type'] ?? 'default';
        
        if (location is GeoPoint) {
          final icon = _getMarkerIcon(eventType);
          print('Creating marker for ${doc.id} with type $eventType');
          
          newMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(location.latitude, location.longitude),
              icon: icon,
              infoWindow: InfoWindow(
                title: data['title'] ?? 'No Title',
                snippet: data['description'] ?? 'No Description',
              ),
            ),
          );
        }
      }
      
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
        print('Updated markers on map: ${_markers.length}');
      });
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _handleSearchSelection(Prediction prediction) {
    // Handle the selected place here
    print(prediction.description);
    // You can use prediction.placeId to get more details about the place
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null 
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _center,
              zoom: 15.0,
            ),
            myLocationEnabled: _locationEnabled,
            myLocationButtonEnabled: _locationEnabled,
            markers: _markers,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: true,
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Filter buttons row
                const SizedBox(height: 10),
                // Existing search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Menu Button
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ),
                      // Search Bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: TextEditingController(),
                            googleAPIKey: "AIzaSyCRa3fwxFQRctwLAh_784aAin9hE5SaIik",
                            inputDecoration: InputDecoration(
                              hintText: "Search location",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            ),
                            debounceTime: 800,
                            countries: ["il"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              // Handle the selected place with lat/lng
                              print("Location: ${prediction.lat}, ${prediction.lng}");

                              // Move camera to selected location
                              mapController?.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(
                                    double.parse(prediction.lat ?? "0"),
                                    double.parse(prediction.lng ?? "0"),
                                  ),
                                ),
                              );
                            },
                            itemClick: (Prediction prediction) {
                              _handleSearchSelection(prediction);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: MapFilters(),
                ),
              ],
            ),
          ),
          // Bottom sheet first (lower z-index)
          EventsBottomSheet(controller: _sheetController),
          
          // Location button above the sheet (higher z-index)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 4,
              child: Icon(Icons.my_location, color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onPressed: _getCurrentLocation,
            ),
          ),
          
          // Loading indicator on top
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 