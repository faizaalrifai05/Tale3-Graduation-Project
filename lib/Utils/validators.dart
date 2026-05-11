class Validators {
  // ─── Email ──────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ─── Password (login – just checks not empty) ────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // ─── Password (registration – stronger rules) ────────────────────────────

  static String? registrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\\;'
        r"'`~/]"))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // ─── Full Name ───────────────────────────────────────────────────────────

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Please enter your full name';
    }
    if (!value.trim().contains(' ')) {
      return 'Please enter both first and last name';
    }
    return null;
  }

  // ─── National ID ─────────────────────────────────────────────────────────

  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'National ID is required';
    }
    // Jordanian National IDs are 9 digits
    if (!RegExp(r'^\d{9,12}$').hasMatch(value.trim())) {
      return 'Please enter a valid National ID (9–12 digits)';
    }
    return null;
  }

  // ─── Phone Number ────────────────────────────────────────────────────────
  //
  // Must start with 07 and be exactly 10 digits.
  // e.g. 0791234567

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-]'), '');

    if (!RegExp(r'^07\d{8}$').hasMatch(cleaned)) {
      return 'Phone number must start with 07 and be 10 digits';
    }

    return null;
  }

  // ─── Birthday (must be 18 or older) ──────────────────────────────────────

  static String? birthday(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    final today = DateTime.now();
    final eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);
    if (value.isAfter(eighteenYearsAgo)) {
      return 'You must be at least 18 years old to register';
    }
    return null;
  }

  // ─── Car Model ───────────────────────────────────────────────────────────

  static String? carModel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Car model is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid car model';
    }
    return null;
  }

  // ─── Plate Number ────────────────────────────────────────────────────────

  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plate number is required';
    }
    // Jordanian plates: digits and letters, e.g. "1234 ABC" or "12-3456"
    if (value.trim().length < 4) {
      return 'Please enter a valid plate number';
    }
    return null;
  }

  // ─── Year ────────────────────────────────────────────────────────────────

  static String? vehicleYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value.trim());
    if (year == null) {
      return 'Please enter a valid year';
    }
    final currentYear = DateTime.now().year;
    if (year < 1990 || year > currentYear + 1) {
      return 'Enter a year between 1990 and $currentYear';
    }
    return null;
  }

  // ─── Generic required field ──────────────────────────────────────────────

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}