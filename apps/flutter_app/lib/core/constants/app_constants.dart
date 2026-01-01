// ============================================
// APP CONSTANTS
// Static data used throughout the app
// ============================================
class AppConstants {
  // Prevent instantiation
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
  // CAR MAKES (Popular in UAE)
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
      'Land Cruiser',
      'Prado',
      'Camry',
      'Corolla',
      'RAV4',
      'Highlander',
      'Fortuner',
      'Hilux',
      'Yaris',
      'Avalon',
      'Supra',
      '86',
      'Other',
    ],
    'Nissan': [
      'Patrol',
      'Altima',
      'Maxima',
      'Sentra',
      'X-Trail',
      'Pathfinder',
      'Kicks',
      'Sunny',
      'GT-R',
      '370Z',
      'Other',
    ],
    'Lexus': [
      'LX',
      'GX',
      'RX',
      'NX',
      'ES',
      'IS',
      'LS',
      'LC',
      'RC',
      'UX',
      'Other',
    ],
    'BMW': [
      'X5',
      'X6',
      'X7',
      'X3',
      'X4',
      '7 Series',
      '5 Series',
      '3 Series',
      'M3',
      'M4',
      'M5',
      'Z4',
      'Other',
    ],
    'Mercedes-Benz': [
      'G-Class',
      'S-Class',
      'E-Class',
      'C-Class',
      'A-Class',
      'GLE',
      'GLC',
      'GLA',
      'AMG GT',
      'Maybach',
      'Other',
    ],
    'Audi': [
      'Q7',
      'Q8',
      'Q5',
      'Q3',
      'A8',
      'A6',
      'A4',
      'A3',
      'RS6',
      'RS7',
      'R8',
      'e-tron',
      'Other',
    ],
    'Porsche': [
      'Cayenne',
      '911',
      'Panamera',
      'Macan',
      'Taycan',
      'Cayman',
      'Boxster',
      'Other',
    ],
    'Land Rover': [
      'Defender',
      'Discovery',
      'Discovery Sport',
      'Freelander',
      'Other',
    ],
    'Range Rover': [
      'Range Rover',
      'Range Rover Sport',
      'Range Rover Velar',
      'Range Rover Evoque',
      'Other',
    ],
    'Chevrolet': [
      'Tahoe',
      'Suburban',
      'Silverado',
      'Camaro',
      'Corvette',
      'Malibu',
      'Impala',
      'Trailblazer',
      'Other',
    ],
    'GMC': [
      'Yukon',
      'Sierra',
      'Terrain',
      'Acadia',
      'Canyon',
      'Other',
    ],
    'Ford': [
      'Explorer',
      'Expedition',
      'F-150',
      'Mustang',
      'Edge',
      'Escape',
      'Bronco',
      'Other',
    ],
    'Honda': [
      'Accord',
      'Civic',
      'CR-V',
      'Pilot',
      'HR-V',
      'Odyssey',
      'Other',
    ],
    'Hyundai': [
      'Palisade',
      'Santa Fe',
      'Tucson',
      'Sonata',
      'Elantra',
      'Kona',
      'Other',
    ],
    'Kia': [
      'Telluride',
      'Sorento',
      'Sportage',
      'K5',
      'Optima',
      'Carnival',
      'Other',
    ],
    'Mazda': [
      'CX-9',
      'CX-5',
      'CX-30',
      'Mazda6',
      'Mazda3',
      'MX-5',
      'Other',
    ],
    'Mitsubishi': [
      'Pajero',
      'Montero',
      'Outlander',
      'Eclipse Cross',
      'ASX',
      'L200',
      'Other',
    ],
    'Infiniti': [
      'QX80',
      'QX60',
      'QX50',
      'Q50',
      'Q60',
      'Other',
    ],
    'Jeep': [
      'Grand Cherokee',
      'Wrangler',
      'Cherokee',
      'Compass',
      'Gladiator',
      'Other',
    ],
    'Dodge': [
      'Durango',
      'Charger',
      'Challenger',
      'Ram 1500',
      'Other',
    ],
    'Volkswagen': [
      'Touareg',
      'Tiguan',
      'Passat',
      'Golf',
      'Jetta',
      'Arteon',
      'Other',
    ],
    'Bentley': [
      'Bentayga',
      'Continental GT',
      'Flying Spur',
      'Other',
    ],
    'Ferrari': [
      '488',
      'F8 Tributo',
      'Roma',
      'Portofino',
      'SF90',
      '812',
      'Other',
    ],
    'Lamborghini': [
      'Urus',
      'Huracán',
      'Aventador',
      'Other',
    ],
    'Maserati': [
      'Levante',
      'Ghibli',
      'Quattroporte',
      'GranTurismo',
      'Other',
    ],
    'Rolls-Royce': [
      'Cullinan',
      'Phantom',
      'Ghost',
      'Wraith',
      'Dawn',
      'Other',
    ],
    'Other': [
      'Other',
    ],
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
    'White',
    'Black',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Brown',
    'Beige',
    'Gold',
    'Orange',
    'Yellow',
  ];

  // ==========================================
  // VEHICLE YEARS
  // ==========================================
  static List<int> get vehicleYears {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => currentYear - index);
  }

  // ==========================================
  // TIME SLOTS FOR BOOKING
  // ==========================================
  static const List<String> timeSlots = [
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];

  // ==========================================
  // BOOKING STATUS
  // ==========================================
  static const List<String> bookingStatuses = [
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  // ==========================================
  // TEST VALIDITY (in days)
  // ==========================================
  static const int testValidityDays = 365; // 1 year
  static const int expiryWarningDays = 30; // Warn 30 days before

  // ==========================================
  // API ENDPOINTS (for later use)
  // ==========================================
  static const String baseUrl = 'https://api.vmsplatform.ae';
  
  // ==========================================
  // STORAGE KEYS
  // ==========================================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
}