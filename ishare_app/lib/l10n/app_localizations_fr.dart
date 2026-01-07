// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get home => 'Accueil';

  @override
  String get find => 'Rechercher';

  @override
  String get trips => 'Trajets';

  @override
  String get profile => 'Profil';

  @override
  String get goodMorning => 'Bonjour,';

  @override
  String get whereToNext => 'Où allez-vous?';

  @override
  String get searchRides => 'Rechercher des trajets';

  @override
  String get currentLocation => 'Position actuelle';

  @override
  String get enterDestination => 'Entrez la destination...';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get findRide => 'Trouver un trajet';

  @override
  String get bookNow => 'Réserver';

  @override
  String get offerRide => 'Proposer un trajet';

  @override
  String get earnMoney => 'Gagner de l\'argent';

  @override
  String get safetyCenter => 'Sécurité';

  @override
  String get guidelines => 'Directives';

  @override
  String get aboutUs => 'À Propos';

  @override
  String get ourStory => 'Notre histoire';

  @override
  String get recommended => 'Recommandé';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get whyIshare => 'Pourquoi iShare ?';

  @override
  String get saveCosts => 'Économiser';

  @override
  String get saveCostsDesc => 'Voyagez moins cher.';

  @override
  String get ecoFriendly => 'Écologique';

  @override
  String get ecoFriendlyDesc => 'Réduisez l\'empreinte carbone.';

  @override
  String get community => 'Communauté';

  @override
  String get communityDesc => 'Connectez-vous aux autres.';

  @override
  String seatsLeft(int count) {
    return '$count places restantes';
  }

  @override
  String get totalPrice => 'Prix Total';

  @override
  String get pickUp => 'Départ';

  @override
  String get dropOff => 'Arrivée';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get verificationRequired => 'Vérification requise';

  @override
  String get verifyAccountMsg =>
      'Veuillez vérifier votre compte avant d\'effectuer le paiement.';

  @override
  String get cancel => 'Annuler';

  @override
  String get verifyNow => 'Vérifier maintenant';

  @override
  String get paymentInitiated => 'Paiement initié';

  @override
  String get checkPhoneMsg =>
      'Veuillez vérifier votre téléphone pour une confirmation de paiement.';

  @override
  String get transactionId => 'ID de transaction';

  @override
  String get amount => 'Montant';

  @override
  String get done => 'Terminé';

  @override
  String get paymentFailed => 'Paiement échoué';

  @override
  String get accountVerified => 'Compte vérifié';

  @override
  String get accountNotVerified => 'Compte non vérifié';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get selectPaymentMethod => 'Sélectionnez le mode de paiement';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get cardPayment => 'Paiement par carte';

  @override
  String get cardPaymentComingSoon =>
      'L\'intégration du paiement par carte arrive bientôt. Veuillez utiliser Mobile Money pour le moment.';

  @override
  String get bankTransfer => 'Virement bancaire';

  @override
  String get bankTransferDetails =>
      'Les détails du virement bancaire seront envoyés à votre email.';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get paymentPromptMsg =>
      'Vous recevrez une demande de paiement sur ce numéro';

  @override
  String get payNow => 'Payer maintenant';

  @override
  String get verifyToPay => 'Vérifier le compte pour payer';

  @override
  String get verifyIdentity => 'Vérifier l\'identité';

  @override
  String get verifyIdentityTitle => 'Confirmez votre identité';

  @override
  String get verifyIdentitySubtitle =>
      'Nous devons vérifier votre identité avant que vous puissiez publier un trajet';

  @override
  String get fullName => 'Nom complet';

  @override
  String get fullNameHint => 'Entrez votre nom complet';

  @override
  String get nationalIdLabel => 'Numéro de carte d\'identité nationale';

  @override
  String get idHelperText => '16 chiffres';

  @override
  String get paymentMethodsAccepted =>
      'Acceptés: MTN Mobile Money, Airtel Money';

  @override
  String get iAgreeTo => 'J\'accepte les ';

  @override
  String get termsAndConditions => 'Conditions générales';

  @override
  String get and => ' et la ';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get confirmAndContinue => 'Confirmer et continuer';

  @override
  String get secureInfoMsg => 'Vos informations sont cryptées et sécurisées';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get enterTwoNames => 'Entrez au moins deux noms';

  @override
  String get invalidNameChars =>
      'Les noms doivent contenir uniquement des lettres';

  @override
  String get enterNationalId => 'Entrez votre carte d\'identité nationale';

  @override
  String get invalidIdLength =>
      'La carte d\'identité doit comporter 16 chiffres';

  @override
  String get invalidIdChars => 'L\'ID doit contenir uniquement des chiffres';

  @override
  String get enterPhoneNumber => 'Entrez votre numéro de téléphone';

  @override
  String get invalidPhone => 'Entrez un numéro rwandais valide';

  @override
  String get acceptTerms => 'Acceptez les conditions avant de continuer';

  @override
  String get verificationSuccess => 'Vérification réussie!';

  @override
  String get verificationSuccessMsg =>
      'Votre identité a été vérifiée. Vous pouvez maintenant commencer votre trajet.';

  @override
  String get continueText => 'Continuer';

  @override
  String get route => 'Itinéraire';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get details => 'Détails';

  @override
  String get review => 'Révision';

  @override
  String get startingPoint => 'Point de départ';

  @override
  String get destination => 'Destination';

  @override
  String get vehicleModel => 'Modèle de véhicule';

  @override
  String get vehiclePhoto => 'Photo du véhicule';

  @override
  String get uploadCarPhoto => 'Appuyez pour télécharger une photo';

  @override
  String get departureTime => 'Heure de départ';

  @override
  String get price => 'Prix';

  @override
  String get planRoute => 'Planifiez votre itinéraire';

  @override
  String get vehicleDetails => 'Détails du véhicule';

  @override
  String get tripInfo => 'Informations sur le trajet';

  @override
  String get summary => 'Résumé';

  @override
  String get planRouteDesc => 'Où commencez-vous et où allez-vous?';

  @override
  String get vehicleDetailsDesc => 'Parlez de votre véhicule aux passagers.';

  @override
  String get tripInfoDesc => 'Définissez votre horaire et vos prix.';

  @override
  String get summaryDesc => 'Vérifiez tout avant de publier.';

  @override
  String get publishRide => 'Publier le trajet';

  @override
  String get fillFormHelp => 'Remplissez le formulaire pour publier un trajet.';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get searchComingSoon => 'La fonction de recherche arrive bientôt!';

  @override
  String get searchFeatureDesc =>
      'Vous pourrez rechercher des trajets par lieu, date et prix ici.';

  @override
  String get emergencySOS => 'SOS d\'urgence';

  @override
  String get sosActive => 'Alerte SOS active';

  @override
  String get pressAndHold => 'Appuyez et maintenez pendant 3 secondes';

  @override
  String get sosActivated => 'SOS activé';

  @override
  String get emergencyAlertSent => 'L\'alerte d\'urgence a été envoyée à:';

  @override
  String get emergencyContacts => 'Contacts d\'urgence';

  @override
  String get ishareSupport => 'Équipe de support iShare';

  @override
  String get currentTripDriver => 'Votre chauffeur/passager du trajet actuel';

  @override
  String get liveLocationShared => 'Votre position en direct est partagée.';

  @override
  String get call112 => 'Appeler le 112';

  @override
  String get shareLocation => 'Partager la position';

  @override
  String get shareLocationDesc =>
      'Votre position actuelle sera partagée avec vos contacts sélectionnés par SMS.';

  @override
  String get locationSharedSuccess => 'Position partagée avec succès!';

  @override
  String get share => 'Partager';

  @override
  String get cancelTrip => 'Annuler le trajet';

  @override
  String get tripCancelRequest => 'Demande d\'annulation de trajet';

  @override
  String get police => 'Police nationale du Rwanda';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get fireBrigade => 'Pompiers';

  @override
  String get emergencyServices => 'Services d\'urgence';

  @override
  String get safetyTips => 'Conseils de sécurité';

  @override
  String get verifyDriver => 'Vérifier les détails du chauffeur';

  @override
  String get verifyDriverDesc =>
      'Vérifiez toujours le nom, la photo et les détails du véhicule du chauffeur avant d\'entrer.';

  @override
  String get shareTrip => 'Partager les détails du trajet';

  @override
  String get shareTripDesc =>
      'Partagez les détails de votre trajet avec vos amis ou votre famille avant de partir.';

  @override
  String get stayConnected => 'Restez connecté';

  @override
  String get stayConnectedDesc =>
      'Gardez votre téléphone chargé et accessible pendant le trajet.';

  @override
  String get checkRatings => 'Vérifier les évaluations';

  @override
  String get checkRatingsDesc =>
      'Consultez les évaluations et commentaires des autres passagers sur le chauffeur.';

  @override
  String get reportIssues => 'Signaler des problèmes';

  @override
  String get reportIssuesDesc =>
      'Signalez immédiatement tout comportement suspect ou préoccupation de sécurité.';

  @override
  String get safetyMatters => 'Votre sécurité compte';

  @override
  String get safetyCommitment =>
      'iShare s\'engage à fournir une expérience de covoiturage sûre et sécurisée. Tous les chauffeurs sont vérifiés.';

  @override
  String get call => 'Appeler';

  @override
  String get aboutIShare => 'À propos d\'iShare';

  @override
  String get appName => 'iShare';

  @override
  String get appTagline => 'Partagez le trajet, partagez les coûts';

  @override
  String get appDescriptionShort =>
      'Plateforme intelligente de covoiturage et de partage des coûts';

  @override
  String get visionTitle => '🎯 Vision';

  @override
  String get visionText =>
      'Révolutionner le transport au Rwanda et en Afrique de l\'Est en créant un réseau de covoiturage fiable, écologique et abordable.';

  @override
  String get missionTitle => '🚀 Mission';

  @override
  String get missionText =>
      'Connecter les propriétaires de voitures avec des sièges vides aux passagers allant dans la même direction, réduisant les coûts de transport, la congestion routière et les émissions de carbone.';

  @override
  String get problemTitle => '❓ Le problème';

  @override
  String get problemText =>
      'Les prix du carburant augmentent, la congestion routière s\'intensifie et les transports publics peuvent être peu pratiques. De nombreuses voitures privées voyagent avec 3-4 sièges vides.';

  @override
  String get solutionTitle => '✅ Notre solution';

  @override
  String get solutionText =>
      'iShare connecte les chauffeurs et les passagers. Les chauffeurs gagnent de l\'argent pour compenser les coûts de carburant, et les passagers voyagent confortablement à un prix inférieur.';

  @override
  String get howItWorks => '📱 Comment ça marche';

  @override
  String get step1Title => 'Le chauffeur publie le trajet';

  @override
  String get step1Desc =>
      'Un chauffeur se rendant à une destination liste les détails de son trajet (heure, sièges, prix).';

  @override
  String get step2Title => 'Le passager réserve';

  @override
  String get step2Desc =>
      'Les passagers recherchent des trajets et réservent une place instantanément.';

  @override
  String get step3Title => 'Voyager ensemble';

  @override
  String get step3Desc =>
      'Ils se rencontrent au point de ramassage et profitent du voyage.';

  @override
  String get step4Title => 'Noter et payer';

  @override
  String get step4Desc =>
      'Le paiement est traité et les deux parties se notent mutuellement.';

  @override
  String get keyFeatures => '⚡ Fonctionnalités clés';

  @override
  String get feat1Title => 'Utilisateurs vérifiés';

  @override
  String get feat1Desc =>
      'Vérification d\'identité et de téléphone pour la sécurité.';

  @override
  String get feat2Title => 'Suivi en temps réel';

  @override
  String get feat2Desc => 'Partagez votre position en direct pour la sécurité.';

  @override
  String get feat3Title => 'Recherche intelligente';

  @override
  String get feat3Desc => 'Trouvez des trajets par ville, date ou prix.';

  @override
  String get feat4Title => 'Paiements sécurisés';

  @override
  String get feat4Desc => 'Intégration Mobile Money et carte.';

  @override
  String get feat5Title => 'Évaluations et avis';

  @override
  String get feat5Desc =>
      'Construisez la confiance avec les commentaires de la communauté.';

  @override
  String get feat6Title => 'SOS et sécurité';

  @override
  String get feat6Desc => 'Alertes d\'urgence et numérotation rapide.';

  @override
  String get ourImpact => '🌍 Notre impact';

  @override
  String get impact1 =>
      'Réduit la congestion routière en optimisant les sièges vides.';

  @override
  String get impact2 => 'Diminue l\'empreinte carbone (Mobilité verte).';

  @override
  String get impact3 =>
      'Économise de l\'argent pour les chauffeurs et les passagers.';

  @override
  String get vision2050Title => '🇷🇼 Alignement avec Vision 2050 du Rwanda';

  @override
  String get vision2050Intro =>
      'iShare contribue directement aux objectifs de Vision 2050 du Rwanda:';

  @override
  String get visionPoint1 => 'Villes intelligentes et mobilité verte.';

  @override
  String get visionPoint2 => 'Prestation de services numériques.';

  @override
  String get visionPoint3 => 'Innovation et entrepreneuriat.';

  @override
  String get longTermVision => '🚀 Vision à long terme';

  @override
  String get longTermText =>
      'Nous visons à nous étendre dans toute la Communauté d\'Afrique de l\'Est (CAE), rendant les voyages transfrontaliers fluides et abordables.';

  @override
  String get targetCountries => 'Pays cibles:';

  @override
  String get countryRwanda => 'Rwanda';

  @override
  String get countryUganda => 'Ouganda';

  @override
  String get countryKenya => 'Kenya';

  @override
  String get countryTanzania => 'Tanzanie';

  @override
  String get countryBurundi => 'Burundi';

  @override
  String get countryDRC => 'RDC';

  @override
  String get copyrightOwner => 'iShare Rwanda Ltd';

  @override
  String get ipNotice =>
      'Tous droits réservés. Ce logiciel est la propriété intellectuelle d\'iShare Rwanda. La reproduction ou distribution non autorisée est strictement interdite.';

  @override
  String get hereToHelp => 'Nous sommes là pour vous aider!';

  @override
  String get reachOutMsg =>
      'Contactez-nous à tout moment, nous serions ravis de vous entendre';

  @override
  String get findUsHere => 'Trouvez-nous ici';

  @override
  String get directions => 'Directions';

  @override
  String get getInTouch => 'Entrer en contact';

  @override
  String get address => 'Adresse';

  @override
  String get callUs => 'Appelez-nous';

  @override
  String get email => 'Email';

  @override
  String get hours => 'Heures';

  @override
  String get officeHours => 'Heures de bureau';

  @override
  String get monFri => 'Lundi - Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get closed => 'Fermé';

  @override
  String get connectWithUs => 'Connectez-vous avec nous';

  @override
  String get haveQuestions => 'Vous avez des questions?';

  @override
  String get sendMessageDesc =>
      'Envoyez-nous un message et nous vous répondrons dans les 24 heures';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get driverVerificationTitle => 'Vérification du chauffeur';

  @override
  String get whyVerification => 'Pourquoi la vérification?';

  @override
  String get verificationDesc =>
      'La vérification assure la sécurité et la confiance pour tous les utilisateurs. Vos informations sont gardées sécurisées et privées.';

  @override
  String get verificationSubmitted => 'Vérification soumise!';

  @override
  String get verificationReviewMsg =>
      'Votre demande de vérification a été soumise. Nous examinerons vos informations et vous informerons dans les 24-48 heures.';

  @override
  String get myActivity => 'Mon activité';

  @override
  String get bookedRides => 'Trajets réservés';

  @override
  String get postedRides => 'Trajets publiés';

  @override
  String get postRide => 'Publier un trajet';

  @override
  String get noBookedRides => 'Aucun trajet réservé pour le moment';

  @override
  String get noBookedRidesDesc => 'Vos prochains trajets apparaîtront ici.';

  @override
  String get noPostedRides => 'Aucun trajet publié';

  @override
  String get noPostedRidesDesc =>
      'Gagnez de l\'argent en publiant un trajet aujourd\'hui.';

  @override
  String get seats => 'Sièges';

  @override
  String get upcoming => 'À venir';

  @override
  String get completed => 'Terminé';

  @override
  String get viewPassengers => 'Voir les passagers';

  @override
  String get submitVerification => 'Soumettre la vérification';

  @override
  String get myTripsTitle => 'Mes Trajets';

  @override
  String get bookedTab => 'Réservé';

  @override
  String get offeredTab => 'Offert';

  @override
  String get noBookingsMessage => 'Aucun trajet réservé pour le moment.';

  @override
  String get noOffersMessage => 'Vous n\'avez publié aucun trajet.';

  @override
  String get welcomeTitle => 'Bienvenue sur iShare';

  @override
  String get welcomeSubtitle => 'Votre plateforme de covoiturage';

  @override
  String get statUsers => 'Utilisateurs';

  @override
  String get statTrips => 'Trajets';

  @override
  String get statRating => 'Note';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get noRidesAvailable => 'Aucun trajet disponible';

  @override
  String get onboardTitle1 => 'Voyagez en\nToute Confiance';

  @override
  String get onboardDesc1 =>
      'Chauffeurs vérifiés, suivi en temps réel et assistance 24/7.';

  @override
  String get onboardTitle2 => 'Partagez les Frais,\nPartagez des Sourires';

  @override
  String get onboardDesc2 =>
      'Connectez-vous avec des gens sur votre route et économisez.';

  @override
  String get onboardTitle3 => 'Transport Rapide\net Fiable';

  @override
  String get onboardDesc3 =>
      'Trouvez un trajet en quelques minutes. Fini l\'attente.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get login => 'Connexion';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get orContinue => 'Ou continuer avec';

  @override
  String get newToApp => 'Nouveau sur iShare ?';

  @override
  String get register => 'S\'inscrire';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get incorrectCredentials =>
      'Identifiants incorrects. Veuillez réessayer.';

  @override
  String get welcomeBack => 'Bonjour,\nBon retour !';

  @override
  String get loginSecurely => 'Connectez-vous en toute sécurité.';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinIshare => 'Rejoindre iShare';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastNameOptional => 'Nom (Optionnel)';

  @override
  String get emailAddress => 'Adresse E-mail';

  @override
  String get registerAction => 'S\'INSCRIRE';

  @override
  String get fillAllRequired =>
      'Veuillez remplir tous les champs obligatoires.';

  @override
  String get registrationSuccess =>
      'Inscription réussie ! Veuillez vous connecter.';

  @override
  String get registrationFailed => 'Échec de l\'inscription : ';

  @override
  String get myTicket => 'Mon Billet';

  @override
  String get tripUnavailable => 'Détails du trajet indisponibles';

  @override
  String get bookingId => 'ID Réservation';

  @override
  String get dateLabel => 'Date';

  @override
  String get bookedStatus => 'Réservé(s)';

  @override
  String get driverLabel => 'Chauffeur';

  @override
  String get ticketInstruction =>
      'Présentez ce billet au chauffeur lors de l\'embarquement.';

  @override
  String get tripDetails => 'Détails du Trajet';

  @override
  String get estimatedEarnings => 'Gains Estimés';

  @override
  String get totalRevenue => 'Revenu Total';

  @override
  String get passengerManifest => 'Liste des Passagers';

  @override
  String bookedCount(int count) {
    return '$count Réservé(s)';
  }

  @override
  String get noPassengers => 'Aucun passager pour le moment.';

  @override
  String get paidStatus => 'PAYÉ';

  @override
  String get cancelTripTitle => 'Annuler le trajet ?';

  @override
  String get cancelTripMessage =>
      'Cela annulera le trajet pour tous les passagers et les notifiera. Êtes-vous sûr ?';

  @override
  String get keepTrip => 'Garder le trajet';

  @override
  String get yesCancel => 'Oui, Annuler';

  @override
  String get callingPassenger => 'Appel du passager...';

  @override
  String get errorLoadingBookings =>
      'Erreur lors du chargement des réservations : ';

  @override
  String get aboutSection => 'À propos';

  @override
  String get noBio => 'Aucune biographie fournie.';

  @override
  String joinedDate(String date) {
    return 'Rejoint le $date';
  }

  @override
  String get vehicleSection => 'Véhicule';

  @override
  String get noCarPhoto => 'Aucune photo de voiture';

  @override
  String get unknownModel => 'Modèle inconnu';

  @override
  String get noPlateInfo => 'Aucune plaque';

  @override
  String get errorLoadProfile => 'Impossible de charger le profil';

  @override
  String get mapView => 'Carte';

  @override
  String get listView => 'Liste';

  @override
  String get shareRide => 'Partager le trajet';

  @override
  String shareMessage(String driver, String car, String from, String to) {
    return 'Salut ! Je suis en route avec ISHARE.\n\n🚗 Chauffeur : $driver\n🚙 Voiture : $car\n📍 Trajet : $from ➝ $to';
  }

  @override
  String get paymentAlreadyPaidTitle => 'Paiement déjà effectué';

  @override
  String get paymentAlreadyPaidMsg =>
      'Cette réservation a déjà été payée. Vous pouvez la voir dans vos trajets.';

  @override
  String get viewTrips => 'Voir les trajets';

  @override
  String get approvePayment => 'Approuver le paiement';

  @override
  String get checkPhoneTitle => 'Veuillez vérifier votre téléphone.';

  @override
  String sentPromptTo(String phone) {
    return 'Une demande a été envoyée au $phone. Entrez votre code PIN pour approuver.';
  }

  @override
  String get iHaveApproved => 'J\'ai approuvé';

  @override
  String get ok => 'OK';

  @override
  String get mobileMoneySubtitle => 'MTN, Airtel';

  @override
  String get cardSubtitle => 'Visa, Mastercard';

  @override
  String get bankTransferSubtitle => 'Virement direct';

  @override
  String get phoneHint => 'ex: 0788123456';

  @override
  String get enterPhoneError => 'Veuillez entrer le numéro de téléphone';

  @override
  String get invalidPhoneError => 'Numéro de téléphone invalide';

  @override
  String get rideRequests => 'Demandes de trajet';

  @override
  String get editProfile => 'Modifier le profil';
}
