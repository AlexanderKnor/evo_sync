import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const DateWidget({
    Key? key,
    required this.date,
    required this.isToday,
    required this.isDarkMode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            DateFormat.E('de_DE').format(date),
            style: TextStyle(
              fontSize: 16,
              color: isToday
                  ? Colors.blue
                  : (isDarkMode ? Colors.white54 : Colors.black54),
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.blue
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[300]),
              shape: BoxShape.circle,
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
              border: Border.all(
                color: isToday ? Colors.blueAccent : Colors.transparent,
                width: 2,
              ),
              gradient: isToday
                  ? const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isToday
                    ? Colors.white
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
