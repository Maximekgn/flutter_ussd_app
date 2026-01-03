import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ussd_menu.dart';
import '../viewmodels/ussd_viewmodel.dart';

/// Écran de création et de modification d'un code USSD.
/// Gère la validation des données et l'interaction avec le ViewModel.
class EditMenuScreen extends StatefulWidget {
  final UssdMenu? menu;

  const EditMenuScreen({super.key, this.menu});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Orange';

  final List<String> _categories = ['Orange', 'Moov', 'MTN', 'Banque', 'Autre'];

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les données existantes si on est en mode édition
    _titleController = TextEditingController(text: widget.menu?.title ?? '');
    _codeController = TextEditingController(text: widget.menu?.code ?? '');
    _descriptionController = TextEditingController(text: widget.menu?.description ?? '');

    if (widget.menu != null && _categories.contains(widget.menu!.category)) {
      _selectedCategory = widget.menu!.category;
    } else if (widget.menu != null) {
      // Si la catégorie n'est pas dans la liste prédéfinie
      _selectedCategory = 'Autre';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Valide et enregistre le menu USSD
  void _saveMenu() {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<UssdViewModel>();
      final menu = UssdMenu(
        id: widget.menu?.id,
        title: _titleController.text.trim(),
        code: _codeController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
      );

      if (widget.menu == null) {
        viewModel.addMenu(menu);
      } else {
        viewModel.updateMenu(menu);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.menu != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le code' : 'Nouveau code USSD'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du service',
                  hintText: 'Ex: Achat Forfait Data',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Code USSD avec validation Regex
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code USSD',
                  hintText: 'Ex: *144*{phone}*{amount}#',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dialpad),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un code';
                  }
                  // Regex pour vérifier le format USSD (*...#) avec support des paramètres {var}
                  if (!RegExp(r'^\*[\d\*#{}a-zA-Z_]*#$').hasMatch(value)) {
                    return 'Format invalide (ex: *144*{phone}#)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélecteur de Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie / Opérateur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Champ Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEditing ? 'METTRE À JOUR' : 'ENREGISTRER',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
