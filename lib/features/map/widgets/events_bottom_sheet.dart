import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsBottomSheet extends StatefulWidget {
  final DraggableScrollableController controller;
  final GoogleMapController? mapController;
  final Set<Marker> markers;
  final GlobalKey<State<EventsBottomSheet>> _key = GlobalKey();

  EventsBottomSheet({
    Key? key,
    required this.controller,
    this.mapController,
    required this.markers,
  }) : super(key: key);

  void showEventDetails(Map<String, dynamic> event) {
    (_key.currentState as _EventsBottomSheetState)._showEventDetails(event);
  }

  @override
  State<EventsBottomSheet> createState() => _EventsBottomSheetState();
}

class _EventsBottomSheetState extends State<EventsBottomSheet> {
  Map<String, dynamic>? selectedEvent;

  void _moveToLocation(BuildContext context, GeoPoint location) {
    widget.mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(location.latitude, location.longitude),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    setState(() {
      selectedEvent = event;
      widget.controller.animateTo(
        0.9,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  ImageProvider _getEventImage(Map<String, dynamic> event) {
    try {
      final imageUrls = event['image_gallery_url'];
      if (imageUrls != null && imageUrls is List && imageUrls.isNotEmpty) {
        return NetworkImage(imageUrls[0]);
      }
    } catch (e) {
      print('Error loading event image: $e');
    }
    return NetworkImage('https://via.placeholder.com/50');
  }

  Widget _buildEventList(List<QueryDocumentSnapshot> events, ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events Near You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('${events.length} found'),
              ],
            ),
          );
        }

        final event = events[index - 1].data() as Map<String, dynamic>;
        final location = event['lat_long'] as GeoPoint;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getEventImage(event),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Text(event['title'] ?? 'No Title'),
            subtitle: Text(
              '${event['place'] ?? 'No Location'}\n${event['event_type'] ?? 'No Type'}',
            ),
            isThreeLine: true,
            onTap: () {
              _moveToLocation(context, location);
              _showEventDetails(event);
            },
          ),
        );
      },
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedEvent = null;
                    widget.controller.animateTo(
                      0.15,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                },
              ),
              Text(
                'Event Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Event image
        if (event['image_gallery_url'] != null && 
            event['image_gallery_url'] is List && 
            (event['image_gallery_url'] as List).isNotEmpty)
          Container(
            height: 200,
            width: double.infinity,
            child: Image.network(
              event['image_gallery_url'][0],
              fit: BoxFit.cover,
            ),
          ),
        // Event details
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                event['place'] ?? 'No Location',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Text(
                event['description'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Date: ${event['date']?.toDate().toString().split(' ')[0] ?? 'Not specified'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Time: ${event['time']?.toDate().toString().split(' ')[1].substring(0, 5) ?? 'Not specified'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: selectedEvent == null
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return _buildEventList(snapshot.data!.docs, scrollController);
                  },
                )
              : SingleChildScrollView(
                  controller: scrollController,
                  child: _buildEventDetails(selectedEvent!),
                ),
        );
      },
    );
  }
} 