import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/providers/auth_provider.dart';
import 'package:formation_flutter/screens/scanner_screen.dart';
import 'package:formation_flutter/screens/favorites_page.dart';
import 'package:formation_flutter/screens/product_page.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<RecordModel>> _scansFuture;

  @override
  void initState() {
    super.initState();
    _refreshScans();
  }

  void _refreshScans() {
    setState(() {
      _scansFuture = context.read<PocketBaseService>().getScans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.heightOf(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ).then((_) => _refreshScans());
            },
            icon: Icon(AppIcons.barcode),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ).then((_) => _refreshScans());
            },
            icon: const Icon(Icons.star, color: Color(0xFF1E2652)),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
            icon: const Icon(Icons.exit_to_app, color: AppColors.blue),
          ),
        ],
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: _scansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final scans = snapshot.data ?? [];

          if (scans.isEmpty) {
            return _buildEmptyState(context, localizations);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              final barcode = scan.getStringValue('barcode');
              final name = scan.getStringValue('product_name');
              final brand = scan.getStringValue('brand');
              final imageUrl = scan.getStringValue('image_url');
              final nutriscore = scan.getStringValue('nutriscore');

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 120,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 120,
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                      ),
                      // Product Details
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductPage(barcode: barcode),
                              ),
                            ).then((_) => _refreshScans());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'Produit inconnu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF1E2652),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  brand.isNotEmpty ? brand : 'Marque inconnue',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.circle, size: 12, color: _getNutriColor(nutriscore)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Nutriscore : ${nutriscore.toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getNutriColor(String score) {
    switch (score.toLowerCase()) {
      case 'a': return Colors.green.shade800;
      case 'b': return Colors.green;
      case 'c': return Colors.yellow.shade700;
      case 'd': return Colors.orange;
      case 'e': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Spacer(flex: 20),
            SvgPicture.asset(AppVectorialImages.illEmpty),
            Spacer(flex: 15),
            Text(
              'Vous n\'avez pas encore scanné de produit',
              textAlign: TextAlign.center,
            ),
            Spacer(flex: 10),
            TextButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                backgroundColor: AppColors.yellow,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                ).then((_) => _refreshScans());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations.my_scans_screen_button.toUpperCase()),
                  const SizedBox(width: 4.0),
                  Icon(Icons.arrow_right_alt_rounded),
                ],
              ),
            ),
            Spacer(flex: 20),
          ],
        ),
      ),
    );
  }
}
