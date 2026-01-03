import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ussd_viewmodel.dart';
import '../models/ussd_menu.dart';
import 'edit_menu_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Retourne une couleur en fonction de la catégorie/opérateur
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'orange':
        return Colors.orange;
      case 'moov':
        return Colors.blue;
      case 'mtn':
        return Colors.yellow.shade800;
      case 'banque':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USSD Manager'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                context.read<UssdViewModel>().searchMenus(value);
              },
            ),
          ),
        ),
      ),
      body: Consumer<UssdViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.errorMessage!)),
              );
              viewModel.clearError();
            });
          }

          if (viewModel.menus.isEmpty) {
            return const Center(
              child: Text('Aucun code USSD trouvé.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: viewModel.menus.length,
            itemBuilder: (context, index) {
              final menu = viewModel.menus[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(menu.category),
                    child: Text(
                      menu.category.isNotEmpty ? menu.category[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    menu.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(menu.code),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMenuScreen(menu: menu),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.green, size: 32),
                        onPressed: () => _handleLaunch(context, viewModel, menu),
                      ),
                    ],
                  ),
                  onLongPress: () => _showDeleteDialog(context, viewModel, menu),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditMenuScreen(),
            ),
          );
        },
        label: const Text('Ajouter'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _handleLaunch(BuildContext context, UssdViewModel viewModel, UssdMenu menu) {
    final params = viewModel.getRequiredParams(menu.code);
    if (params.isEmpty) {
      viewModel.launchUssd(menu.code);
    } else {
      _showParamsDialog(context, viewModel, menu, params);
    }
  }

  void _showParamsDialog(
    BuildContext context,
    UssdViewModel viewModel,
    UssdMenu menu,
    List<String> params,
  ) {
    final Map<String, TextEditingController> controllers = {
      for (var p in params) p: TextEditingController()
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paramètres : ${menu.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: params.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: controllers[p],
                decoration: InputDecoration(
                  labelText: p.toUpperCase(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: p.toLowerCase().contains('phone') || p.toLowerCase().contains('amount')
                    ? TextInputType.number
                    : TextInputType.text,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () {
              final Map<String, String> values = {
                for (var entry in controllers.entries) entry.key: entry.value.text
              };
              viewModel.launchUssd(menu.code, params: values);
              Navigator.pop(context);
            },
            child: const Text('LANCER'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UssdViewModel viewModel, UssdMenu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le code'),
        content: Text('Voulez-vous vraiment supprimer "${menu.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteMenu(menu.id!);
              Navigator.pop(context);
            },
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
