// ============================================
// APP CONSTANTS
// Central configuration for the app
// ============================================
class AppConstants {
  // Private constructor
  AppConstants._();

  // ==========================================
  // APP INFO
  // ==========================================
  static const String appName = 'VMS Platform';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Vehicle Management System';

  // ==========================================
  // SUPABASE CONFIGURATION
  // ==========================================
  static const String supabaseUrl = 'https://vtpusrpxucshpllclayz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ow6cODyxsvghdCkOcSE0YA_9qXpAMqo';

  // ==========================================
  // UAE EMIRATES
  // ==========================================
  static const List<String> emirates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];

  // ==========================================
  // CAR MAKES
  // ==========================================
  static const List<String> carMakes = [
    'Toyota',
    'Nissan',
    'Lexus',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Porsche',
    'Land Rover',
    'Range Rover',
    'Chevrolet',
    'GMC',
    'Ford',
    'Honda',
    'Hyundai',
    'Kia',
    'Mazda',
    'Mitsubishi',
    'Infiniti',
    'Jeep',
    'Dodge',
    'Volkswagen',
    'Bentley',
    'Ferrari',
    'Lamborghini',
    'Maserati',
    'Rolls-Royce',
    'Other',
  ];

  // ==========================================
  // CAR MODELS BY MAKE
  // ==========================================
  static const Map<String, List<String>> carModels = {
    'Toyota': [
      'Land Cruiser', 'Prado', 'Fortuner', 'Hilux', 'Camry', 'Corolla',
      'Yaris', 'RAV4', 'Highlander', 'Sequoia', 'Avalon', 'Supra',
      '86', 'C-HR', 'Rush', 'Innova', 'Granvia', 'Previa', 'FJ Cruiser', 'Other',
    ],
    'Nissan': [
      'Patrol', 'Pathfinder', 'X-Trail', 'Altima', 'Maxima', 'Sunny',
      'Sentra', 'Kicks', 'Juke', 'Murano', 'Armada', 'Navara',
      'Titan', '370Z', 'GT-R', 'Leaf', 'Qashqai', 'Terra', 'Urvan', 'Other',
    ],
    'Lexus': ['LX', 'GX', 'RX', 'NX', 'UX', 'ES', 'IS', 'LS', 'LC', 'RC', 'LM', 'Other'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X1', 'X3', 'X5', 'X6', 'X7', 'M3', 'M4', 'M5', 'M8', 'Z4', 'i4', 'iX', 'i7', 'Other'],
    'Mercedes-Benz': ['A-Class', 'C-Class', 'E-Class', 'S-Class', 'GLA', 'GLB', 'GLC', 'GLE', 'GLS', 'G-Class', 'AMG GT', 'CLA', 'CLS', 'EQS', 'EQE', 'Maybach', 'Other'],
    'Audi': ['A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron', 'RS3', 'RS5', 'RS6', 'RS7', 'R8', 'TT', 'Other'],
    'Porsche': ['Cayenne', 'Macan', '911', 'Panamera', 'Taycan', 'Boxster', 'Cayman', 'Other'],
    'Land Rover': ['Defender', 'Discovery', 'Discovery Sport', 'Freelander', 'Other'],
    'Range Rover': ['Range Rover', 'Range Rover Sport', 'Range Rover Velar', 'Range Rover Evoque', 'Other'],
    'Chevrolet': ['Tahoe', 'Suburban', 'Traverse', 'Equinox', 'Blazer', 'Trailblazer', 'Silverado', 'Colorado', 'Camaro', 'Corvette', 'Malibu', 'Impala', 'Captiva', 'Other'],
    'GMC': ['Yukon', 'Yukon XL', 'Sierra', 'Terrain', 'Acadia', 'Canyon', 'Hummer EV', 'Other'],
    'Ford': ['Expedition', 'Explorer', 'Edge', 'Escape', 'Bronco', 'F-150', 'Ranger', 'Mustang', 'Taurus', 'Fusion', 'Focus', 'EcoSport', 'Other'],
    'Honda': ['Accord', 'Civic', 'City', 'CR-V', 'HR-V', 'Pilot', 'Passport', 'Odyssey', 'Jazz', 'Other'],
    'Hyundai': ['Tucson', 'Santa Fe', 'Palisade', 'Kona', 'Creta', 'Venue', 'Elantra', 'Sonata', 'Accent', 'Azera', 'Genesis', 'Veloster', 'Ioniq', 'Other'],
    'Kia': ['Sportage', 'Sorento', 'Telluride', 'Seltos', 'Soul', 'Carnival', 'Cerato', 'Optima', 'K5', 'K8', 'Stinger', 'EV6', 'Other'],
    'Mazda': ['CX-3', 'CX-30', 'CX-5', 'CX-9', 'Mazda3', 'Mazda6', 'MX-5', 'Other'],
    'Mitsubishi': ['Pajero', 'Montero', 'Outlander', 'Eclipse Cross', 'ASX', 'L200', 'Lancer', 'Attrage', 'Other'],
    'Infiniti': ['QX80', 'QX60', 'QX55', 'QX50', 'Q50', 'Q60', 'Other'],
    'Jeep': ['Grand Cherokee', 'Cherokee', 'Wrangler', 'Gladiator', 'Compass', 'Renegade', 'Other'],
    'Dodge': ['Durango', 'Charger', 'Challenger', 'Ram 1500', 'Ram 2500', 'Other'],
    'Volkswagen': ['Touareg', 'Tiguan', 'T-Roc', 'Golf', 'Passat', 'Arteon', 'ID.4', 'Teramont', 'Other'],
    'Bentley': ['Bentayga', 'Continental GT', 'Flying Spur', 'Other'],
    'Ferrari': ['488', 'F8', 'SF90', 'Roma', 'Portofino', '812', 'Purosangue', 'Other'],
    'Lamborghini': ['Urus', 'Huracán', 'Aventador', 'Revuelto', 'Other'],
    'Maserati': ['Levante', 'Ghibli', 'Quattroporte', 'MC20', 'Grecale', 'Other'],
    'Rolls-Royce': ['Phantom', 'Ghost', 'Cullinan', 'Wraith', 'Dawn', 'Spectre', 'Other'],
    'Other': ['Other'],
  };

  // ==========================================
  // FUEL TYPES
  // ==========================================
  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'Hybrid',
    'Electric',
    'Plug-in Hybrid',
  ];

  // ==========================================
  // VEHICLE COLORS
  // ==========================================
  static const List<String> vehicleColors = [
    'White', 'Black', 'Silver', 'Gray', 'Red', 'Blue',
    'Green', 'Brown', 'Beige', 'Gold', 'Orange', 'Yellow',
  ];

  // ==========================================
  // VEHICLE YEARS (Last 30 years)
  // ==========================================
  static List<int> get vehicleYears {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => currentYear - index);
  }

  // ==========================================
  // TIME SLOTS
  // ==========================================
  static const List<String> timeSlots = [
    '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM',
    '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM',
    '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM',
  ];

  // ==========================================
  // BOOKING STATUSES
  // ==========================================
  static const List<String> bookingStatuses = [
    'pending', 'confirmed', 'completed', 'cancelled',
  ];

  // ==========================================
  // TEST VALIDITY
  // ==========================================
  static const int testValidityDays = 365;
  static const int testWarningDays = 30;

  // ==========================================
  // STORAGE KEYS
  // ==========================================
  static const String storageAuthToken = 'auth_token';
  static const String storageUserData = 'user_data';
  static const String storageOnboarding = 'onboarding_complete';
}