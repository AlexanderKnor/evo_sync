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
                  : (isDarkMode ? Colors.white70 : Colors.grey[800]),
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * 0.12, // Responsive width
            height:
                MediaQuery.of(context).size.width * 0.12, // Responsive height
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.blue
                  : (isDarkMode ? Colors.grey[850] : Colors.grey[200]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isToday
                      ? Colors.blue.withOpacity(0.4)
                      : (isDarkMode ? Colors.black54 : Colors.grey[400]!),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isToday ? Colors.blueAccent : Colors.transparent,
                width: 2,
              ),
              gradient: isToday
                  ? LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.grey[800]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
