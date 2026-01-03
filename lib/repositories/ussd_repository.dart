import '../models/ussd_menu.dart';
import '../services/database_service.dart';

/// Repository pour la gestion des codes USSD
/// Fait le lien entre la logique métier et la source de données (SQLite)
class UssdRepository {
  final DatabaseService _databaseService = DatabaseService();

  /// Récupère la liste de tous les codes USSD enregistrés
  Future<List<UssdMenu>> getMenus() async {
    return await _databaseService.getAllMenus();
  }

  /// Ajoute un nouveau code USSD
  Future<void> addMenu(UssdMenu menu) async {
    await _databaseService.insertMenu(menu);
  }

  /// Met à jour un code USSD existant
  Future<void> updateMenu(UssdMenu menu) async {
    await _databaseService.updateMenu(menu);
  }

  /// Supprime un code USSD par son identifiant
  Future<void> deleteMenu(int id) async {
    await _databaseService.deleteMenu(id);
  }

  /// Recherche des codes USSD par titre ou catégorie
  Future<List<UssdMenu>> searchMenus(String query) async {
    if (query.isEmpty) {
      return await getMenus();
    }
    return await _databaseService.searchMenus(query);
  }
}
