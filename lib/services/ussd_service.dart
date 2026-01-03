import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service pour gérer les codes USSD et les appels téléphoniques
class UssdService {
  // Code de base pour le service (à modifier selon votre opérateur)
  static const String _baseServiceCode = '145';

  // Canal pour communiquer avec le code natif Android
  static const MethodChannel _channel = MethodChannel(
    'com.example.flutter_ussd_app/ussd',
  );

  /// Construit un code USSD pour le transfert d'argent
  /// Format: *144*1*destinataire*montant#
  static String buildTransferCode({
    required String recipient,
    required String amount,
    required String pin,
    String? serviceCode,
  }) {
    final code = serviceCode ?? _baseServiceCode;
    return '*$code*1*$recipient*$amount*$pin#';
  }

  /// Construit un code USSD pour vérifier le solde
  /// Format: *144#
  static String buildBalanceCode({String? serviceCode}) {
    final code = serviceCode ?? _baseServiceCode;
    return '*$code#';
  }

  /// Construit un code USSD pour acheter du crédit
  /// Format: *144*2*montant# (pour soi-même)
  /// Format: *144*2*destinataire*montant# (pour quelqu'un d'autre)
  static String buildAirtimeCode({
    required String amount,
    String? recipient,
    String? serviceCode,
  }) {
    final code = serviceCode ?? _baseServiceCode;
    if (recipient != null && recipient.isNotEmpty) {
      return '*$code*2*$recipient*$amount#';
    }
    return '*$code*2*$amount#';
  }

  /// Vérifie et demande les permissions nécessaires
  static Future<bool> checkAndRequestPermissions() async {
    final status = await Permission.phone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Compose et exécute automatiquement un code USSD via le canal natif
  static Future<bool> dialUssd(String code) async {
    // Vérifier les permissions
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw UssdException('Permission téléphone refusée');
    }

    try {
      // Utiliser le canal natif pour exécuter automatiquement le code
      final result = await _channel.invokeMethod('directCall', {'code': code});
      return result == true;
    } on PlatformException catch (e) {
      throw UssdException('Erreur: ${e.message}');
    }
  }

  /// Passe un appel téléphonique via le canal natif
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw UssdException('Permission téléphone refusée');
    }

    // Nettoyer le numéro
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      // Utiliser le canal natif pour passer l'appel
      final result = await _channel.invokeMethod('directCall', {
        'code': cleanNumber,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw UssdException('Impossible d\'appeler: ${e.message}');
    }
  }

  /// Valide le format d'un code USSD
  static bool isValidUssdCode(String code) {
    // Un code USSD doit commencer par * et finir par #
    return code.startsWith('*') && code.endsWith('#');
  }

  /// Valide un numéro de téléphone
  static bool isValidPhoneNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    // Au moins 8 chiffres
    return cleanNumber.length >= 8;
  }

  /// Valide un montant
  static bool isValidAmount(String amount) {
    final parsed = int.tryParse(amount);
    return parsed != null && parsed > 0;
  }
}

/// Exception personnalisée pour les erreurs USSD
class UssdException implements Exception {
  final String message;
  UssdException(this.message);

  @override
  String toString() => message;
}
