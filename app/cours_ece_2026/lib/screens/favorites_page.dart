import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';
import 'package:formation_flutter/screens/product_page.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<RecordModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = context.read<PocketBaseService>().getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore de favoris.'),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              final barcode = item.getStringValue('barcode');
              final name = item.getStringValue('product_name');
              final brand = item.getStringValue('brand');
              final imageUrl = item.getStringValue('image_url');
              final nutriscore = item.getStringValue('nutriscore');

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image))
                    : const Icon(Icons.image_not_supported),
                title: Text(name.isNotEmpty ? name : 'Produit inconnu'),
                subtitle: Text('$brand • $nutriscore'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductPage(barcode: barcode),
                    ),
                  ).then((_) => _refreshFavorites());
                },
              );
            },
          );
        },
      ),
    );
  }
}
