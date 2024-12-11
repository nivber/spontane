import 'package:flutter/material.dart';

class TimeFilter extends StatefulWidget {
  final Function(int) onTimeChanged;

  const TimeFilter({
    required this.onTimeChanged,
    Key? key,
  }) : super(key: key);

  @override
  _TimeFilterState createState() => _TimeFilterState();
}

class _TimeFilterState extends State<TimeFilter> {
  double _currentHours = 1; // Default 1 hour

  void _showTimeSlider() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _currentHours,
                    min: 1,
                    max: 24,
                    divisions: 23,
                    onChanged: (value) {
                      setDialogState(() {
                        setState(() {
                          _currentHours = value;
                        });
                      });
                    },
                  ),
                  Text(
                    '${_currentHours.round()} ${_currentHours.round() == 1 ? 'hour' : 'hours'}',
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
                    widget.onTimeChanged(_currentHours.round());
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
      onTap: _showTimeSlider,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          '${_currentHours.round()}h',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 