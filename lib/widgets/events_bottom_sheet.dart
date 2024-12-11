import 'package:flutter/material.dart';

class EventsBottomSheet extends StatelessWidget {
  final DraggableScrollableController controller;

  const EventsBottomSheet({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      snapSizes: [0.2, 0.5, 0.9],
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Events Near You!!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Example content
                    for (int i = 0; i < 20; i++)
                      ListTile(
                        title: Text('Event $i'),
                        subtitle: Text('Descrition for event $i'),
                        leading: Icon(Icons.event),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 