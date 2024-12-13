import 'package:flutter/material.dart';

enum EventType {
  sale('Sale'),
  performance('Performance'),
  party('Party'),
  art('Art'),
  sports('Sports'),
  specialOffer('Special Offer');

  final String label;
  const EventType(this.label);
}

class TypeFilter extends StatefulWidget {
  final Function(List<EventType>) onTypesChanged;

  const TypeFilter({
    required this.onTypesChanged,
    Key? key,
  }) : super(key: key);

  @override
  _TypeFilterState createState() => _TypeFilterState();
}

class _TypeFilterState extends State<TypeFilter> {
  final Set<EventType> _selectedTypes = {};

  void _showTypeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Event Types'),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EventType.values.map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(type.label),
                    onSelected: (bool selected) {
                      setDialogState(() {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      });
                    },
                    selectedColor: Colors.blue.withOpacity(0.25),
                    checkmarkColor: Colors.blue,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onTypesChanged(_selectedTypes.toList());
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
          _selectedTypes.isEmpty ? 'Types' : '${_selectedTypes.length} Types',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 