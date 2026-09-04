/// Form validation rules for GoTogether
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateDateOfBirth(DateTime? dob) {
    if (dob == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < 18) {
      return 'You must be at least 18 years old to use GoTogether';
    }
    if (age > 105) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }

  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Maximum member capacity is required';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid integer';
    }
    if (number < 2) {
      return 'Capacity must be at least 2 people (including you)';
    }
    if (number > 50) {
      return 'Capacity cannot exceed 50 people for a single group';
    }
    return null;
  }

  static String? validateTripDates(DateTime? start, DateTime? end) {
    if (start == null) {
      return 'Start date is required';
    }
    if (end == null) {
      return 'End date is required';
    }
    final today = DateTime.now().subtract(const Duration(hours: 24));
    if (start.isBefore(today)) {
      return 'Start date cannot be in the past';
    }
    if (end.isBefore(start)) {
      return 'End date must be on or after the start date';
    }
    if (end.difference(start).inDays > 45) {
      return 'Trip duration cannot exceed 45 days';
    }
    return null;
  }
}
