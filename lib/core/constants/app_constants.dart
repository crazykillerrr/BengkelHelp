class AppConstants {
  // App Info
  static const String appName = 'BengkelHelp';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';
  
  // Collections
  static const String usersCollection = 'users';
  static const String bengkelsCollection = 'bengkels';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String remindersCollection = 'reminders';
  static const String transactionsCollection = 'transactions';
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderAccepted = 'accepted';
  static const String orderRejected = 'rejected';
  static const String orderInProgress = 'in_progress';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';
  
  // Payment Methods
  static const String paymentBengkelPay = 'bengkelpay';
  static const String paymentCash = 'cash';
  
  // Product Categories
  static const List<String> productCategories = [
    'Oli & Pelumas',
    'Ban',
    'Aki',
    'Spare Part Mesin',
    'Spare Part Body',
    'Aksesoris',
    'Lainnya',
  ];
  
  // Service Categories
  static const List<String> serviceCategories = [
    'Servis Berkala',
    'Ganti Oli',
    'Tune Up',
    'Ganti Ban',
    'AC Mobil',
    'Body Repair',
    'Cat & Polish',
    'Cuci Steam',
    'Darurat',
  ];
  
  // Reminder Types
  static const String reminderOilChange = 'oil_change';
  static const String reminderService = 'service';
  static const String reminderTireChange = 'tire_change';
  
  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // API Keys (untuk production, pindahkan ke environment variables)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Limits
  static const int maxSearchRadius = 50; // km
  static const int chatMessageLimit = 50;
  static const double minTopUpAmount = 10000;
  static const double maxTopUpAmount = 10000000;
}