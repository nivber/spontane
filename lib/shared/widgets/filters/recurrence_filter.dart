import 'package:flutter/material.dart';

enum RecurrenceType {
  oneTime,
  permanent,
  limited
}

class RecurrenceFilter extends StatefulWidget {
  final Function(RecurrenceType) onTypeChanged;

  const RecurrenceFilter({
    required this.onTypeChanged,
    Key? key,
  }) : super(key: key);

  @override
  _RecurrenceFilterState createState() => _RecurrenceFilterState();
}

class _RecurrenceFilterState extends State<RecurrenceFilter> {
  RecurrenceType _currentType = RecurrenceType.oneTime;

  void _showTypeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Event Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('One Time'),
                leading: Radio<RecurrenceType>(
                  value: RecurrenceType.oneTime,
                  groupValue: _currentType,
                  onChanged: (RecurrenceType? value) {
                    setState(() {
                      _currentType = value!;
                      widget.onTypeChanged(_currentType);
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Permanent'),
                leading: Radio<RecurrenceType>(
                  value: RecurrenceType.permanent,
                  groupValue: _currentType,
                  onChanged: (RecurrenceType? value) {
                    setState(() {
                      _currentType = value!;
                      widget.onTypeChanged(_currentType);
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Limited Time'),
                leading: Radio<RecurrenceType>(
                  value: RecurrenceType.limited,
                  groupValue: _currentType,
                  onChanged: (RecurrenceType? value) {
                    setState(() {
                      _currentType = value!;
                      widget.onTypeChanged(_currentType);
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTypeSelector,
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
          _currentType.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 