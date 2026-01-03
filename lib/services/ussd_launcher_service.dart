import 'ussd_service.dart';

/// Service central pour le lancement des codes USSD (Phase 5.1).
/// Cette classe isole l'utilisation des mécanismes d'exécution et gère la logique métier
/// conformément aux exigences du TP.
class UssdLauncherService {

  /// Extrait les noms des paramètres requis dans un code USSD (ex: {phone}, {amount})
  /// Retourne une liste de clés sans les accolades.
  List<String> extractRequiredParams(String code) {
    final RegExp regExp = RegExp(r'\{(\w+)\}');
    final Iterable<Match> matches = regExp.allMatches(code);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  /// Exécute un code USSD (Phase 5.1 - méthode launch).
  /// Cette méthode gère les validations, les exceptions (ex: SIM absente)
  /// et intègre la logique Multi-SIM demandée.
  /// [params] permet de remplacer des variables dans le code (ex: {phone}, {amount}).
  Future<void> launch(String code, {Map<String, String>? params}) async {
    try {
      String finalCode = code;

      // Remplacement des paramètres dynamiques (ex: *144*{phone}# -> *144*771234567#)
      if (params != null) {
        params.forEach((key, value) {
          finalCode = finalCode.replaceAll('{$key}', value);
        });
      }

      // Validation préalable du format du code USSD final
      if (!UssdService.isValidUssdCode(finalCode)) {
        throw UssdException("Le format du code USSD est invalide. Il doit commencer par '*' et se terminer par '#'.");
      }

      // Algorithme de gestion Multi-SIM (Phase 5.2) :

      // 1. Vérifier le nombre de SIMs actives
      int activeSims = await _checkActiveSims();

      if (activeSims > 1) {
        // 2. Vérifier si l'utilisateur a défini une SIM par défaut pour ce code spécifique
        int? preferredSim = await _getPreferredSimForCode(finalCode);

        if (preferredSim != null) {
          // Exécuter avec la SIM spécifiée (si le service natif le permet)
          await _launchOnSpecificSim(finalCode, preferredSim);
        } else {
          // 3. Sinon, demander à l'utilisateur ou utiliser la SIM par défaut du système
          // On utilise la méthode existante dialUssd qui délègue au système Android
          await UssdService.dialUssd(finalCode);
        }
      } else {
        // Cas standard : une seule SIM ou utilisation de la SIM par défaut du système
        await UssdService.dialUssd(finalCode);
      }

    } on UssdException {
      // On laisse remonter les exceptions métier connues
      rethrow;
    } catch (e) {
      // Gestion des exceptions génériques (ex: carte SIM absente ou erreur système)
      throw UssdException("Erreur lors de l'exécution du code USSD : $e");
    }
  }

  /// Vérifie le nombre de cartes SIM actives (Simulation de l'algorithme 5.2.1).
  /// Dans une version de production, cela passerait par un MethodChannel vers SubscriptionManager.
  Future<int> _checkActiveSims() async {
    // Simulation : retourne 1 par défaut.
    return 1;
  }

  /// Vérifie si une SIM préférée est enregistrée pour ce code (Simulation de l'algorithme 5.2.2).
  /// On pourrait stocker cette préférence dans la base de données locale.
  Future<int?> _getPreferredSimForCode(String code) async {
    // Simulation : aucune préférence définie.
    return null;
  }

  /// Lance le code sur un slot SIM spécifique (Simulation de l'algorithme 5.2.3).
  Future<void> _launchOnSpecificSim(String code, int slot) async {
    // Utilise la méthode existante du projet.
    // Note : Pour supporter réellement le choix de la SIM, le MethodChannel dans MainActivity.kt
    // devrait être mis à jour pour accepter un paramètre 'subscriptionId'.
    await UssdService.dialUssd(code);
  }
}
