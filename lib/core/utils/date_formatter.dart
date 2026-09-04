import 'package:intl/intl.dart';

/// Clean, production-ready date & time formatters
class DateFormatter {
  static final DateFormat _tripDateRangeFormat = DateFormat('d MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('d MMM');
  static final DateFormat _dobFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _chatTimeFormat = DateFormat('hh:mm a');

  /// Formats a trip date range, e.g., "10 Oct - 16 Oct 2026" or "28 Dec 2026 - 2 Jan 2027"
  static String formatTripDates(DateTime start, DateTime end) {
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${start.day} – ${end.day} ${DateFormat('MMM yyyy').format(start)}';
      }
      return '${_shortDateFormat.format(start)} – ${_shortDateFormat.format(end)} ${start.year}';
    }
    return '${_tripDateRangeFormat.format(start)} – ${_tripDateRangeFormat.format(end)}';
  }

  /// Formats number of days duration, e.g. "6 Days / 5 Nights"
  static String formatDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    if (days <= 1) return '1 Day Trip';
    final nights = days - 1;
    return '$days Days / $nights ${nights == 1 ? 'Night' : 'Nights'}';
  }

  /// Formats date of birth
  static String formatDob(DateTime dob) => _dobFormat.format(dob);

  /// Formats chat timestamp cleanly (e.g. "Today 10:30 AM", "Yesterday 04:15 PM", "12 Oct 11:20 AM")
  static String formatChatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return _chatTimeFormat.format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday ${_chatTimeFormat.format(dateTime)}';
    } else {
      return '${_shortDateFormat.format(dateTime)}, ${_chatTimeFormat.format(dateTime)}';
    }
  }

  /// Relative time ago formatter (e.g., "2m ago", "1h ago", "3d ago")
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _shortDateFormat.format(dateTime);
    }
  }
}
