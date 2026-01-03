class AppConstants {
  AppConstants._();

  // ==========================================
  // SUPABASE CONFIG
  // ==========================================
  static const String supabaseUrl = 'https://vtpusrpxucshpllclayz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ow6cODyxsvghdCkOcSE0YA_9qXpAMqo';

  // ==========================================
  // APP INFO
  // ==========================================
  static const String appName = 'VMS Green Crescent';
  static const String appVersion = '1.0.0';

  // ==========================================
  // EMIRATES
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
  // CAR MAKES & MODELS
  // ==========================================
  static const List<String> carMakes = [
    'Toyota',
    'Nissan',
    'Honda',
    'Mitsubishi',
    'Ford',
    'Chevrolet',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Lexus',
    'Hyundai',
    'Kia',
    'Mazda',
    'Volkswagen',
    'Jeep',
    'Land Rover',
    'Porsche',
    'GMC',
    'Infiniti',
    'Other',
  ];

  static const Map<String, List<String>> carModels = {
    'Toyota': ['Camry', 'Corolla', 'Land Cruiser', 'Prado', 'RAV4', 'Hilux', 'Yaris', 'Fortuner', 'Avalon', 'Other'],
    'Nissan': ['Altima', 'Patrol', 'X-Trail', 'Sunny', 'Sentra', 'Maxima', 'Pathfinder', 'Kicks', 'Other'],
    'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot', 'HR-V', 'City', 'Odyssey', 'Other'],
    'Mitsubishi': ['Pajero', 'Outlander', 'ASX', 'Lancer', 'Eclipse Cross', 'Montero', 'Other'],
    'Ford': ['F-150', 'Explorer', 'Expedition', 'Mustang', 'Edge', 'Escape', 'Bronco', 'Other'],
    'Chevrolet': ['Tahoe', 'Suburban', 'Silverado', 'Camaro', 'Malibu', 'Traverse', 'Equinox', 'Other'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X3', 'X5', 'X7', 'M3', 'M5', 'Other'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'GLS', 'AMG GT', 'Other'],
    'Audi': ['A3', 'A4', 'A6', 'A8', 'Q3', 'Q5', 'Q7', 'Q8', 'Other'],
    'Lexus': ['ES', 'IS', 'LS', 'RX', 'NX', 'GX', 'LX', 'Other'],
    'Hyundai': ['Sonata', 'Elantra', 'Tucson', 'Santa Fe', 'Palisade', 'Accent', 'Kona', 'Other'],
    'Kia': ['Optima', 'K5', 'Sportage', 'Sorento', 'Telluride', 'Cerato', 'Carnival', 'Other'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-5', 'CX-9', 'CX-30', 'MX-5', 'Other'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Touareg', 'Jetta', 'Arteon', 'Other'],
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Gladiator', 'Other'],
    'Land Rover': ['Range Rover', 'Range Rover Sport', 'Discovery', 'Defender', 'Evoque', 'Velar', 'Other'],
    'Porsche': ['911', 'Cayenne', 'Panamera', 'Macan', 'Taycan', 'Other'],
    'GMC': ['Sierra', 'Yukon', 'Terrain', 'Acadia', 'Canyon', 'Other'],
    'Infiniti': ['Q50', 'Q60', 'QX50', 'QX60', 'QX80', 'Other'],
    'Other': ['Other'],
  };

  // ==========================================
  // VEHICLE OPTIONS
  // ==========================================
  static List<int> get vehicleYears {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => currentYear - index);
  }

  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'Hybrid',
    'Electric',
    'Plug-in Hybrid',
  ];

  static const List<String> vehicleColors = [
    'White',
    'Black',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Brown',
    'Gold',
    'Green',
    'Orange',
    'Yellow',
    'Other',
  ];

  // ==========================================
  // BOOKING
  // ==========================================
  static const List<String> timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
  ];
}