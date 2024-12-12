import 'package:flutter/material.dart';
import '../../../widgets/filters/distance_filter.dart';
import '../../../widgets/filters/time_filter.dart';
import '../../../widgets/filters/recurrence_filter.dart';
import '../../../widgets/filters/type_filter.dart';

class MapFilters extends StatelessWidget {
  const MapFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate equal width for each button
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 50) / 4; // 40 = total horizontal padding (20 * 2)

    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: buttonWidth,
              child: DistanceFilter(
                onDistanceChanged: (double distance) {
                  print('Selected distance: ${distance.round()} meters');
                },
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: TimeFilter(
                onTimeChanged: (int hours) {
                  print('Selected time: $hours hours');
                },
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: RecurrenceFilter(
                onTypeChanged: (RecurrenceType type) {
                  print('Selected type: ${type.name}');
                },
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: TypeFilter(
                onTypesChanged: (List<EventType> types) {
                  print('Selected types: ${types.map((t) => t.name).join(', ')}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 