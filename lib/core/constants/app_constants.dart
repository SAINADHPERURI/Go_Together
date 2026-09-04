/// Core application constants for GoTogether
class AppConstants {
  static const String appName = 'GoTogether';
  static const String appTagline = 'Travel with people who match your pace';

  // Popular curated destinations across India & abroad
  static const List<String> popularDestinations = [
    'Kashmir',
    'Manali',
    'Ladakh',
    'Tirupati',
    'Varanasi',
    'Rishikesh',
    'Coorg',
    'Munnar',
    'Ooty',
    'Goa',
    'Spiti Valley',
    'Meghalaya',
    'Kedarnath',
    'Puri',
    'Rameshwaram',
    'Udaipur',
    'Jaipur',
    'Hampi',
    'Gokarna',
    'Andaman',
  ];

  // Starting major cities
  static const List<String> majorCities = [
    'Chennai',
    'Bengaluru',
    'Hyderabad',
    'Mumbai',
    'Delhi NCR',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Kochi',
    'Coimbatore',
    'Visakhapatnam',
    'Chandigarh',
    'Lucknow',
    'Jaipur',
  ];

  // All trip types
  static const List<String> tripTypes = [
    'Adventure',
    'Trekking',
    'Climbing',
    'Hill Station',
    'Vacation',
    'Weekend Trip',
    'Road Trip',
    'Cultural',
    'Yatra',
    'Pilgrimage',
    'Spiritual Journey',
    'Camping',
    'Nature Retreat',
    'Comfortable Travel',
    'Other Group Travel',
  ];

  // Indian Languages for travel communication
  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Bengali',
    'Gujarati',
    'Punjabi',
    'Odia',
  ];

  // Travel interests & styles
  static const List<String> travelInterests = [
    'Mountain Treks',
    'Spiritual Yatras',
    'Heritage & Temples',
    'Beach Sunsets',
    'Campfires & Stargazing',
    'Photography',
    'Local Food Tasting',
    'Road Trips & Biking',
    'Wildlife & Nature',
    'Relaxed Sightseeing',
    'Budget Travel',
    'Comfort Stays',
  ];

  // Limits
  static const int minTripCapacity = 2;
  static const int maxTripCapacity = 30;
  static const int defaultTripCapacity = 6;
  static const int maxBioLength = 300;
  static const int maxTripDescriptionLength = 1000;
}
