import 'package:flutter/material.dart';
import '../models/ussd_menu.dart';
import '../repositories/ussd_repository.dart';
import '../services/ussd_service.dart';
import '../services/ussd_launcher_service.dart';

/// ViewModel pour la gestion de la logique métier des menus USSD.
/// Utilise le pattern MVVM pour séparer l'interface de la logique.
class UssdViewModel extends ChangeNotifier {
  final UssdRepository _repository = UssdRepository();
  final UssdLauncherService _launcherService = UssdLauncherService();

  List<UssdMenu> _menus = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UssdMenu> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UssdViewModel() {
    fetchMenus();
  }

  /// Récupère tous les menus depuis la base de données
  Future<void> fetchMenus() async {
    _setLoading(true);
    try {
      _menus = await _repository.getMenus();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Erreur lors du chargement des menus : $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Ajoute un nouveau menu USSD
  Future<void> addMenu(UssdMenu menu) async {
    try {
      await _repository.addMenu(menu);
      await fetchMenus();
    } catch (e) {
      _errorMessage = "Erreur lors de l'ajout : $e";
      notifyListeners();
    }
  }

  /// Met à jour un menu existant
  Future<void> updateMenu(UssdMenu menu) async {
    try {
      await _repository.updateMenu(menu);
      await fetchMenus();
    } catch (e) {
      _errorMessage = "Erreur lors de la modification : $e";
      notifyListeners();
    }
  }

  /// Supprime un menu par son ID
  Future<void> deleteMenu(int id) async {
    try {
      await _repository.deleteMenu(id);
      await fetchMenus();
    } catch (e) {
      _errorMessage = "Erreur lors de la suppression : $e";
      notifyListeners();
    }
  }

  /// Recherche des menus par titre ou catégorie
  Future<void> searchMenus(String query) async {
    _setLoading(true);
    try {
      _menus = await _repository.searchMenus(query);
    } catch (e) {
      _errorMessage = "Erreur lors de la recherche : $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Récupère les paramètres requis pour un code donné (ex: {phone})
  List<String> getRequiredParams(String code) {
    return _launcherService.extractRequiredParams(code);
  }

  /// Exécute un code USSD en utilisant le service centralisé (Phase 5.1).
  /// Utilise la méthode existante dans le projet au lieu de la dépendance ussd_advanced.
  /// [params] contient les valeurs pour les variables du code.
  Future<void> launchUssd(String code, {Map<String, String>? params}) async {
    try {
      _errorMessage = null;
      await _launcherService.launch(code, params: params);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
