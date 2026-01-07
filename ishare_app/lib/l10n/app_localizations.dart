import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @whereToNext.
  ///
  /// In en, this message translates to:
  /// **'Where to next?'**
  String get whereToNext;

  /// No description provided for @searchRides.
  ///
  /// In en, this message translates to:
  /// **'Search Rides'**
  String get searchRides;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @enterDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter destination...'**
  String get enterDestination;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @findRide.
  ///
  /// In en, this message translates to:
  /// **'Find Ride'**
  String get findRide;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @offerRide.
  ///
  /// In en, this message translates to:
  /// **'Offer Ride'**
  String get offerRide;

  /// No description provided for @earnMoney.
  ///
  /// In en, this message translates to:
  /// **'Earn Money'**
  String get earnMoney;

  /// No description provided for @safetyCenter.
  ///
  /// In en, this message translates to:
  /// **'Safety Center'**
  String get safetyCenter;

  /// No description provided for @guidelines.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelines;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About iShare'**
  String get aboutUs;

  /// No description provided for @ourStory.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get ourStory;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @whyIshare.
  ///
  /// In en, this message translates to:
  /// **'Why iShare?'**
  String get whyIshare;

  /// No description provided for @saveCosts.
  ///
  /// In en, this message translates to:
  /// **'Save Costs'**
  String get saveCosts;

  /// No description provided for @saveCostsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share fuel costs and save on every trip.'**
  String get saveCostsDesc;

  /// No description provided for @ecoFriendly.
  ///
  /// In en, this message translates to:
  /// **'Eco-Friendly'**
  String get ecoFriendly;

  /// No description provided for @ecoFriendlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce your carbon footprint by sharing rides.'**
  String get ecoFriendlyDesc;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @communityDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with great people in your area.'**
  String get communityDesc;

  /// No description provided for @seatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsLeft(int count);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @pickUp.
  ///
  /// In en, this message translates to:
  /// **'Pick-up'**
  String get pickUp;

  /// No description provided for @dropOff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropOff;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @verifyAccountMsg.
  ///
  /// In en, this message translates to:
  /// **'Please verify your account before making payment.'**
  String get verifyAccountMsg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @paymentInitiated.
  ///
  /// In en, this message translates to:
  /// **'Payment Initiated'**
  String get paymentInitiated;

  /// No description provided for @checkPhoneMsg.
  ///
  /// In en, this message translates to:
  /// **'Please check your phone for payment confirmation.'**
  String get checkPhoneMsg;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account Verified'**
  String get accountVerified;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Account Not Verified'**
  String get accountNotVerified;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// No description provided for @cardPaymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Card payment integration coming soon. Please use Mobile Money for now.'**
  String get cardPaymentComingSoon;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @bankTransferDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer details will be sent to your email.'**
  String get bankTransferDetails;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @paymentPromptMsg.
  ///
  /// In en, this message translates to:
  /// **'You will receive a payment prompt on this number'**
  String get paymentPromptMsg;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @verifyToPay.
  ///
  /// In en, this message translates to:
  /// **'Verify Account to Pay'**
  String get verifyToPay;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @verifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get verifyIdentityTitle;

  /// No description provided for @verifyIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need to verify your identity before you can post a trip'**
  String get verifyIdentitySubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get nationalIdLabel;

  /// No description provided for @idHelperText.
  ///
  /// In en, this message translates to:
  /// **'16 digits'**
  String get idHelperText;

  /// No description provided for @paymentMethodsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted: MTN Mobile Money, Airtel Money'**
  String get paymentMethodsAccepted;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeTo;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @confirmAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Continue'**
  String get confirmAndContinue;

  /// No description provided for @secureInfoMsg.
  ///
  /// In en, this message translates to:
  /// **'Your information is encrypted and secure'**
  String get secureInfoMsg;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterTwoNames.
  ///
  /// In en, this message translates to:
  /// **'Enter at least two names'**
  String get enterTwoNames;

  /// No description provided for @invalidNameChars.
  ///
  /// In en, this message translates to:
  /// **'Names must contain only letters'**
  String get invalidNameChars;

  /// No description provided for @enterNationalId.
  ///
  /// In en, this message translates to:
  /// **'Enter your national ID'**
  String get enterNationalId;

  /// No description provided for @invalidIdLength.
  ///
  /// In en, this message translates to:
  /// **'National ID must be 16 digits'**
  String get invalidIdLength;

  /// No description provided for @invalidIdChars.
  ///
  /// In en, this message translates to:
  /// **'ID must contain only digits'**
  String get invalidIdChars;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Rwandan phone number'**
  String get invalidPhone;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept terms before continuing'**
  String get acceptTerms;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful!'**
  String get verificationSuccess;

  /// No description provided for @verificationSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified. You can now start your trip.'**
  String get verificationSuccessMsg;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @startingPoint.
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @vehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photo'**
  String get vehiclePhoto;

  /// No description provided for @uploadCarPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload photo'**
  String get uploadCarPhoto;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @planRoute.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Route'**
  String get planRoute;

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// No description provided for @tripInfo.
  ///
  /// In en, this message translates to:
  /// **'Trip Information'**
  String get tripInfo;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @planRouteDesc.
  ///
  /// In en, this message translates to:
  /// **'Where are you starting and where are you going?'**
  String get planRouteDesc;

  /// No description provided for @vehicleDetailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell passengers about your vehicle.'**
  String get vehicleDetailsDesc;

  /// No description provided for @tripInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your schedule and pricing.'**
  String get tripInfoDesc;

  /// No description provided for @summaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Review everything before publishing.'**
  String get summaryDesc;

  /// No description provided for @publishRide.
  ///
  /// In en, this message translates to:
  /// **'Publish Ride'**
  String get publishRide;

  /// No description provided for @fillFormHelp.
  ///
  /// In en, this message translates to:
  /// **'Fill out the form to publish a trip.'**
  String get fillFormHelp;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @searchComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search feature coming soon!'**
  String get searchComingSoon;

  /// No description provided for @searchFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be able to search for trips by location, date, and price here.'**
  String get searchFeatureDesc;

  /// No description provided for @emergencySOS.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySOS;

  /// No description provided for @sosActive.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert Active'**
  String get sosActive;

  /// No description provided for @pressAndHold.
  ///
  /// In en, this message translates to:
  /// **'Press and hold for 3 seconds'**
  String get pressAndHold;

  /// No description provided for @sosActivated.
  ///
  /// In en, this message translates to:
  /// **'SOS Activated'**
  String get sosActivated;

  /// No description provided for @emergencyAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent to:'**
  String get emergencyAlertSent;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @ishareSupport.
  ///
  /// In en, this message translates to:
  /// **'iShare Support Team'**
  String get ishareSupport;

  /// No description provided for @currentTripDriver.
  ///
  /// In en, this message translates to:
  /// **'Your driver/passenger for current trip'**
  String get currentTripDriver;

  /// No description provided for @liveLocationShared.
  ///
  /// In en, this message translates to:
  /// **'Your live location is being shared.'**
  String get liveLocationShared;

  /// No description provided for @call112.
  ///
  /// In en, this message translates to:
  /// **'Call 112'**
  String get call112;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocation;

  /// No description provided for @shareLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Your current location will be shared with your selected contacts via SMS.'**
  String get shareLocationDesc;

  /// No description provided for @locationSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location shared successfully!'**
  String get locationSharedSuccess;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @cancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTrip;

  /// No description provided for @tripCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Trip cancellation request'**
  String get tripCancelRequest;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Rwanda National Police'**
  String get police;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @fireBrigade.
  ///
  /// In en, this message translates to:
  /// **'Fire Brigade'**
  String get fireBrigade;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety Tips'**
  String get safetyTips;

  /// No description provided for @verifyDriver.
  ///
  /// In en, this message translates to:
  /// **'Verify Driver Details'**
  String get verifyDriver;

  /// No description provided for @verifyDriverDesc.
  ///
  /// In en, this message translates to:
  /// **'Always verify the driver\'s name, photo, and vehicle details before getting in.'**
  String get verifyDriverDesc;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share Trip Details'**
  String get shareTrip;

  /// No description provided for @shareTripDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your trip details with friends or family before you leave.'**
  String get shareTripDesc;

  /// No description provided for @stayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get stayConnected;

  /// No description provided for @stayConnectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone charged and accessible during the trip.'**
  String get stayConnectedDesc;

  /// No description provided for @checkRatings.
  ///
  /// In en, this message translates to:
  /// **'Check Ratings'**
  String get checkRatings;

  /// No description provided for @checkRatingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Check ratings and reviews from other passengers about the driver.'**
  String get checkRatingsDesc;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report Issues'**
  String get reportIssues;

  /// No description provided for @reportIssuesDesc.
  ///
  /// In en, this message translates to:
  /// **'Report any suspicious behavior or safety concerns immediately.'**
  String get reportIssuesDesc;

  /// No description provided for @safetyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Safety Matters'**
  String get safetyMatters;

  /// No description provided for @safetyCommitment.
  ///
  /// In en, this message translates to:
  /// **'iShare is committed to providing a safe and secure ride-sharing experience. All drivers are verified.'**
  String get safetyCommitment;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @aboutIShare.
  ///
  /// In en, this message translates to:
  /// **'About iShare'**
  String get aboutIShare;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'iShare'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Share the Ride, Share the Cost'**
  String get appTagline;

  /// No description provided for @appDescriptionShort.
  ///
  /// In en, this message translates to:
  /// **'Smart ride-sharing and cost-sharing platform'**
  String get appDescriptionShort;

  /// No description provided for @visionTitle.
  ///
  /// In en, this message translates to:
  /// **'🎯 Vision'**
  String get visionTitle;

  /// No description provided for @visionText.
  ///
  /// In en, this message translates to:
  /// **'Revolutionizing transportation in Rwanda and East Africa by creating a reliable, eco-friendly, and affordable ride-sharing network.'**
  String get visionText;

  /// No description provided for @missionTitle.
  ///
  /// In en, this message translates to:
  /// **'🚀 Mission'**
  String get missionTitle;

  /// No description provided for @missionText.
  ///
  /// In en, this message translates to:
  /// **'Connecting car owners with empty seats to passengers going the same direction, reducing transport costs, road congestion, and carbon emissions.'**
  String get missionText;

  /// No description provided for @problemTitle.
  ///
  /// In en, this message translates to:
  /// **'❓ The Problem'**
  String get problemTitle;

  /// No description provided for @problemText.
  ///
  /// In en, this message translates to:
  /// **'Fuel prices are rising, road congestion is increasing, and public transport can be inconvenient. Many private cars travel with 3-4 empty seats.'**
  String get problemText;

  /// No description provided for @solutionTitle.
  ///
  /// In en, this message translates to:
  /// **'✅ Our Solution'**
  String get solutionTitle;

  /// No description provided for @solutionText.
  ///
  /// In en, this message translates to:
  /// **'iShare connects drivers and passengers. Drivers earn money to offset fuel costs, and passengers travel comfortably at a lower price.'**
  String get solutionText;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'📱 How It Works'**
  String get howItWorks;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Driver Posts Trip'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'A driver going to a destination lists their trip details (time, seats, price).'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Passenger Books'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Passengers search for trips and book a seat instantly.'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Travel Together'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'They meet at the pickup point and enjoy the journey.'**
  String get step3Desc;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Rate & Pay'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'Payment is processed and both parties rate each other.'**
  String get step4Desc;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'⚡ Key Features'**
  String get keyFeatures;

  /// No description provided for @feat1Title.
  ///
  /// In en, this message translates to:
  /// **'Verified Users'**
  String get feat1Title;

  /// No description provided for @feat1Desc.
  ///
  /// In en, this message translates to:
  /// **'Identity and phone verification for security.'**
  String get feat1Desc;

  /// No description provided for @feat2Title.
  ///
  /// In en, this message translates to:
  /// **'Real-time Tracking'**
  String get feat2Title;

  /// No description provided for @feat2Desc.
  ///
  /// In en, this message translates to:
  /// **'Share your live location for safety.'**
  String get feat2Desc;

  /// No description provided for @feat3Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Search'**
  String get feat3Title;

  /// No description provided for @feat3Desc.
  ///
  /// In en, this message translates to:
  /// **'Find trips by city, date, or price.'**
  String get feat3Desc;

  /// No description provided for @feat4Title.
  ///
  /// In en, this message translates to:
  /// **'Secure Payments'**
  String get feat4Title;

  /// No description provided for @feat4Desc.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money & Card integration.'**
  String get feat4Desc;

  /// No description provided for @feat5Title.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get feat5Title;

  /// No description provided for @feat5Desc.
  ///
  /// In en, this message translates to:
  /// **'Build trust with community feedback.'**
  String get feat5Desc;

  /// No description provided for @feat6Title.
  ///
  /// In en, this message translates to:
  /// **'SOS & Safety'**
  String get feat6Title;

  /// No description provided for @feat6Desc.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts and quick dialing.'**
  String get feat6Desc;

  /// No description provided for @ourImpact.
  ///
  /// In en, this message translates to:
  /// **'🌍 Our Impact'**
  String get ourImpact;

  /// No description provided for @impact1.
  ///
  /// In en, this message translates to:
  /// **'Reduces road congestion by optimizing empty seats.'**
  String get impact1;

  /// No description provided for @impact2.
  ///
  /// In en, this message translates to:
  /// **'Decreases carbon footprint (Green Mobility).'**
  String get impact2;

  /// No description provided for @impact3.
  ///
  /// In en, this message translates to:
  /// **'Saves money for drivers and passengers.'**
  String get impact3;

  /// No description provided for @vision2050Title.
  ///
  /// In en, this message translates to:
  /// **'🇷🇼 Alignment with Rwanda Vision 2050'**
  String get vision2050Title;

  /// No description provided for @vision2050Intro.
  ///
  /// In en, this message translates to:
  /// **'iShare contributes directly to Rwanda Vision 2050 goals:'**
  String get vision2050Intro;

  /// No description provided for @visionPoint1.
  ///
  /// In en, this message translates to:
  /// **'Smart cities & green mobility.'**
  String get visionPoint1;

  /// No description provided for @visionPoint2.
  ///
  /// In en, this message translates to:
  /// **'Digital service delivery.'**
  String get visionPoint2;

  /// No description provided for @visionPoint3.
  ///
  /// In en, this message translates to:
  /// **'Innovation & entrepreneurship.'**
  String get visionPoint3;

  /// No description provided for @longTermVision.
  ///
  /// In en, this message translates to:
  /// **'🚀 Long-term Vision'**
  String get longTermVision;

  /// No description provided for @longTermText.
  ///
  /// In en, this message translates to:
  /// **'We aim to expand across East African Community (EAC), making cross-border travel seamless and affordable.'**
  String get longTermText;

  /// No description provided for @targetCountries.
  ///
  /// In en, this message translates to:
  /// **'Target Countries:'**
  String get targetCountries;

  /// No description provided for @countryRwanda.
  ///
  /// In en, this message translates to:
  /// **'Rwanda'**
  String get countryRwanda;

  /// No description provided for @countryUganda.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get countryUganda;

  /// No description provided for @countryKenya.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get countryKenya;

  /// No description provided for @countryTanzania.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get countryTanzania;

  /// No description provided for @countryBurundi.
  ///
  /// In en, this message translates to:
  /// **'Burundi'**
  String get countryBurundi;

  /// No description provided for @countryDRC.
  ///
  /// In en, this message translates to:
  /// **'DRC'**
  String get countryDRC;

  /// No description provided for @copyrightOwner.
  ///
  /// In en, this message translates to:
  /// **'iShare Rwanda Ltd'**
  String get copyrightOwner;

  /// No description provided for @ipNotice.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved. This software is the intellectual property of iShare Rwanda.'**
  String get ipNotice;

  /// No description provided for @hereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help!'**
  String get hereToHelp;

  /// No description provided for @reachOutMsg.
  ///
  /// In en, this message translates to:
  /// **'Contact us anytime, we\'d love to hear from you'**
  String get reachOutMsg;

  /// No description provided for @findUsHere.
  ///
  /// In en, this message translates to:
  /// **'Find Us Here'**
  String get findUsHere;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get In Touch'**
  String get getInTouch;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @officeHours.
  ///
  /// In en, this message translates to:
  /// **'Office Hours'**
  String get officeHours;

  /// No description provided for @monFri.
  ///
  /// In en, this message translates to:
  /// **'Monday - Friday'**
  String get monFri;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @connectWithUs.
  ///
  /// In en, this message translates to:
  /// **'Connect With Us'**
  String get connectWithUs;

  /// No description provided for @haveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Have Questions?'**
  String get haveQuestions;

  /// No description provided for @sendMessageDesc.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we\'ll respond within 24 hours'**
  String get sendMessageDesc;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @driverVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Verification'**
  String get driverVerificationTitle;

  /// No description provided for @whyVerification.
  ///
  /// In en, this message translates to:
  /// **'Why Verification?'**
  String get whyVerification;

  /// No description provided for @verificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Verification ensures safety and trust for all users. Your information is kept secure and private.'**
  String get verificationDesc;

  /// No description provided for @verificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Verification Submitted!'**
  String get verificationSubmitted;

  /// No description provided for @verificationReviewMsg.
  ///
  /// In en, this message translates to:
  /// **'Your verification request has been submitted. We\'ll review your information and notify you within 24-48 hours.'**
  String get verificationReviewMsg;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @bookedRides.
  ///
  /// In en, this message translates to:
  /// **'Booked Rides'**
  String get bookedRides;

  /// No description provided for @postedRides.
  ///
  /// In en, this message translates to:
  /// **'Posted Rides'**
  String get postedRides;

  /// No description provided for @postRide.
  ///
  /// In en, this message translates to:
  /// **'Post Ride'**
  String get postRide;

  /// No description provided for @noBookedRides.
  ///
  /// In en, this message translates to:
  /// **'No booked rides yet'**
  String get noBookedRides;

  /// No description provided for @noBookedRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Your upcoming trips will appear here.'**
  String get noBookedRidesDesc;

  /// No description provided for @noPostedRides.
  ///
  /// In en, this message translates to:
  /// **'No posted rides'**
  String get noPostedRides;

  /// No description provided for @noPostedRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn money by posting a trip today.'**
  String get noPostedRidesDesc;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @viewPassengers.
  ///
  /// In en, this message translates to:
  /// **'View Passengers'**
  String get viewPassengers;

  /// No description provided for @submitVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification'**
  String get submitVerification;

  /// No description provided for @myTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTripsTitle;

  /// No description provided for @bookedTab.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get bookedTab;

  /// No description provided for @offeredTab.
  ///
  /// In en, this message translates to:
  /// **'Offered'**
  String get offeredTab;

  /// No description provided for @noBookingsMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t booked any trips yet.'**
  String get noBookingsMessage;

  /// No description provided for @noOffersMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any trips yet.'**
  String get noOffersMessage;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to iShare'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ride-sharing platform'**
  String get welcomeSubtitle;

  /// No description provided for @statUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get statUsers;

  /// No description provided for @statTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get statTrips;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noRidesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get noRidesAvailable;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Travel with\nConfidence'**
  String get onboardTitle1;

  /// No description provided for @onboardDesc1.
  ///
  /// In en, this message translates to:
  /// **'Verified drivers, real-time tracking, and 24/7 support.'**
  String get onboardDesc1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Share Costs,\nShare Smiles'**
  String get onboardTitle2;

  /// No description provided for @onboardDesc2.
  ///
  /// In en, this message translates to:
  /// **'Connect with people on your route and save.'**
  String get onboardDesc2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Fast & Reliable\nTransport'**
  String get onboardTitle3;

  /// No description provided for @onboardDesc3.
  ///
  /// In en, this message translates to:
  /// **'Find a ride in minutes. No more waiting.'**
  String get onboardDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @orContinue.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinue;

  /// No description provided for @newToApp.
  ///
  /// In en, this message translates to:
  /// **'New to iShare?'**
  String get newToApp;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get fillAllFields;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect credentials. Please try again.'**
  String get incorrectCredentials;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Hello,\nWelcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginSecurely.
  ///
  /// In en, this message translates to:
  /// **'Log in securely to your iShare account.'**
  String get loginSecurely;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinIshare.
  ///
  /// In en, this message translates to:
  /// **'Join iShare'**
  String get joinIshare;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Last Name (Optional)'**
  String get lastNameOptional;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get registerAction;

  /// No description provided for @fillAllRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get fillAllRequired;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please log in.'**
  String get registrationSuccess;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: '**
  String get registrationFailed;

  /// No description provided for @myTicket.
  ///
  /// In en, this message translates to:
  /// **'My Ticket'**
  String get myTicket;

  /// No description provided for @tripUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Trip details unavailable'**
  String get tripUnavailable;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @bookedStatus.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get bookedStatus;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @ticketInstruction.
  ///
  /// In en, this message translates to:
  /// **'Show this ticket to the driver before boarding.'**
  String get ticketInstruction;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @estimatedEarnings.
  ///
  /// In en, this message translates to:
  /// **'Estimated Earnings'**
  String get estimatedEarnings;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @passengerManifest.
  ///
  /// In en, this message translates to:
  /// **'Passenger Manifest'**
  String get passengerManifest;

  /// No description provided for @bookedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Booked'**
  String bookedCount(int count);

  /// No description provided for @noPassengers.
  ///
  /// In en, this message translates to:
  /// **'No passengers yet.'**
  String get noPassengers;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paidStatus;

  /// No description provided for @cancelTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip?'**
  String get cancelTripTitle;

  /// No description provided for @cancelTripMessage.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the trip for all passengers and notify them. Are you sure?'**
  String get cancelTripMessage;

  /// No description provided for @keepTrip.
  ///
  /// In en, this message translates to:
  /// **'No, Keep Trip'**
  String get keepTrip;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @callingPassenger.
  ///
  /// In en, this message translates to:
  /// **'Calling passenger...'**
  String get callingPassenger;

  /// No description provided for @errorLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings: '**
  String get errorLoadingBookings;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @noBio.
  ///
  /// In en, this message translates to:
  /// **'No biography provided.'**
  String get noBio;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(String date);

  /// No description provided for @vehicleSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleSection;

  /// No description provided for @noCarPhoto.
  ///
  /// In en, this message translates to:
  /// **'No car photo available'**
  String get noCarPhoto;

  /// No description provided for @unknownModel.
  ///
  /// In en, this message translates to:
  /// **'Unknown model'**
  String get unknownModel;

  /// No description provided for @noPlateInfo.
  ///
  /// In en, this message translates to:
  /// **'No plate info'**
  String get noPlateInfo;

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get errorLoadProfile;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @shareRide.
  ///
  /// In en, this message translates to:
  /// **'Share Ride'**
  String get shareRide;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Hey! I\'m on a trip with ISHARE.\n\n🚗 Driver: {driver}\n🚙 Car: {car}\n📍 Trip: {from} ➝ {to}'**
  String shareMessage(String driver, String car, String from, String to);

  /// No description provided for @paymentAlreadyPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Already Made'**
  String get paymentAlreadyPaidTitle;

  /// No description provided for @paymentAlreadyPaidMsg.
  ///
  /// In en, this message translates to:
  /// **'This booking has already been paid. You can view it in your trips.'**
  String get paymentAlreadyPaidMsg;

  /// No description provided for @viewTrips.
  ///
  /// In en, this message translates to:
  /// **'View Trips'**
  String get viewTrips;

  /// No description provided for @approvePayment.
  ///
  /// In en, this message translates to:
  /// **'Approve Payment'**
  String get approvePayment;

  /// No description provided for @checkPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your phone.'**
  String get checkPhoneTitle;

  /// No description provided for @sentPromptTo.
  ///
  /// In en, this message translates to:
  /// **'A prompt has been sent to {phone}. Enter your PIN to approve.'**
  String sentPromptTo(String phone);

  /// No description provided for @iHaveApproved.
  ///
  /// In en, this message translates to:
  /// **'I have approved'**
  String get iHaveApproved;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @mobileMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'MTN, Airtel'**
  String get mobileMoneySubtitle;

  /// No description provided for @cardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard'**
  String get cardSubtitle;

  /// No description provided for @bankTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct transfer'**
  String get bankTransferSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: 0788123456'**
  String get phoneHint;

  /// No description provided for @enterPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enterPhoneError;

  /// No description provided for @invalidPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneError;

  /// No description provided for @rideRequests.
  ///
  /// In en, this message translates to:
  /// **'Ride Requests'**
  String get rideRequests;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
