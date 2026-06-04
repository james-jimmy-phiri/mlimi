import 'dart:io';
import 'dart:async';

class ErrorUtils {
  /// Returns a user-friendly error message based on the exception type and language.
  static String getFriendlyErrorMessage(Object error, String language) {
    if (error is SocketException) {
      return language == 'en'
          ? 'No internet connection. Please check your data or Wi-Fi.'
          : 'Palibe intaneti. Onani deta yanu kapena Wi-Fi.';
    } else if (error is TimeoutException) {
      return language == 'en'
          ? 'Connection timed out. Please try again later.'
          : 'Nthawi yatha. Yesaninso pakapita nthawi.';
    } else if (error is HttpException) {
      return language == 'en'
          ? 'Server error occurred. Please try again later.'
          : 'Cholakwika pa seva. Yesaninso pakapita nthawi.';
    } else if (error is FormatException) {
      return language == 'en'
          ? 'Invalid response from server.'
          : 'Zotsulidwa molakwika kuchokera ku seva.';
    } else if (error is Exception) {
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }

    // Default error message: show the error instead of hiding it
    return error.toString();
  }
}
