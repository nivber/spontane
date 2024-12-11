import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'widgets/events_bottom_sheet.dart';
import 'widgets/side_menu.dart';
import 'widgets/filters/distance_filter.dart';
import 'widgets/filters/time_filter.dart';
import 'widgets/filters/recurrence_filter.dart';
import 'widgets/filters/type_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(32.0853, 34.7818);
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<Marker> _markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('posts').get();
      print('Found ${snapshot.docs.length} posts');

      setState(() {
        _markers.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing document: ${doc.id}');
          print('Document data: $data');
          
          final location = data['location'] as GeoPoint;
          print('Location: ${location.latitude}, ${location.longitude}');

          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: data['title'] ?? 'No Title',
                snippet: data['description'] ?? 'No Description',
              ),
            ),
          );
        }
        print('Added ${_markers.length} markers');
      });
    } catch (e, stackTrace) {
      print('Error loading markers: $e');
      print('Stack trace: $stackTrace');
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
              target: _center,
              zoom: 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Filter buttons row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(width: 4),
                      DistanceFilter(
                        onDistanceChanged: (double distance) {
                          print('Selected distance: ${distance.round()} meters');
                        },
                      ),
                      SizedBox(width: 4),
                      TimeFilter(
                        onTimeChanged: (int hours) {
                          print('Selected time: $hours hours');
                        },
                      ),
                      SizedBox(width: 4),
                      RecurrenceFilter(
                        onTypeChanged: (RecurrenceType type) {
                          print('Selected type: ${type.name}');
                        },
                      ),
                      SizedBox(width: 4),
                      TypeFilter(
                        onTypesChanged: (List<EventType> types) {
                          print('Selected types: ${types.map((t) => t.name).join(', ')}');
                        },
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
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
                            googleAPIKey: "AIzaSyCR a3fwxFQRctwLAh_784aAin9hE5SaIik",
                            inputDecoration: InputDecoration(
                              hintText: "Search location",
                              border: InputBorder.none,
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
              ],
            ),
          ),
          EventsBottomSheet(controller: _sheetController),
        ],
      ),
    );
  }
} 