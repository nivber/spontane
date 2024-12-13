import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geolocator/geolocator.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _userNameController = TextEditingController();
  
  String _selectedType = 'Sale';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _imageUrls = [];
  GeoPoint? _selectedLocation;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      for (var image in images) {
        String url = await _uploadImage(File(image.path));
        setState(() {
          _imageUrls.add(url);
        });
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('events_images')
        .child(fileName);
    
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      try {
        await FirebaseFirestore.instance.collection('posts').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'event_type': _selectedType,
          'date': _selectedDate,
          'time': DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
              _selectedTime.hour, _selectedTime.minute),
          'lat_long': _selectedLocation,
          'place': _placeController.text,
          'user_name': _userNameController.text,
          'image_gallery_url': _imageUrls,
          'comments': 0,
          'likes': 0,
          'shares': 0,
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding event: $e')),
        );
      }
    }
  }

  void _handlePlaceSelection(Prediction prediction) {
    setState(() {
      _placeController.text = prediction.description ?? '';
      if (prediction.lat != null && prediction.lng != null) {
        _selectedLocation = GeoPoint(
          double.parse(prediction.lat!),
          double.parse(prediction.lng!),
        );
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _selectedLocation = GeoPoint(position.latitude, position.longitude);
        _placeController.text = 'Current Location';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _placeController,
                      googleAPIKey: "AIzaSyCRa3fwxFQRctwLAh_784aAin9hE5SaIik",
                      inputDecoration: InputDecoration(
                        labelText: 'Place',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      debounceTime: 800,
                      countries: ["il"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        _handlePlaceSelection(prediction);
                      },
                      itemClick: (Prediction prediction) {
                        _handlePlaceSelection(prediction);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
            ),
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'User Name'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(labelText: 'Event Type'),
              items: ['Sale', 'Art', 'Sports', 'Party', 'Performance', 'SpecialOffer']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            ListTile(
              title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            ListTile(
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) setState(() => _selectedTime = time);
              },
            ),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Add Images'),
            ),
            if (_imageUrls.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image.network(_imageUrls[index]),
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed: _submitEvent,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
} 