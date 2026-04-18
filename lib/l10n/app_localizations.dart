import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppLocalizations
//  Access via: AppLocalizations.of(context).someKey
//
//  To add a new string:
//    1. Add a getter below
//    2. Add the translation to _en and _ar maps
// ─────────────────────────────────────────────────────────────────────────────
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ── internal lookup ───────────────────────────────────────────────────────
  String _t(String key) =>
      (isArabic ? _ar[key] : _en[key]) ?? _en[key] ?? key;

  // ── GENERAL ───────────────────────────────────────────────────────────────
  String get appName => _t('appName');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get yes => _t('yes');
  String get no => _t('no');
  String get ok => _t('ok');
  String get confirm => _t('confirm');
  String get loading => _t('loading');
  String get error => _t('error');
  String get success => _t('success');
  String get notNow => _t('notNow');
  String get allow => _t('allow');

  // ── AUTH ──────────────────────────────────────────────────────────────────
  String get email => _t('email');
  String get password => _t('password');
  String get name => _t('name');
  String get phone => _t('phone');
  String get register => _t('register');
  String get login => _t('login');
  String get logout => _t('logout');
  String get forgotPassword => _t('forgotPassword');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get orContinueWith => _t('orContinueWith');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get noAccount => _t('noAccount');

  // ── WELCOME ───────────────────────────────────────────────────────────────
  String get welcomeTagline => _t('welcomeTagline');
  String get welcomeDesc => _t('welcomeDesc');
  String get verifiedDrivers => _t('verifiedDrivers');
  String get affordablePricing => _t('affordablePricing');

  // ── CHOOSE ROLE ───────────────────────────────────────────────────────────
  String get chooseRole => _t('chooseRole');
  String get chooseRoleSubtitle => _t('chooseRoleSubtitle');
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get passenger => _t('passenger');
  String get driver => _t('driver');
  String get passengerDesc => _t('passengerDesc');
  String get driverDesc => _t('driverDesc');

  // ── SPLASH ────────────────────────────────────────────────────────────────
  String get preparingJourney => _t('preparingJourney');

  // ── HOME ──────────────────────────────────────────────────────────────────
  String get home => _t('home');
  String get search => _t('search');
  String get myTrips => _t('myTrips');
  String get profile => _t('profile');
  String get whereToGo => _t('whereToGo');
  String get selectDestination => _t('selectDestination');
  String get availableRides => _t('availableRides');
  String get noRidesAvailable => _t('noRidesAvailable');

  // ── RIDE ─────────────────────────────────────────────────────────────────
  String get from => _t('from');
  String get to => _t('to');
  String get date => _t('date');
  String get time => _t('time');
  String get seats => _t('seats');
  String get price => _t('price');
  String get bookNow => _t('bookNow');
  String get cancelRide => _t('cancelRide');
  String get startRide => _t('startRide');
  String get endRide => _t('endRide');
  String get rideDetails => _t('rideDetails');
  String get passengers => _t('passengers');
  String get pickupPoint => _t('pickupPoint');
  String get dropoffPoint => _t('dropoffPoint');

  // ── DRIVER ────────────────────────────────────────────────────────────────
  String get createRide => _t('createRide');
  String get myRides => _t('myRides');
  String get vehicle => _t('vehicle');
  String get verification => _t('verification');
  String get verificationStatus => _t('verificationStatus');

  // ── SETTINGS ─────────────────────────────────────────────────────────────
  String get settings => _t('settings');
  String get account => _t('account');
  String get personalInfo => _t('personalInfo');
  String get passwordSecurity => _t('passwordSecurity');
  String get switchAccount => _t('switchAccount');
  String get preferences => _t('preferences');
  String get pushNotifications => _t('pushNotifications');
  String get location => _t('location');
  String get language => _t('language');
  String get darkMode => _t('darkMode');
  String get support => _t('support');
  String get helpCenter => _t('helpCenter');
  String get contactUs => _t('contactUs');
  String get termsPrivacy => _t('termsPrivacy');
  String get dangerZone => _t('dangerZone');
  String get deleteAccount => _t('deleteAccount');
  String get languageEnglish => _t('languageEnglish');
  String get languageArabic => _t('languageArabic');
  String get themeSystem => _t('themeSystem');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeSystemDesc => _t('themeSystemDesc');
  String get themeLightDesc => _t('themeLightDesc');
  String get themeDarkDesc => _t('themeDarkDesc');
  String get appearance => _t('appearance');
  String get selectLanguage => _t('selectLanguage');

  // ── PERMISSIONS ───────────────────────────────────────────────────────────
  String get enableNotifications => _t('enableNotifications');
  String get enableLocation => _t('enableLocation');
  String get notificationsReason => _t('notificationsReason');
  String get locationReason => _t('locationReason');

  // ── CHAT ─────────────────────────────────────────────────────────────────
  String get messages => _t('messages');
  String get typeMessage => _t('typeMessage');
  String get noMessages => _t('noMessages');

  // ── SAVED PLACES ──────────────────────────────────────────────────────────
  String get savedPlaces => _t('savedPlaces');
  String get addPlace => _t('addPlace');
  String get noSavedPlaces => _t('noSavedPlaces');

  // ══════════════════════════════════════════════════════════════════════════
  //  ENGLISH STRINGS
  // ══════════════════════════════════════════════════════════════════════════
  static const Map<String, String> _en = {
    'appName': 'Tale3',
    'save': 'Save',
    'cancel': 'Cancel',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    'confirm': 'Confirm',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'notNow': 'Not Now',
    'allow': 'Allow',

    'email': 'Email',
    'password': 'Password',
    'name': 'Full Name',
    'phone': 'Phone Number',
    'register': 'Register',
    'login': 'Login',
    'logout': 'Log Out',
    'forgotPassword': 'Forgot Password?',
    'continueWithGoogle': 'Continue with Google',
    'orContinueWith': 'Or continue with',
    'alreadyHaveAccount': 'Already have an account? Login',
    'noAccount': "Don't have an account? Register",

    'welcomeTagline': 'Find and share rides between cities in Jordan',
    'welcomeDesc':
        'Join thousands of commuters traveling safely between Amman, Irbid, Zarqa, and beyond.',
    'verifiedDrivers': 'Verified Drivers',
    'affordablePricing': 'Affordable Pricing',

    'chooseRole': 'Choose Your Role',
    'chooseRoleSubtitle': 'How would you like to use Tale3? Choose one to get started.',
    'loginTitle': 'Log in to your account',
    'loginSubtitle': 'Welcome back! How would you like to log in today?',
    'passenger': 'Passenger',
    'driver': 'Driver',
    'passengerDesc': 'Find & book rides between cities',
    'driverDesc': 'Offer rides & earn money driving',

    'preparingJourney': 'Preparing your journey...',

    'home': 'Home',
    'search': 'Search',
    'myTrips': 'My Trips',
    'profile': 'Profile',
    'whereToGo': 'Where to go?',
    'selectDestination': 'Select destination',
    'availableRides': 'Available Rides',
    'noRidesAvailable': 'No rides available',

    'from': 'From',
    'to': 'To',
    'date': 'Date',
    'time': 'Time',
    'seats': 'Seats',
    'price': 'Price',
    'bookNow': 'Book Now',
    'cancelRide': 'Cancel Ride',
    'startRide': 'Start Ride',
    'endRide': 'End Ride',
    'rideDetails': 'Ride Details',
    'passengers': 'Passengers',
    'pickupPoint': 'Pickup Point',
    'dropoffPoint': 'Drop-off Point',

    'createRide': 'Create Ride',
    'myRides': 'My Rides',
    'vehicle': 'Vehicle',
    'verification': 'Verification',
    'verificationStatus': 'Verification Status',

    'settings': 'Settings',
    'account': 'ACCOUNT',
    'personalInfo': 'Personal Information',
    'passwordSecurity': 'Password & Security',
    'switchAccount': 'Switch Account',
    'preferences': 'PREFERENCES',
    'pushNotifications': 'Push Notifications',
    'location': 'Location',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'support': 'SUPPORT',
    'helpCenter': 'Help Center',
    'contactUs': 'Contact Us',
    'termsPrivacy': 'Terms & Privacy Policy',
    'dangerZone': 'DANGER ZONE',
    'deleteAccount': 'Delete Account',
    'languageEnglish': 'English',
    'languageArabic': 'Arabic',
    'themeSystem': 'System',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'themeSystemDesc': 'Follow device settings',
    'themeLightDesc': 'Always light theme',
    'themeDarkDesc': 'Always dark theme',
    'appearance': 'Appearance',
    'selectLanguage': 'Select Language',

    'enableNotifications': 'Enable Notifications',
    'enableLocation': 'Enable Location',
    'notificationsReason':
        'Stay updated on your ride status, messages from drivers, and important alerts.',
    'locationReason':
        'Tale3 uses your location to find nearby rides and calculate accurate pickup points.',

    'messages': 'Messages',
    'typeMessage': 'Type a message...',
    'noMessages': 'No messages yet',

    'savedPlaces': 'Saved Places',
    'addPlace': 'Add Place',
    'noSavedPlaces': 'No saved places yet',
  };

  // ══════════════════════════════════════════════════════════════════════════
  //  ARABIC STRINGS
  // ══════════════════════════════════════════════════════════════════════════
  static const Map<String, String> _ar = {
    'appName': 'تعلي3',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'yes': 'نعم',
    'no': 'لا',
    'ok': 'موافق',
    'confirm': 'تأكيد',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'notNow': 'ليس الآن',
    'allow': 'السماح',

    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'name': 'الاسم الكامل',
    'phone': 'رقم الهاتف',
    'register': 'إنشاء حساب',
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'continueWithGoogle': 'المتابعة مع Google',
    'orContinueWith': 'أو المتابعة بـ',
    'alreadyHaveAccount': 'لديك حساب بالفعل؟ سجل الدخول',
    'noAccount': 'ليس لديك حساب؟ سجل الآن',

    'welcomeTagline': 'ابحث عن رحلات وشاركها بين المدن في الأردن',
    'welcomeDesc':
        'انضم إلى آلاف المسافرين الذين يتنقلون بأمان بين عمان وإربد والزرقاء وغيرها.',
    'verifiedDrivers': 'سائقون موثّقون',
    'affordablePricing': 'أسعار مناسبة',

    'chooseRole': 'اختر دورك',
    'chooseRoleSubtitle': 'كيف تريد استخدام تعلي3؟ اختر للبدء.',
    'loginTitle': 'سجّل الدخول لحسابك',
    'loginSubtitle': 'أهلاً بعودتك! كيف تريد تسجيل الدخول اليوم؟',
    'passenger': 'راكب',
    'driver': 'سائق',
    'passengerDesc': 'ابحث عن رحلات واحجزها بين المدن',
    'driverDesc': 'قدّم رحلات واكسب من قيادتك',

    'preparingJourney': 'جاري تجهيز رحلتك...',

    'home': 'الرئيسية',
    'search': 'بحث',
    'myTrips': 'رحلاتي',
    'profile': 'الملف الشخصي',
    'whereToGo': 'إلى أين؟',
    'selectDestination': 'اختر الوجهة',
    'availableRides': 'الرحلات المتاحة',
    'noRidesAvailable': 'لا توجد رحلات متاحة',

    'from': 'من',
    'to': 'إلى',
    'date': 'التاريخ',
    'time': 'الوقت',
    'seats': 'مقاعد',
    'price': 'السعر',
    'bookNow': 'احجز الآن',
    'cancelRide': 'إلغاء الرحلة',
    'startRide': 'بدء الرحلة',
    'endRide': 'إنهاء الرحلة',
    'rideDetails': 'تفاصيل الرحلة',
    'passengers': 'الركاب',
    'pickupPoint': 'نقطة الالتقاء',
    'dropoffPoint': 'نقطة الإنزال',

    'createRide': 'إنشاء رحلة',
    'myRides': 'رحلاتي',
    'vehicle': 'المركبة',
    'verification': 'التحقق',
    'verificationStatus': 'حالة التحقق',

    'settings': 'الإعدادات',
    'account': 'الحساب',
    'personalInfo': 'المعلومات الشخصية',
    'passwordSecurity': 'كلمة المرور والأمان',
    'switchAccount': 'تبديل الحساب',
    'preferences': 'التفضيلات',
    'pushNotifications': 'الإشعارات',
    'location': 'الموقع',
    'language': 'اللغة',
    'darkMode': 'الوضع الليلي',
    'support': 'الدعم',
    'helpCenter': 'مركز المساعدة',
    'contactUs': 'تواصل معنا',
    'termsPrivacy': 'الشروط وسياسة الخصوصية',
    'dangerZone': 'منطقة الخطر',
    'deleteAccount': 'حذف الحساب',
    'languageEnglish': 'الإنجليزية',
    'languageArabic': 'العربية',
    'themeSystem': 'تلقائي',
    'themeLight': 'فاتح',
    'themeDark': 'داكن',
    'themeSystemDesc': 'يتبع إعدادات الجهاز',
    'themeLightDesc': 'المظهر الفاتح دائماً',
    'themeDarkDesc': 'المظهر الداكن دائماً',
    'appearance': 'المظهر',
    'selectLanguage': 'اختر اللغة',

    'enableNotifications': 'تفعيل الإشعارات',
    'enableLocation': 'تفعيل الموقع',
    'notificationsReason':
        'ابقَ على اطلاع بحالة رحلتك والرسائل من السائقين والتنبيهات المهمة.',
    'locationReason':
        'يستخدم تعلي3 موقعك للعثور على الرحلات القريبة وحساب نقاط الالتقاء الدقيقة.',

    'messages': 'الرسائل',
    'typeMessage': 'اكتب رسالة...',
    'noMessages': 'لا توجد رسائل بعد',

    'savedPlaces': 'الأماكن المحفوظة',
    'addPlace': 'إضافة مكان',
    'noSavedPlaces': 'لا توجد أماكن محفوظة بعد',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Convenience extension — use context.l10n.someKey anywhere
// ─────────────────────────────────────────────────────────────────────────────
extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
