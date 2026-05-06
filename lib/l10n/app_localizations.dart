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
  // ── REGISTRATION ─────────────────────────────────────────────────────────
  String get passengerRegistration => _t('passengerRegistration');
  String get driverRegistration => _t('driverRegistration');
  String get accountDetails => _t('accountDetails');
  String get profileDetails => _t('profileDetails');
  String get step => _t('step');
  String get createYourAccount => _t('createYourAccount');
  String get tellUsAboutYourself => _t('tellUsAboutYourself');
  String get fillInDetails => _t('fillInDetails');
  String get fewMoreDetails => _t('fewMoreDetails');
  String get fillAllFields => _t('fillAllFields');
  String get enterValidEmail => _t('enterValidEmail');
  String get passwordMinLength => _t('passwordMinLength');
  String get acceptTerms => _t('acceptTerms');
  String get fullName => _t('fullName');
  String get fullNameHint => _t('fullNameHint');
  String get emailHint => _t('emailHint');
  String get passwordLabel => _t('passwordLabel');
  String get continueBtn => _t('continueBtn');
  String get phoneNumber => _t('phoneNumber');
  String get phoneHint => _t('phoneHint');
  String get gender => _t('gender');
  String get selectGender => _t('selectGender');
  String get genderMale => _t('genderMale');
  String get genderFemale => _t('genderFemale');
  String get genderPreferNotToSay => _t('genderPreferNotToSay');
  String get universityWorkplace => _t('universityWorkplace');
  String get optional => _t('optional');
  String get universityHint => _t('universityHint');
  String get termsAgreement => _t('termsAgreement');
  String get termsOfService => _t('termsOfService');
  String get and => _t('and');
  String get privacyPolicy => _t('privacyPolicy');
  String get joinAsPassenger => _t('joinAsPassenger');
  String get joinAsDriver => _t('joinAsDriver');
  String get alreadyHaveAccountQ => _t('alreadyHaveAccountQ');
  String get joinTale3AsDriver => _t('joinTale3AsDriver');
  String get driverJoinDesc => _t('driverJoinDesc');
  String get dateOfBirth => _t('dateOfBirth');
  String get selectDateOfBirth => _t('selectDateOfBirth');
  String get nationalId => _t('nationalId');
  String get nationalIdHint => _t('nationalIdHint');
  String get passwordMinHint => _t('passwordMinHint');
  String get confirmPassword => _t('confirmPassword');
  String get pleaseConfirmPassword => _t('pleaseConfirmPassword');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get selectGenderMsg => _t('selectGenderMsg');
  String get close => _t('close');
  String get phoneRequired => _t('phoneRequired');
  String get enterValidPhone => _t('enterValidPhone');
  // ── VERIFICATION ─────────────────────────────────────────────────────────
  String get verifyYourEmail => _t('verifyYourEmail');
  String get sentCodeToEmail => _t('sentCodeToEmail');
  String get sentCodeTo => _t('sentCodeTo');
  String get enterCodeBelow => _t('enterCodeBelow');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get codeResent => _t('codeResent');
  String get verificationCodeResent => _t('verificationCodeResent');
  String get resendCode => _t('resendCode');
  String get resendIn => _t('resendIn');
  String get verify => _t('verify');
  String get enterFullCode => _t('enterFullCode');
  String get verificationSuccessful => _t('verificationSuccessful');
  String get verificationSuccessDesc => _t('verificationSuccessDesc');
  // ── PROFILE ───────────────────────────────────────────────────────────────
  String get myProfile => _t('myProfile');
  String get editProfile => _t('editProfile');
  String get tapToChangePhoto => _t('tapToChangePhoto');
  String get yourFullName => _t('yourFullName');
  String get profileUpdated => _t('profileUpdated');
  String get yourName => _t('yourName');
  String get addPhoneNumber => _t('addPhoneNumber');
  String get passengerName => _t('passengerName');
  String get driverName => _t('driverName');
  String get quickLinks => _t('quickLinks');
  String get logOut => _t('logOut');
  String get logOutConfirm => _t('logOutConfirm');
  String get rating => _t('rating');
  String get trips => _t('trips');
  String get years => _t('years');
  String get takeAPhoto => _t('takeAPhoto');
  String get chooseFromGallery => _t('chooseFromGallery');

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
  String get noRidesFound => _t('noRidesFound');
  String get filterRides => _t('filterRides');
  String get priceRange => _t('priceRange');
  String get minSeats => _t('minSeats');
  String get apply => _t('apply');
  String get reset => _t('reset');
  String get sortPriceLow => _t('sortPriceLow');
  String get sortPriceHigh => _t('sortPriceHigh');
  String get sortByTime => _t('sortByTime');
  String get noActiveRide => _t('noActiveRide');
  String get anywhere => _t('anywhere');
  String get booked => _t('booked');
  String get noPassengersYet => _t('noPassengersYet');
  String get noUpcomingTrips => _t('noUpcomingTrips');
  String get noPastTrips => _t('noPastTrips');
  String get noCancelledTrips => _t('noCancelledTrips');
  String get upcoming => _t('upcoming');
  String get past => _t('past');
  String get canceled => _t('canceled');
  String get confirmed => _t('confirmed');
  String get cancelled => _t('cancelled');
  String get completed => _t('completed');
  String get activeNow => _t('activeNow');
  String get scheduled => _t('scheduled');

  // ── RIDE / CANCEL ──────────────────────────────────────────────────────────
  String get cancelTrip => _t('cancelTrip');
  String get cancelTripQuestion => _t('cancelTripQuestion');
  String get cancelTripDesc => _t('cancelTripDesc');
  String get reasonChangedMind => _t('reasonChangedMind');
  String get reasonFoundRide => _t('reasonFoundRide');
  String get reasonDriverLate => _t('reasonDriverLate');
  String get reasonOther => _t('reasonOther');
  String get confirmCancellation => _t('confirmCancellation');
  String get keepRide => _t('keepRide');

  // ── RIDE CONFIRMATION / CREATION ─────────────────────────────────────────
  String get reviewRide => _t('reviewRide');
  String get reviewRideDesc => _t('reviewRideDesc');
  String get notSpecified => _t('notSpecified');
  String get pricePerSeat => _t('pricePerSeat');
  String get featuresPreferences => _t('featuresPreferences');
  String get luggage => _t('luggage');
  String get noSmoking => _t('noSmoking');
  String get noFeaturesSelected => _t('noFeaturesSelected');
  String get additionalNotes => _t('additionalNotes');
  String get totalIfFullyBooked => _t('totalIfFullyBooked');
  String get edit => _t('edit');
  String get publishing => _t('publishing');
  String get confirmAndPublish => _t('confirmAndPublish');
  String get routeSettings => _t('routeSettings');
  String get originHint => _t('originHint');
  String get destinationHint => _t('destinationHint');
  String get availableSeats => _t('availableSeats');
  String get additionalNotesHint => _t('additionalNotesHint');
  String get publishRide => _t('publishRide');

  // ── RIDE POSTED ───────────────────────────────────────────────────────────
  String get ridePosted => _t('ridePosted');
  String get rideIsLive => _t('rideIsLive');
  String get matchingPassengers => _t('matchingPassengers');
  String get destination => _t('destination');
  String get shareTrip => _t('shareTrip');
  String get goToDashboard => _t('goToDashboard');

  // ── DRIVER RIDE DETAILS ───────────────────────────────────────────────────
  String get shareRide => _t('shareRide');
  String get copyRideDetails => _t('copyRideDetails');
  String get rideCopied => _t('rideCopied');
  String get dateAndTime => _t('dateAndTime');
  String get pickup => _t('pickup');
  String get dropOff => _t('dropOff');
  String get ridePreferences => _t('ridePreferences');
  String get finalDestination => _t('finalDestination');

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
  String get selectYourSeat => _t('selectYourSeat');
  String get available => _t('available');
  String get selectedLabel => _t('selectedLabel');
  String get occupied => _t('occupied');
  String get selectedSeats => _t('selectedSeats');
  String get totalPrice => _t('totalPrice');
  String get confirmSeatSelection => _t('confirmSeatSelection');
  String get bookingFailed => _t('bookingFailed');
  String get bookingStatus => _t('bookingStatus');
  String get bookingConfirmed => _t('bookingConfirmed');
  String get bookingConfirmedDesc => _t('bookingConfirmedDesc');
  String get tripDetails => _t('tripDetails');
  String get passwordReset => _t('passwordReset');
  String get forgotPasswordTitle => _t('forgotPasswordTitle');
  String get checkYourInbox => _t('checkYourInbox');
  String get passwordResetDesc => _t('passwordResetDesc');
  String get sendLink => _t('sendLink');
  String get backToLogin => _t('backToLogin');
  String get rememberPassword => _t('rememberPassword');
  String get logIn => _t('logIn');

  // ── COMMUNITY GUIDELINES ─────────────────────────────────────────────────
  String get beforeYouStart => _t('beforeYouStart');
  String get guidelinesIntro => _t('guidelinesIntro');
  String get sharedCommunity => _t('sharedCommunity');
  String get guidelineSharedCab => _t('guidelineSharedCab');
  String get travelSmarter => _t('travelSmarter');
  String get bePunctual => _t('bePunctual');
  String get trustAndCommunity => _t('trustAndCommunity');
  String get iUnderstandGetStarted => _t('iUnderstandGetStarted');

  // ── NOTES & RULES ────────────────────────────────────────────────────────
  String get notesAndRules => _t('notesAndRules');
  String get communityGuidelines => _t('communityGuidelines');
  String get guidelineSharedCarpool => _t('guidelineSharedCarpool');
  String get guidelineShareRides => _t('guidelineShareRides');
  String get guidelineArriveEarly => _t('guidelineArriveEarly');
  String get guidelineCarpooling => _t('guidelineCarpooling');
  String get seatsOrder => _t('seatsOrder');
  String get backRowSelection => _t('backRowSelection');
  String get backRowSelectionDesc => _t('backRowSelectionDesc');
  String get fullCarSelection => _t('fullCarSelection');
  String get fullCarSelectionDesc => _t('fullCarSelectionDesc');
  String get next => _t('next');

  // ── DRIVER PROFILE ───────────────────────────────────────────────────────
  String get myRide => _t('myRide');
  String get driverProfile => _t('driverProfile');
  String get goldDriver => _t('goldDriver');
  String get noVehicleAdded => _t('noVehicleAdded');
  String get active => _t('active');
  String get identityVerified => _t('identityVerified');
  String get backgroundCheck => _t('backgroundCheck');
  String get rides => _t('rides');
  String get verified => _t('verified');
  String get pending => _t('pending');

  // ── RATINGS & REVIEWS ────────────────────────────────────────────────────
  String get ratingsAndReviews => _t('ratingsAndReviews');
  String get passengerFeedback => _t('passengerFeedback');
  String get sortBy => _t('sortBy');
  String get newest => _t('newest');
  String get reviewsLabel => _t('reviewsLabel');

  // ── SAVED PLACES SCREEN ──────────────────────────────────────────────────
  String get savedPlacesEmptyDesc => _t('savedPlacesEmptyDesc');
  String get addNewPlace => _t('addNewPlace');
  String get placeType => _t('placeType');
  String get placeTypeHome => _t('placeTypeHome');
  String get placeTypeWork => _t('placeTypeWork');
  String get placeTypeFavourite => _t('placeTypeFavourite');
  String get placeTypeOther => _t('placeTypeOther');
  String get placeNameLabel => _t('placeNameLabel');
  String get addressLabel => _t('addressLabel');

  // ── DRIVER VERIFICATION STATUS ───────────────────────────────────────────
  String get identityVerification => _t('identityVerification');
  String get verificationDocsBeingReviewed => _t('verificationDocsBeingReviewed');
  String get statusActive => _t('statusActive');
  String get idVerification => _t('idVerification');
  String get vehicleInspection => _t('vehicleInspection');
  String get pendingReview => _t('pendingReview');
  String get statusRejected => _t('statusRejected');
  String get statusVerified => _t('statusVerified');
  String get notSubmitted => _t('notSubmitted');
  String get contactSupport => _t('contactSupport');

  // ── DRIVER PROFILE PHOTO ─────────────────────────────────────────────────
  String get profilePhoto => _t('profilePhoto');
  String get settingUpYourProfile => _t('settingUpYourProfile');
  String get addProfilePhoto => _t('addProfilePhoto');
  String get addProfilePhotoDesc => _t('addProfilePhotoDesc');
  String get takePhoto => _t('takePhoto');
  String get uploadFromGallery => _t('uploadFromGallery');
  String get skipForNow => _t('skipForNow');
  String get ofWord => _t('ofWord');

  // ── DRIVER ID VERIFICATION ───────────────────────────────────────────────
  String get uploadIdDesc => _t('uploadIdDesc');
  String get frontOfId => _t('frontOfId');
  String get uploadFrontSide => _t('uploadFrontSide');
  String get fileTypeHint => _t('fileTypeHint');
  String get backOfId => _t('backOfId');
  String get uploadBackSide => _t('uploadBackSide');
  String get photoRequirements => _t('photoRequirements');
  String get reqFourCorners => _t('reqFourCorners');
  String get reqClearText => _t('reqClearText');
  String get reqNoGlare => _t('reqNoGlare');
  String get submitForVerification => _t('submitForVerification');
  String get sslEncrypted => _t('sslEncrypted');
  String get uploadBothId => _t('uploadBothId');
  String get tapToChange => _t('tapToChange');

  // ── DRIVER VEHICLE DETAILS ───────────────────────────────────────────────
  String get vehicleDetails => _t('vehicleDetails');
  String get onboardingProgress => _t('onboardingProgress');
  String get tellUsAboutVehicle => _t('tellUsAboutVehicle');
  String get provideVehicleDetails => _t('provideVehicleDetails');
  String get carMake => _t('carMake');
  String get carMakeHint => _t('carMakeHint');
  String get carMakeRequired => _t('carMakeRequired');
  String get carModel => _t('carModel');
  String get carModelHint => _t('carModelHint');
  String get carModelRequired => _t('carModelRequired');
  String get year => _t('year');
  String get required => _t('required');
  String get invalidYear => _t('invalidYear');
  String get colorLabel => _t('colorLabel');
  String get colorHint => _t('colorHint');
  String get plateNumber => _t('plateNumber');
  String get plateHint => _t('plateHint');
  String get plateRequired => _t('plateRequired');
  String get nextStep => _t('nextStep');

  // ── DRIVER ────────────────────────────────────────────────────────────────
  String get createRide => _t('createRide');
  String get myRides => _t('myRides');
  String get createNewRide => _t('createNewRide');
  String get activeRide => _t('activeRide');
  String get earnings => _t('earnings');
  String get reviews => _t('reviews');
  String get myReviews => _t('myReviews');
  String get onTrack => _t('onTrack');
  String get details => _t('details');
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

  // ── AUTH SCREENS ──────────────────────────────────────────────────────────
  String get passengerLogin => _t('passengerLogin');
  String get driverLogin => _t('driverLogin');
  String get welcomeBack => _t('welcomeBack');
  String get welcomeCaptain => _t('welcomeCaptain');
  String get passengerLoginSubtitle => _t('passengerLoginSubtitle');
  String get driverLoginSubtitle => _t('driverLoginSubtitle');
  String get emailAddress => _t('emailAddress');
  String get enterYourPassword => _t('enterYourPassword');
  String get loginAsPassenger => _t('loginAsPassenger');
  String get loginAsDriver => _t('loginAsDriver');
  String get signInWithGoogle => _t('signInWithGoogle');
  String get newToTale3 => _t('newToTale3');
  String get registerNow => _t('registerNow');

  // ── HOME SCREEN ───────────────────────────────────────────────────────────
  String get goodMorning => _t('goodMorning');
  String get goodAfternoon => _t('goodAfternoon');
  String get goodEvening => _t('goodEvening');
  String get tripsTaken => _t('tripsTaken');
  String get myRating => _t('myRating');
  String get planYourTrip => _t('planYourTrip');
  String get chooseFromMap => _t('chooseFromMap');
  String get today => _t('today');
  String get onePassenger => _t('onePassenger');
  String get searchRides => _t('searchRides');
  String get recommendedForYou => _t('recommendedForYou');
  String get seeAll => _t('seeAll');
  String get quickDestinations => _t('quickDestinations');
  String get departure => _t('departure');
  String get chat => _t('chat');

  // ── SETTINGS SHEETS ───────────────────────────────────────────────────────
  String get noSavedAccounts => _t('noSavedAccounts');
  String get addNewAccount => _t('addNewAccount');
  String get saveChanges => _t('saveChanges');
  String get updatePassword => _t('updatePassword');
  String get sendUsMessage => _t('sendUsMessage');
  String get delete => _t('delete');
  String get currentPassword => _t('currentPassword');
  String get newPasswordLabel => _t('newPasswordLabel');
  String get confirmNewPassword => _t('confirmNewPassword');

  // ── RIDE SCREENS ──────────────────────────────────────────────────────────
  String get tapToSeeDetails => _t('tapToSeeDetails');
  String get seatsLeft => _t('seatsLeft');
  String get route => _t('route');
  String get estTime => _t('estTime');
  String get tripRulesFeatures => _t('tripRulesFeatures');
  String get verifiedDriver => _t('verifiedDriver');
  String get requestBooking => _t('requestBooking');
  String get book => _t('book');
  String get noSpecialRules => _t('noSpecialRules');
  String get selectSeat => _t('selectSeat');
  String get noSmokingAllowed => _t('noSmokingAllowed');
  String get luggageSpaceAvailable => _t('luggageSpaceAvailable');
  String get airConditioning => _t('airConditioning');
  String get petsAllowed => _t('petsAllowed');
  String get noPets => _t('noPets');

  // ── CHAT SCREENS ──────────────────────────────────────────────────────────
  String get searchConversations => _t('searchConversations');
  String get noConversations => _t('noConversations');

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
    'passengerRegistration': 'Passenger Registration',
    'driverRegistration': 'Driver Registration',
    'accountDetails': 'Account Details',
    'profileDetails': 'Profile Details',
    'step': 'Step',
    'createYourAccount': 'Create your account',
    'tellUsAboutYourself': 'Tell us about yourself',
    'fillInDetails': 'Fill in your details to join the Tale3 community.',
    'fewMoreDetails': 'Just a couple more details to personalise your experience.',
    'fillAllFields': 'Please fill in all fields to continue',
    'enterValidEmail': 'Please enter a valid email address',
    'passwordMinLength': 'Password must be at least 8 characters',
    'acceptTerms': 'Please accept the Terms of Service to continue',
    'fullName': 'Full Name',
    'fullNameHint': 'John Doe',
    'emailHint': 'name@example.com',
    'passwordLabel': 'Password',
    'continueBtn': 'Continue',
    'phoneNumber': 'Phone Number',
    'phoneHint': '+966 5X XXX XXXX',
    'gender': 'Gender',
    'selectGender': 'Select gender',
    'genderMale': 'Male',
    'genderFemale': 'Female',
    'genderPreferNotToSay': 'Prefer not to say',
    'universityWorkplace': 'University / Workplace',
    'optional': 'OPTIONAL',
    'universityHint': 'Where do you commute to?',
    'termsAgreement': "By joining, I agree to Tale3's ",
    'termsOfService': 'Terms of Service',
    'and': ' and ',
    'privacyPolicy': 'Privacy Policy',
    'joinAsPassenger': 'Join as Passenger',
    'joinAsDriver': 'Join as Driver',
    'alreadyHaveAccountQ': 'Already have an account?',
    'joinTale3AsDriver': 'Join Tale3 as a Driver',
    'driverJoinDesc': 'Start your journey with us and maximize your earnings today.',
    'dateOfBirth': 'Date of Birth',
    'selectDateOfBirth': 'Select your date of birth',
    'nationalId': 'National ID Number',
    'nationalIdHint': 'Enter ID number',
    'passwordMinHint': 'Min. 8 characters, one uppercase letter and one number',
    'confirmPassword': 'Confirm Password',
    'pleaseConfirmPassword': 'Please confirm your password',
    'passwordsDoNotMatch': 'Passwords do not match',
    'selectGenderMsg': 'Please select your gender',
    'close': 'Close',
    'phoneRequired': 'Phone number is required',
    'enterValidPhone': 'Enter a valid phone number',

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
    'noRidesFound': 'No rides found for your search',
    'filterRides': 'Filter Rides',
    'priceRange': 'Max Price',
    'minSeats': 'Min. Seats',
    'apply': 'Apply',
    'reset': 'Reset',
    'sortPriceLow': 'Price: Low → High',
    'sortPriceHigh': 'Price: High → Low',
    'sortByTime': 'Departure Time',
    'noActiveRide': 'No active ride',
    'anywhere': 'Anywhere',
    'booked': 'booked',
    'noPassengersYet': 'No passengers booked yet',
    'noUpcomingTrips': 'No upcoming trips.',
    'noPastTrips': 'No past trips yet.',
    'noCancelledTrips': 'No cancelled trips.',
    'upcoming': 'Upcoming',
    'past': 'Past',
    'canceled': 'CANCELED',
    'confirmed': 'CONFIRMED',
    'cancelled': 'CANCELLED',
    'completed': 'Completed',
    'activeNow': 'Active Now',
    'scheduled': 'Scheduled',

    'from': 'From',
    'to': 'To',
    'date': 'Date',
    'time': 'Time',
    'seats': 'Seats',
    'price': 'Price',
    'bookNow': 'Book Now',
    'cancelRide': 'Cancel Ride',
    'cancelTrip': 'Cancel Trip',
    'cancelTripQuestion': 'Cancel Trip?',
    'cancelTripDesc': 'Are you sure you want to cancel this trip?\nPlease select a reason:',
    'reasonChangedMind': 'Changed my mind',
    'reasonFoundRide': 'Found another ride',
    'reasonDriverLate': 'Driver is running late',
    'reasonOther': 'Other reason',
    'confirmCancellation': 'Confirm Cancellation',
    'keepRide': 'Keep Ride',
    'reviewRide': 'Review Ride',
    'reviewRideDesc': 'Please review your ride details\nbefore publishing.',
    'notSpecified': 'Not specified',
    'pricePerSeat': 'Price / Seat',
    'featuresPreferences': 'Features & Preferences',
    'luggage': 'Luggage',
    'noSmoking': 'No Smoking',
    'noFeaturesSelected': 'No features selected',
    'additionalNotes': 'Additional Notes',
    'totalIfFullyBooked': 'Total if fully booked',
    'edit': 'Edit',
    'publishing': 'Publishing...',
    'confirmAndPublish': 'Confirm & Publish',
    'routeSettings': 'Route settings',
    'originHint': 'Origin (e.g. Downtown Dubai)',
    'destinationHint': 'Destination (e.g. Dubai Marina)',
    'availableSeats': 'Available Seats',
    'additionalNotesHint': 'Add any specific details here...',
    'publishRide': 'Publish Ride',
    'ridePosted': 'Ride Posted',
    'rideIsLive': 'Your ride is live!',
    'matchingPassengers': 'Subscribers are being calculated and\nmatching you with passengers...',
    'destination': 'Destination',
    'shareTrip': 'Share Trip',
    'goToDashboard': 'Go to Dashboard',
    'shareRide': 'Share Ride',
    'copyRideDetails': 'Copy Ride Details',
    'rideCopied': 'Ride details copied to clipboard',
    'dateAndTime': 'DATE & TIME',
    'pickup': 'Pickup',
    'dropOff': 'Drop-off',
    'ridePreferences': 'RIDE PREFERENCES',
    'finalDestination': 'Final destination',
    'startRide': 'Start Ride',
    'endRide': 'End Ride',
    'rideDetails': 'Ride Details',
    'passengers': 'Passengers',
    'pickupPoint': 'Pickup Point',
    'dropoffPoint': 'Drop-off Point',
    'selectYourSeat': 'Select your seat',
    'available': 'Available',
    'selectedLabel': 'Selected',
    'occupied': 'Occupied',
    'selectedSeats': 'Selected Seat(s)',
    'totalPrice': 'Total Price',
    'confirmSeatSelection': 'Confirm Seat Selection',
    'bookingFailed': 'Booking failed. Seats may no longer be available.',
    'bookingStatus': 'Booking Status',
    'bookingConfirmed': 'Booking Confirmed!',
    'bookingConfirmedDesc': 'Your ride has been confirmed. You can\ntrack its status at My Trips.',
    'tripDetails': 'TRIP DETAILS',
    'passwordReset': 'Password Reset',
    'forgotPasswordTitle': 'Forgot Password?',
    'checkYourInbox': 'Check your inbox',
    'passwordResetDesc': 'Enter the email address associated\nwith your Tale3 account.',
    'sendLink': 'Send Link',
    'backToLogin': 'Back to Login',
    'rememberPassword': 'Remember your password?',
    'logIn': 'Log in',

    'beforeYouStart': 'Before you start',
    'guidelinesIntro': 'Please review how Tale3 works to ensure a great experience for everyone.',
    'sharedCommunity': 'Shared Community',
    'guidelineSharedCab': 'Tale3 is a shared carpool community — not a private cab. Ride together, not alone.',
    'travelSmarter': 'Travel Smarter',
    'bePunctual': 'Be Punctual',
    'trustAndCommunity': 'Trust & Community',
    'iUnderstandGetStarted': 'I Understand & Get Started',

    'notesAndRules': 'Notes & Rules',
    'communityGuidelines': 'Community Guidelines',
    'guidelineSharedCarpool': 'Tale3 is a shared carpool community — not a private car. Ride together, not alone.',
    'guidelineShareRides': 'Share rides, split costs, and travel smarter together.',
    'guidelineArriveEarly': 'Arrive a little early to keep things smooth. Showing up a few minutes before your driver arrives helps ensure a stress-free ride.',
    'guidelineCarpooling': 'Carpooling helps keep travel affordable while building a friendly, trust-based community.',
    'seatsOrder': 'Seats Order',
    'backRowSelection': 'Back Row Selection',
    'backRowSelectionDesc': 'Choose "Back Row" to reserve all three back seats for maximum comfort or luggage space.',
    'fullCarSelection': 'Full Car Selection',
    'fullCarSelectionDesc': 'Choose "All" to reserve all four seats and have the entire vehicle to yourself.',
    'next': 'Next',

    'ratingsAndReviews': 'Ratings & Reviews',
    'passengerFeedback': 'Passenger Feedback',
    'sortBy': 'Sort by',
    'newest': 'Newest',
    'reviewsLabel': 'reviews',

    'savedPlacesEmptyDesc': 'Save your home, work, or\nfrequent destinations here.',
    'addNewPlace': 'Add New Place',
    'placeType': 'Type',
    'placeTypeHome': 'Home',
    'placeTypeWork': 'Work',
    'placeTypeFavourite': 'Favourite',
    'placeTypeOther': 'Other',
    'placeNameLabel': 'Name (e.g. Home)',
    'addressLabel': 'Address',

    'identityVerification': 'Identity Verification',
    'verificationDocsBeingReviewed': 'Your documents are being reviewed.\nNotifications will be sent to your app\nand email.',
    'statusActive': 'Active',
    'idVerification': 'ID Verification',
    'vehicleInspection': 'Vehicle Inspection',
    'pendingReview': 'Pending Review',
    'statusRejected': 'Rejected',
    'statusVerified': 'Verified',
    'notSubmitted': 'Not Submitted',
    'contactSupport': 'Contact Support',

    'profilePhoto': 'Profile Photo',
    'settingUpYourProfile': 'SETTING UP YOUR PROFILE',
    'addProfilePhoto': 'Add a Profile Photo',
    'addProfilePhotoDesc': 'Add a clear photo of yourself to help\ndrivers identify you. This builds trust in\nthe community.',
    'takePhoto': 'Take Photo',
    'uploadFromGallery': 'Upload from Gallery',
    'skipForNow': 'Skip for now',
    'ofWord': 'of',

    'uploadIdDesc': 'Please upload a clear photo of your National\nID or Passport to verify your identity.',
    'frontOfId': 'FRONT OF ID',
    'uploadFrontSide': 'Upload front side',
    'fileTypeHint': 'JPG, PNG or PDF (max. 5MB)',
    'backOfId': 'BACK OF ID',
    'uploadBackSide': 'Upload back side',
    'photoRequirements': 'Requirements for photo:',
    'reqFourCorners': 'All four corners of the document are visible',
    'reqClearText': 'Text is clear and easy to read',
    'reqNoGlare': 'No glare or reflections from flash',
    'submitForVerification': 'Submit for Verification',
    'sslEncrypted': 'SECURE 256-BIT SSL ENCRYPTED VERIFICATION',
    'uploadBothId': 'Please upload both front and back of your ID to continue',
    'tapToChange': 'Tap to change',

    'vehicleDetails': 'Vehicle Details',
    'onboardingProgress': 'Onboarding Progress',
    'tellUsAboutVehicle': 'Tell us about your vehicle',
    'provideVehicleDetails': "Provide the details of the vehicle you'll be driving.",
    'carMake': 'Car Make',
    'carMakeHint': 'e.g. Toyota',
    'carMakeRequired': 'Car make is required',
    'carModel': 'Car Model',
    'carModelHint': 'e.g. Camry',
    'carModelRequired': 'Car model is required',
    'year': 'Year',
    'required': 'Required',
    'invalidYear': 'Invalid year',
    'colorLabel': 'Color',
    'colorHint': 'e.g. White',
    'plateNumber': 'Plate Number',
    'plateHint': 'ABC 1234',
    'plateRequired': 'Plate number is required',
    'nextStep': 'Next Step',

    'myRide': 'My Ride',
    'driverProfile': 'Driver Profile',
    'goldDriver': 'Gold Driver',
    'noVehicleAdded': 'No vehicle added',
    'active': 'ACTIVE',
    'identityVerified': 'Identity Verified',
    'backgroundCheck': 'Background Check',
    'rides': 'Rides',
    'verified': 'VERIFIED',
    'pending': 'PENDING',

    'createRide': 'Create Ride',
    'myRides': 'My Rides',
    'createNewRide': 'Create New Ride',
    'activeRide': 'Active Ride',
    'earnings': 'Earnings',
    'reviews': 'Reviews',
    'myReviews': 'My Reviews',
    'onTrack': 'On Track',
    'details': 'Details',
    'vehicle': 'Vehicle',
    'verification': 'Verification',
    'verificationStatus': 'Verification Status',
    'verifyYourEmail': 'Verify your Email',
    'sentCodeToEmail': "We've sent a 4-digit code to your email address. Please enter it below to continue.",
    'sentCodeTo': "We've sent a 4-digit code to\n",
    'enterCodeBelow': '. Please enter it below to continue.',
    'didntReceiveCode': "Didn't receive the code?",
    'codeResent': 'Code resent to your email.',
    'verificationCodeResent': 'Verification code resent',
    'resendCode': 'Resend Code',
    'resendIn': 'Resend in',
    'verify': 'Verify',
    'enterFullCode': 'Please enter the full 4-digit code.',
    'verificationSuccessful': 'Verification\nSuccessful!',
    'verificationSuccessDesc': 'Your email has been verified. You can now use Tale3 to find and request a ride.',

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

    'passengerLogin': 'Passenger Login',
    'driverLogin': 'Driver Login',
    'welcomeBack': 'Welcome Back',
    'welcomeCaptain': 'Welcome Captain',
    'passengerLoginSubtitle': 'Ready for your next trip? Log in to continue.',
    'driverLoginSubtitle': 'Ready to hit the road? Log in to continue.',
    'emailAddress': 'Email Address',
    'enterYourPassword': 'Enter your password',
    'loginAsPassenger': 'Login as Passenger',
    'loginAsDriver': 'Login as Driver',
    'signInWithGoogle': 'Sign in with Google',
    'newToTale3': 'New to Tale3?',
    'registerNow': 'Register Now!',

    'goodMorning': 'Morning',
    'goodAfternoon': 'Afternoon',
    'goodEvening': 'Evening',
    'tripsTaken': 'Trips Taken',
    'myRating': 'My Rating',
    'planYourTrip': 'Plan your trip',
    'chooseFromMap': 'Choose from map',
    'today': 'Today',
    'onePassenger': '1 passenger',
    'searchRides': 'Search Rides',
    'recommendedForYou': 'Recommended for you',
    'seeAll': 'See all',
    'quickDestinations': 'Quick Destinations',
    'departure': 'Departure',
    'chat': 'Chat',

    'noSavedAccounts': 'No saved accounts.',
    'addNewAccount': 'Add New Account',
    'saveChanges': 'Save Changes',
    'myProfile': 'My Profile',
    'editProfile': 'Edit Profile',
    'tapToChangePhoto': 'Tap to change photo',
    'yourFullName': 'Your full name',
    'profileUpdated': 'Profile updated',
    'yourName': 'Your Name',
    'addPhoneNumber': 'Add phone number',
    'passengerName': 'Passenger',
    'driverName': 'Driver',
    'quickLinks': 'Quick Links',
    'logOut': 'Log Out',
    'logOutConfirm': 'Are you sure you want to log out?',
    'rating': 'Rating',
    'trips': 'Trips',
    'years': 'Years',
    'takeAPhoto': 'Take a photo',
    'chooseFromGallery': 'Choose from gallery',
    'updatePassword': 'Update Password',
    'sendUsMessage': 'Send us a Message',
    'delete': 'Delete',
    'currentPassword': 'CURRENT PASSWORD',
    'newPasswordLabel': 'NEW PASSWORD',
    'confirmNewPassword': 'CONFIRM NEW PASSWORD',

    'tapToSeeDetails': 'Tap a ride to see details',
    'seatsLeft': 'SEATS LEFT',
    'route': 'ROUTE',
    'estTime': 'EST. TIME',
    'tripRulesFeatures': 'TRIP RULES & FEATURES',
    'verifiedDriver': 'VERIFIED DRIVER',
    'requestBooking': 'Request Booking',
    'book': 'Book',
    'noSpecialRules': 'No special rules.',
    'selectSeat': 'Select\nSeat',
    'noSmokingAllowed': 'No smoking allowed',
    'luggageSpaceAvailable': 'Luggage space available',
    'airConditioning': 'Air conditioning',
    'petsAllowed': 'Pets allowed',
    'noPets': 'No pets',

    'searchConversations': 'Search conversations…',
    'noConversations': 'No conversations yet.',
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
    'passengerRegistration': 'تسجيل الراكب',
    'driverRegistration': 'تسجيل السائق',
    'accountDetails': 'بيانات الحساب',
    'profileDetails': 'بيانات الملف الشخصي',
    'step': 'الخطوة',
    'createYourAccount': 'إنشاء حسابك',
    'tellUsAboutYourself': 'أخبرنا عن نفسك',
    'fillInDetails': 'أدخل بياناتك للانضمام إلى مجتمع Tale3.',
    'fewMoreDetails': 'بضعة تفاصيل إضافية لتخصيص تجربتك.',
    'fillAllFields': 'يرجى ملء جميع الحقول للمتابعة',
    'enterValidEmail': 'يرجى إدخال عنوان بريد إلكتروني صحيح',
    'passwordMinLength': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
    'acceptTerms': 'يرجى قبول شروط الخدمة للمتابعة',
    'fullName': 'الاسم الكامل',
    'fullNameHint': 'مثال: محمد أحمد',
    'emailHint': 'name@example.com',
    'passwordLabel': 'كلمة المرور',
    'continueBtn': 'متابعة',
    'phoneNumber': 'رقم الهاتف',
    'phoneHint': '+966 5X XXX XXXX',
    'gender': 'الجنس',
    'selectGender': 'اختر الجنس',
    'genderMale': 'ذكر',
    'genderFemale': 'أنثى',
    'genderPreferNotToSay': 'أفضل عدم الذكر',
    'universityWorkplace': 'الجامعة / جهة العمل',
    'optional': 'اختياري',
    'universityHint': 'إلى أين تتنقل يومياً؟',
    'termsAgreement': 'بالانضمام، أوافق على ',
    'termsOfService': 'شروط الخدمة',
    'and': ' و',
    'privacyPolicy': 'سياسة الخصوصية',
    'joinAsPassenger': 'انضم كراكب',
    'joinAsDriver': 'انضم كسائق',
    'alreadyHaveAccountQ': 'لديك حساب بالفعل؟',
    'joinTale3AsDriver': 'انضم إلى Tale3 كسائق',
    'driverJoinDesc': 'ابدأ رحلتك معنا وحقق أقصى استفادة من أرباحك اليوم.',
    'dateOfBirth': 'تاريخ الميلاد',
    'selectDateOfBirth': 'اختر تاريخ ميلادك',
    'nationalId': 'رقم الهوية الوطنية',
    'nationalIdHint': 'أدخل رقم الهوية',
    'passwordMinHint': '8 أحرف على الأقل، حرف كبير ورقم واحد',
    'confirmPassword': 'تأكيد كلمة المرور',
    'pleaseConfirmPassword': 'يرجى تأكيد كلمة المرور',
    'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
    'selectGenderMsg': 'يرجى اختيار الجنس',
    'close': 'إغلاق',
    'phoneRequired': 'رقم الهاتف مطلوب',
    'enterValidPhone': 'أدخل رقم هاتف صحيح',

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
    'noRidesFound': 'لا توجد رحلات تطابق بحثك',
    'filterRides': 'تصفية الرحلات',
    'priceRange': 'الحد الأقصى للسعر',
    'minSeats': 'الحد الأدنى للمقاعد',
    'apply': 'تطبيق',
    'reset': 'إعادة تعيين',
    'sortPriceLow': 'السعر: من الأقل للأعلى',
    'sortPriceHigh': 'السعر: من الأعلى للأقل',
    'sortByTime': 'وقت المغادرة',
    'noActiveRide': 'لا توجد رحلة نشطة',
    'anywhere': 'أي مكان',
    'booked': 'محجوز',
    'noPassengersYet': 'لا يوجد ركاب محجوزون بعد',
    'noUpcomingTrips': 'لا توجد رحلات قادمة.',
    'noPastTrips': 'لا توجد رحلات سابقة بعد.',
    'noCancelledTrips': 'لا توجد رحلات ملغاة.',
    'upcoming': 'القادمة',
    'past': 'السابقة',
    'canceled': 'ملغاة',
    'confirmed': 'مؤكدة',
    'cancelled': 'ملغاة',
    'completed': 'مكتملة',
    'activeNow': 'نشطة الآن',
    'scheduled': 'مجدولة',

    'from': 'من',
    'to': 'إلى',
    'date': 'التاريخ',
    'time': 'الوقت',
    'seats': 'مقاعد',
    'price': 'السعر',
    'bookNow': 'احجز الآن',
    'cancelRide': 'إلغاء الرحلة',
    'cancelTrip': 'إلغاء الرحلة',
    'cancelTripQuestion': 'إلغاء الرحلة؟',
    'cancelTripDesc': 'هل أنت متأكد أنك تريد إلغاء هذه الرحلة؟\nيرجى تحديد السبب:',
    'reasonChangedMind': 'غيّرت رأيي',
    'reasonFoundRide': 'وجدت رحلة أخرى',
    'reasonDriverLate': 'السائق متأخر',
    'reasonOther': 'سبب آخر',
    'confirmCancellation': 'تأكيد الإلغاء',
    'keepRide': 'إبقاء الرحلة',
    'reviewRide': 'مراجعة الرحلة',
    'reviewRideDesc': 'يرجى مراجعة تفاصيل رحلتك\nقبل النشر.',
    'notSpecified': 'غير محدد',
    'pricePerSeat': 'السعر / مقعد',
    'featuresPreferences': 'الميزات والتفضيلات',
    'luggage': 'الأمتعة',
    'noSmoking': 'ممنوع التدخين',
    'noFeaturesSelected': 'لم يتم تحديد ميزات',
    'additionalNotes': 'ملاحظات إضافية',
    'totalIfFullyBooked': 'الإجمالي إذا امتلأت المقاعد',
    'edit': 'تعديل',
    'publishing': 'جارٍ النشر...',
    'confirmAndPublish': 'تأكيد ونشر',
    'routeSettings': 'إعدادات المسار',
    'originHint': 'نقطة الانطلاق (مثال: وسط دبي)',
    'destinationHint': 'الوجهة (مثال: مرسى دبي)',
    'availableSeats': 'المقاعد المتاحة',
    'additionalNotesHint': 'أضف أي تفاصيل محددة هنا...',
    'publishRide': 'نشر الرحلة',
    'ridePosted': 'تم نشر الرحلة',
    'rideIsLive': 'رحلتك منشورة الآن!',
    'matchingPassengers': 'جارٍ حساب المشتركين ومطابقتك مع الركاب...',
    'destination': 'الوجهة',
    'shareTrip': 'مشاركة الرحلة',
    'goToDashboard': 'الذهاب إلى لوحة التحكم',
    'shareRide': 'مشاركة الرحلة',
    'copyRideDetails': 'نسخ تفاصيل الرحلة',
    'rideCopied': 'تم نسخ تفاصيل الرحلة إلى الحافظة',
    'dateAndTime': 'التاريخ والوقت',
    'pickup': 'نقطة الانطلاق',
    'dropOff': 'نقطة النزول',
    'ridePreferences': 'تفضيلات الرحلة',
    'finalDestination': 'الوجهة النهائية',
    'startRide': 'بدء الرحلة',
    'endRide': 'إنهاء الرحلة',
    'rideDetails': 'تفاصيل الرحلة',
    'passengers': 'الركاب',
    'pickupPoint': 'نقطة الالتقاء',
    'dropoffPoint': 'نقطة الإنزال',
    'selectYourSeat': 'اختر مقعدك',
    'available': 'متاح',
    'selectedLabel': 'محدد',
    'occupied': 'محجوز',
    'selectedSeats': 'المقعد(المقاعد) المختارة',
    'totalPrice': 'السعر الإجمالي',
    'confirmSeatSelection': 'تأكيد اختيار المقعد',
    'bookingFailed': 'فشل الحجز. قد لا تكون المقاعد متاحة بعد الآن.',
    'bookingStatus': 'حالة الحجز',
    'bookingConfirmed': 'تم تأكيد الحجز!',
    'bookingConfirmedDesc': 'تم تأكيد رحلتك. يمكنك\nمتابعة حالتها في رحلاتي.',
    'tripDetails': 'تفاصيل الرحلة',
    'passwordReset': 'إعادة تعيين كلمة المرور',
    'forgotPasswordTitle': 'نسيت كلمة المرور؟',
    'checkYourInbox': 'تحقق من بريدك الوارد',
    'passwordResetDesc': 'أدخل عنوان البريد الإلكتروني\nالمرتبط بحساب Tale3.',
    'sendLink': 'إرسال الرابط',
    'backToLogin': 'العودة لتسجيل الدخول',
    'rememberPassword': 'تتذكر كلمة المرور؟',
    'logIn': 'تسجيل الدخول',

    'beforeYouStart': 'قبل أن تبدأ',
    'guidelinesIntro': 'يرجى مراجعة كيفية عمل تعلي3 لضمان تجربة رائعة للجميع.',
    'sharedCommunity': 'مجتمع مشترك',
    'guidelineSharedCab': 'تعلي3 مجتمع مشاركة السيارات — وليس تاكسي خاصاً. اركب معاً وليس بمفردك.',
    'travelSmarter': 'سافر بذكاء',
    'bePunctual': 'كن منضبطاً بالوقت',
    'trustAndCommunity': 'الثقة والمجتمع',
    'iUnderstandGetStarted': 'فهمت، لنبدأ',

    'notesAndRules': 'ملاحظات وقواعد',
    'communityGuidelines': 'إرشادات المجتمع',
    'guidelineSharedCarpool': 'تعلي3 مجتمع مشاركة السيارات — وليس سيارة خاصة. اركب معاً وليس بمفردك.',
    'guidelineShareRides': 'شارك الرحلات، وقسّم التكاليف، وسافر بشكل أذكى معاً.',
    'guidelineArriveEarly': 'احرص على الوصول مبكراً قليلاً لضمان سير الأمور بسلاسة. الحضور قبل وصول السائق بدقائق يساعد في ضمان رحلة خالية من التوتر.',
    'guidelineCarpooling': 'المشاركة في الرحلات تساعد في الحفاظ على أسعار تنقل معقولة مع بناء مجتمع ودي وموثوق.',
    'seatsOrder': 'ترتيب المقاعد',
    'backRowSelection': 'اختيار المقعدين الخلفيين',
    'backRowSelectionDesc': 'اختر "الصف الخلفي" لحجز المقاعد الثلاثة الخلفية لأقصى قدر من الراحة أو مساحة الأمتعة.',
    'fullCarSelection': 'اختيار السيارة بالكامل',
    'fullCarSelectionDesc': 'اختر "الكل" لحجز جميع المقاعد الأربعة وامتلاك المركبة بالكامل لنفسك.',
    'next': 'التالي',

    'ratingsAndReviews': 'التقييمات والمراجعات',
    'passengerFeedback': 'تعليقات الركاب',
    'sortBy': 'ترتيب حسب',
    'newest': 'الأحدث',
    'reviewsLabel': 'تقييم',

    'savedPlacesEmptyDesc': 'احفظ منزلك أو عملك أو\nوجهاتك المتكررة هنا.',
    'addNewPlace': 'إضافة مكان جديد',
    'placeType': 'النوع',
    'placeTypeHome': 'منزل',
    'placeTypeWork': 'عمل',
    'placeTypeFavourite': 'مفضلة',
    'placeTypeOther': 'أخرى',
    'placeNameLabel': 'الاسم (مثال: المنزل)',
    'addressLabel': 'العنوان',

    'identityVerification': 'التحقق من الهوية',
    'verificationDocsBeingReviewed': 'جارٍ مراجعة وثائقك.\nسيتم إرسال الإشعارات إلى تطبيقك\nوبريدك الإلكتروني.',
    'statusActive': 'نشط',
    'idVerification': 'التحقق من الهوية',
    'vehicleInspection': 'فحص المركبة',
    'pendingReview': 'قيد المراجعة',
    'statusRejected': 'مرفوض',
    'statusVerified': 'موثّق',
    'notSubmitted': 'لم يتم الإرسال',
    'contactSupport': 'تواصل مع الدعم',

    'profilePhoto': 'صورة الملف الشخصي',
    'settingUpYourProfile': 'إعداد ملفك الشخصي',
    'addProfilePhoto': 'أضف صورة للملف الشخصي',
    'addProfilePhotoDesc': 'أضف صورة واضحة لنفسك لمساعدة\nالسائقين على التعرف عليك. هذا يبني الثقة في\nالمجتمع.',
    'takePhoto': 'التقط صورة',
    'uploadFromGallery': 'رفع من المعرض',
    'skipForNow': 'تخطي الآن',
    'ofWord': 'من',

    'uploadIdDesc': 'يرجى رفع صورة واضحة لبطاقة هويتك الوطنية\nأو جواز سفرك للتحقق من هويتك.',
    'frontOfId': 'الوجه الأمامي للهوية',
    'uploadFrontSide': 'رفع الوجه الأمامي',
    'fileTypeHint': 'JPG أو PNG أو PDF (الحد الأقصى 5 ميجابايت)',
    'backOfId': 'الوجه الخلفي للهوية',
    'uploadBackSide': 'رفع الوجه الخلفي',
    'photoRequirements': 'متطلبات الصورة:',
    'reqFourCorners': 'جميع الزوايا الأربع للوثيقة مرئية',
    'reqClearText': 'النص واضح وسهل القراءة',
    'reqNoGlare': 'لا يوجد وهج أو انعكاسات من الفلاش',
    'submitForVerification': 'تقديم للتحقق',
    'sslEncrypted': 'تحقق مشفر بـ SSL 256 بت آمن',
    'uploadBothId': 'يرجى رفع الوجهين الأمامي والخلفي لهويتك للمتابعة',
    'tapToChange': 'انقر للتغيير',

    'vehicleDetails': 'تفاصيل المركبة',
    'onboardingProgress': 'تقدم التسجيل',
    'tellUsAboutVehicle': 'أخبرنا عن مركبتك',
    'provideVehicleDetails': 'أدخل تفاصيل المركبة التي ستقودها.',
    'carMake': 'ماركة السيارة',
    'carMakeHint': 'مثال: تويوتا',
    'carMakeRequired': 'ماركة السيارة مطلوبة',
    'carModel': 'موديل السيارة',
    'carModelHint': 'مثال: كامري',
    'carModelRequired': 'موديل السيارة مطلوب',
    'year': 'السنة',
    'required': 'مطلوب',
    'invalidYear': 'سنة غير صحيحة',
    'colorLabel': 'اللون',
    'colorHint': 'مثال: أبيض',
    'plateNumber': 'رقم اللوحة',
    'plateHint': 'أ ب ج 1234',
    'plateRequired': 'رقم اللوحة مطلوب',
    'nextStep': 'الخطوة التالية',

    'myRide': 'رحلتي',
    'driverProfile': 'ملف السائق',
    'goldDriver': 'سائق ذهبي',
    'noVehicleAdded': 'لم تتم إضافة مركبة',
    'active': 'نشط',
    'identityVerified': 'تم التحقق من الهوية',
    'backgroundCheck': 'فحص الخلفية',
    'rides': 'رحلات',
    'verified': 'موثّق',
    'pending': 'قيد الانتظار',

    'createRide': 'إنشاء رحلة',
    'myRides': 'رحلاتي',
    'createNewRide': 'إنشاء رحلة جديدة',
    'activeRide': 'الرحلة الحالية',
    'earnings': 'الأرباح',
    'reviews': 'التقييمات',
    'myReviews': 'تقييماتي',
    'onTrack': 'في الوقت المحدد',
    'details': 'التفاصيل',
    'vehicle': 'المركبة',
    'verification': 'التحقق',
    'verificationStatus': 'حالة التحقق',
    'verifyYourEmail': 'تحقق من بريدك الإلكتروني',
    'sentCodeToEmail': 'لقد أرسلنا رمزاً مكوناً من 4 أرقام إلى بريدك الإلكتروني. يرجى إدخاله أدناه للمتابعة.',
    'sentCodeTo': 'لقد أرسلنا رمزاً مكوناً من 4 أرقام إلى\n',
    'enterCodeBelow': '. يرجى إدخاله أدناه للمتابعة.',
    'didntReceiveCode': 'لم تستلم الرمز؟',
    'codeResent': 'تم إعادة إرسال الرمز إلى بريدك الإلكتروني.',
    'verificationCodeResent': 'تم إعادة إرسال رمز التحقق',
    'resendCode': 'إعادة إرسال الرمز',
    'resendIn': 'إعادة الإرسال خلال',
    'verify': 'تحقق',
    'enterFullCode': 'يرجى إدخال الرمز المكون من 4 أرقام كاملاً.',
    'verificationSuccessful': 'تم التحقق\nبنجاح!',
    'verificationSuccessDesc': 'تم التحقق من بريدك الإلكتروني. يمكنك الآن استخدام Tale3 للعثور على رحلة وطلبها.',

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

    'passengerLogin': 'تسجيل دخول الراكب',
    'driverLogin': 'تسجيل دخول السائق',
    'welcomeBack': 'مرحباً بعودتك',
    'welcomeCaptain': 'مرحباً يا قائد',
    'passengerLoginSubtitle': 'هل أنت مستعد لرحلتك القادمة؟ سجل الدخول للمتابعة.',
    'driverLoginSubtitle': 'هل أنت مستعد للانطلاق؟ سجل الدخول للمتابعة.',
    'emailAddress': 'عنوان البريد الإلكتروني',
    'enterYourPassword': 'أدخل كلمة المرور',
    'loginAsPassenger': 'تسجيل الدخول كراكب',
    'loginAsDriver': 'تسجيل الدخول كسائق',
    'signInWithGoogle': 'تسجيل الدخول بـ Google',
    'newToTale3': 'جديد على تعلي3؟',
    'registerNow': 'سجل الآن!',

    'goodMorning': 'الصباح',
    'goodAfternoon': 'الظهيرة',
    'goodEvening': 'المساء',
    'tripsTaken': 'رحلات منجزة',
    'myRating': 'تقييمي',
    'planYourTrip': 'خطط لرحلتك',
    'chooseFromMap': 'اختر من الخريطة',
    'today': 'اليوم',
    'onePassenger': 'راكب واحد',
    'searchRides': 'البحث عن رحلات',
    'recommendedForYou': 'موصى به لك',
    'seeAll': 'عرض الكل',
    'quickDestinations': 'وجهات سريعة',
    'departure': 'المغادرة',
    'chat': 'المحادثات',

    'noSavedAccounts': 'لا توجد حسابات محفوظة.',
    'addNewAccount': 'إضافة حساب جديد',
    'saveChanges': 'حفظ التغييرات',
    'myProfile': 'ملفي الشخصي',
    'editProfile': 'تعديل الملف الشخصي',
    'tapToChangePhoto': 'انقر لتغيير الصورة',
    'yourFullName': 'اسمك الكامل',
    'profileUpdated': 'تم تحديث الملف الشخصي',
    'yourName': 'اسمك',
    'addPhoneNumber': 'أضف رقم الهاتف',
    'passengerName': 'الراكب',
    'driverName': 'السائق',
    'quickLinks': 'روابط سريعة',
    'logOut': 'تسجيل الخروج',
    'logOutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    'rating': 'التقييم',
    'trips': 'الرحلات',
    'years': 'سنوات',
    'takeAPhoto': 'التقط صورة',
    'chooseFromGallery': 'اختر من المعرض',
    'updatePassword': 'تحديث كلمة المرور',
    'sendUsMessage': 'أرسل لنا رسالة',
    'delete': 'حذف',
    'currentPassword': 'كلمة المرور الحالية',
    'newPasswordLabel': 'كلمة المرور الجديدة',
    'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',

    'tapToSeeDetails': 'انقر على رحلة لرؤية التفاصيل',
    'seatsLeft': 'مقاعد متبقية',
    'route': 'المسار',
    'estTime': 'الوقت التقديري',
    'tripRulesFeatures': 'قواعد الرحلة والميزات',
    'verifiedDriver': 'سائق موثّق',
    'requestBooking': 'طلب حجز',
    'book': 'احجز',
    'noSpecialRules': 'لا توجد قواعد خاصة.',
    'selectSeat': 'اختر\nمقعداً',
    'noSmokingAllowed': 'ممنوع التدخين',
    'luggageSpaceAvailable': 'مساحة للأمتعة متاحة',
    'airConditioning': 'تكييف هواء',
    'petsAllowed': 'الحيوانات الأليفة مسموحة',
    'noPets': 'ممنوع الحيوانات الأليفة',

    'searchConversations': 'البحث في المحادثات...',
    'noConversations': 'لا توجد محادثات بعد.',
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
