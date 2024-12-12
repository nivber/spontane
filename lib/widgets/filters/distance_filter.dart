import 'package:flutter/material.dart';

class DistanceFilter extends StatefulWidget {
  final Function(double) onDistanceChanged;

  const DistanceFilter({
    required this.onDistanceChanged,
    Key? key,
  }) : super(key: key);

  @override
  _DistanceFilterState createState() => _DistanceFilterState();
}

class _DistanceFilterState extends State<DistanceFilter> {
  double _currentDistance = 1000; // Default 1km

  void _showDistanceSlider() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Distance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _currentDistance,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    onChanged: (value) {
                      setDialogState(() {
                        setState(() {
                          _currentDistance = value;
                        });
                      });
                    },
                  ),
                  Text(
                    '${(_currentDistance / 1000).toStringAsFixed(1)} km',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDistanceChanged(_currentDistance);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDistanceSlider,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${(_currentDistance / 1000).toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 