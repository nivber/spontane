import 'package:flutter/material.dart';
import '../../../shared/widgets/filters/distance_filter.dart';
import '../../../shared/widgets/filters/time_filter.dart';
import '../../../shared/widgets/filters/recurrence_filter.dart';
import '../../../shared/widgets/filters/type_filter.dart';

class MapFilters extends StatelessWidget {
  const MapFilters({Key? key}) : super(key: key);

  void _showFilterDialog(BuildContext context, String filterType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adjust $filterType',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Add specific filter controls based on type
              if (filterType == 'Distance') _buildDistanceFilter(),
              if (filterType == 'Time') _buildTimeFilter(),
              if (filterType == 'Event Type') _buildEventTypeFilter(),
              if (filterType == 'Recurrence') _buildRecurrenceFilter(),
            ],
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Slider(
      value: 1.0,
      min: 0.1,
      max: 10.0,
      divisions: 99,
      label: '1.0 km',
      onChanged: (value) {
        // Handle distance change
      },
    );
  }

  Widget _buildTimeFilter() {
    return Slider(
      value: 1.0,
      min: 1.0,
      max: 24.0,
      divisions: 23,
      label: '1h',
      onChanged: (value) {
        // Handle time change
      },
    );
  }

  Widget _buildEventTypeFilter() {
    return Wrap(
      spacing: 8,
      children: ['Sale', 'Art', 'Sports', 'Party', 'Performance'].map((type) {
        return FilterChip(
          label: Text(type),
          selected: false,
          onSelected: (bool selected) {
            // Handle type selection
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecurrenceFilter() {
    return Wrap(
      spacing: 8,
      children: ['One Time', 'Daily', 'Weekly', 'Monthly'].map((type) {
        return ChoiceChip(
          label: Text(type),
          selected: type == 'One Time',
          onSelected: (bool selected) {
            // Handle recurrence selection
          },
        );
      }).toList(),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          String filterType = label == '1.0 km' ? 'Distance' :
                            label == '1h' ? 'Time' :
                            label == 'oneTime' ? 'Recurrence' : 'Event Type';
          _showFilterDialog(context, filterType);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('1.0 km', Icons.location_on),
          _buildFilterChip('1h', Icons.access_time),
          _buildFilterChip('oneTime', Icons.event),
          _buildFilterChip('Type', Icons.category),
        ],
      ),
    );
  }
}