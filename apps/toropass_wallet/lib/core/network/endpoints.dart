// ignore_for_file: constant_identifier_names

class ApiEndpoints {
  static const String BASE_URL = 'http://16.171.168.144:3000/api/v1/';

  static const String LOGIN = 'auth/login';
  static const String REGISTER = 'auth/register';
  static const String VERIFY_EMAIL = 'auth/verify-email';
  static const String RESEND_VERIFICATION = 'auth/resend-verification';
  static const String REFRESH_TOKEN = 'auth/refresh-token';
  static const String OAUTH_GOOGLE = 'auth/oauth/google';
  static const String OAUTH_APPLE = 'auth/oauth/apple';
  static const String OAUTH_FACEBOOK = 'auth/oauth/facebook';
  static const String FORGOT_PASSWORD = 'auth/forgot-password';
  static const String RESET_PASSWORD = 'auth/reset-password';
  static const String LOGOUT = 'auth/logout';

  // NOTIFICATIONS
  static const String NOTIFICATIONS = 'notifications';
  static const String NOTIFICATIONS_READ_ALL = 'notifications/read-all';
  static String notificationRead(String id) => 'notifications/$id/read';
  static String notificationById(String id) => 'notifications/$id';
  static const String DEVICES_REGISTER = 'devices/register';
  static String deviceByToken(String token) => 'devices/$token';

  // PROFILE
  static const String SELECT_ACCOUNT_TYPE = 'auth/select-account-type';
  static const String ACCOUNT_TYPE = 'account/type';
  static const String CLIENT_PERSONAL_PROFILE = 'clients/me/personal-profile';
  static const String CLIENT_BUSINESS_PROFILE = 'clients/me/business-profile';
  static const String CLIENT_BUSINESS_DOCS = 'clients/me/business-profile/docs';
  static const String CREATIVE_PERSONAL_PROFILE =
      'creatives/me/personal-profile';
  static const String CREATIVE_BUSINESS_PROFILE =
      'creatives/me/business-profile';
  static const String CREATIVE_PORTFOLIO = 'creatives/me/portfolio';
  static const String CREATIVES = 'creatives';
  static const String SUGGESTED_CREATIVES = 'creatives/suggested';

  // PLATFORM
  static const String CATEGORIES = 'categories';
  static const String COUNTRIES = 'platform/countries';
  static const String CURRENCIES = 'platform/currencies';

  // VERIFICATION
  static const String START_VERIFICATION = 'verification/start';
  static const String REFRESH_VERIFICATION_TOKEN = 'verification/token-refresh';
  static const String GET_VERIFICATION_STATUS = 'verification/status';

  // BRIEF
  static const String BRIEF = 'briefs';
  static const String MY_BRIEFS = 'briefs/me';
  static const String BRIEF_CATEGORIES = 'briefs/categories';
  static const String BRIEF_SKILLS = 'briefs/skills';
  static const String CANCEL_BRIEF = 'briefs/cancel';
  static String briefToCreative(String creativeId) =>
      'briefs/$creativeId/send-to-creative';

  // PITCHES
  static const String PITCHES = 'pitches';
  static const String MY_PITCHES = 'pitches/me';
  static String briefPitches(String briefId) => 'briefs/$briefId/pitches';
  static String pitchDetails(String id) => 'pitches/$id';
  static String acceptPitch(String id) => 'pitches/$id/accept';
  static String rejectPitch(String id) => 'pitches/$id/reject';

  // PROJECTS
  static const String PROJECTS = 'projects';
  static const String CREATIVE_GIGS = 'projects/creative';
  static String projectDetails(String id) => 'projects/$id';
  static String updateProjectStatus(String id) => 'projects/$id/status';
  static String completeMilestone(String id, String mid) =>
      'projects/$id/milestones/$mid';
  static String projectDeliverables(String id) => 'projects/$id/deliverables';
  static String downloadDeliverable(String id, String fileId) =>
      'projects/$id/deliverables/$fileId/download';
  static String collabProgress(String id) => 'projects/$id/collab-progress';
  static String authorizePayout(String id) => 'projects/$id/authorize-payout';
  static String requestRevision(String id) => 'projects/$id/request-revision';

  // COLLABORATIONS
  static const String COLLABS = 'collabs';
  static const String COLLABS_INVITE = 'collabs/invite';
  static String collabResponses(String id) => 'collabs/$id/responses';
  static String acceptCollab(String id) => 'collabs/$id/accept';
  static String rejectCollab(String id) => 'collabs/$id/reject';
  static String withdrawCollab(String id) => 'collabs/$id/withdraw';
  static String collabProgressById(String id) => 'collabs/$id/progress';
  static String collabDeliverables(String id) => 'collabs/$id/deliverables';
  static String collabGroupChat(String id) => 'collabs/$id/group-chat';

  // FAVORITES
  static const String FAVORITES = 'favorites';
  static String removeFavorite(String creativeId) => 'favorites/$creativeId';
  static String sendBriefToFavorite(String creativeId) =>
      'favorites/$creativeId/send-brief';

  // REVIEWS
  static const String REVIEWS = 'reviews';
  static const String MY_REVIEWS = 'reviews/me';
  static String creativeReviews(String creativeId) =>
      'reviews/creative/$creativeId';
  static String projectReviews(String projectId) => 'reviews/$projectId';

  // CLIENT FAM
  static const String CLIENT_FAM = 'client-fam';
  static String clientFamDetails(String clientId) => 'client-fam/$clientId';
  static String clientFamChat(String clientId) => 'client-fam/$clientId/chat';

  // DISPUTES
  static const String DISPUTES = 'disputes';
  static const String MY_DISPUTES = 'disputes/me';
  static String disputeDetails(String id) => 'disputes/$id';
  static String updateDispute(String id) => 'disputes/$id/update';

  // ORDERS / WALLET
  static const String WALLET = 'wallet';
  static const String WALLET_ADD_FUNDS = 'wallet/add-funds';
  static const String WALLET_TRANSACTIONS = 'wallet/transactions';
  static const String EARNINGS = 'earnings';
  static const String EARNINGS_BREAKDOWN = 'earnings/breakdown';
  static const String EARNINGS_TRANSACTIONS = 'earnings/transactions';
  static String earningsTransactionDetails(String id) =>
      'earnings/transactions/$id';
  static const String EARNINGS_WITHDRAW = 'earnings/withdraw';
  static const String PAYMENT_METHODS = 'payment-methods';
  static const String PAYMENT_METHOD_CARD = 'payment-methods/card';
  static const String PAYMENT_METHOD_BANK = 'payment-methods/bank';
  static String paymentMethodById(String id) => 'payment-methods/$id';
  static String createPaymentIntent(String projectId) =>
      'orders/$projectId/payment';
  static String confirmPayment(String projectId) =>
      'orders/$projectId/confirm-payment';
  static String paymentSummary(String projectId) =>
      'orders/$projectId/payment-summary';
}
