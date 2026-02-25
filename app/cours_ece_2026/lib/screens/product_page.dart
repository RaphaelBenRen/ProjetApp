import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';

import 'package:formation_flutter/services/pocketbase_service.dart';
import 'package:formation_flutter/services/product_service.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/providers/recall_fetcher.dart';
import 'package:formation_flutter/widgets/product_recall_banner.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String barcode;

  const ProductPage({
    super.key,
    this.productData,
    required this.barcode,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  static const double IMAGE_HEIGHT = 300.0;
  late Product product;
  bool _isFavorite = false;
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (widget.productData != null) {
      product = Product.fromJson(widget.productData!);
      setState(() {
        _isLoading = false;
      });
    } else {
      final productService = context.read<ProductService>();
      final data = await productService.getProduct(widget.barcode);
      if (mounted) {
        if (data != null) {
          setState(() {
            product = Product.fromJson(data);
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible de charger les données du produit")),
          );
        }
      }
    }

    _checkFavorite();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecallFetcher>().checkProduct(widget.barcode);
    });
  }

  Future<void> _checkFavorite() async {
    final isFav = await context.read<PocketBaseService>().isFavorite(widget.barcode);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await context.read<PocketBaseService>().toggleFavorite(product);
    _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: IMAGE_HEIGHT,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? AppColors.yellow : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.picture ??
                    'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=1310&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.0),
                ),
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Produit inconnu',
                    style: context.theme.title1,
                  ),
                  Text(
                    product.brands?.join(", ") ?? 'Marque inconnue',
                    style: context.theme.title2,
                  ),
                  
                  // Recall Banner
                  Consumer<RecallFetcher>(
                    builder: (context, fetcher, child) {
                      if (fetcher.recalls.isNotEmpty) {
                        return ProductRecallBanner(recall: fetcher.recalls.first);
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 10),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Fiche'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Caractéristiques'),
          BottomNavigationBarItem(icon: Icon(Icons.spa_outlined), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_on), label: 'Tableau'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildFicheTab();
      case 1: return _buildFeaturesTab();
      case 2: return _buildNutritionTab();
      case 3: return _buildTableTab();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildFicheTab() {
    return Column(
      children: [
        Scores(product: product),
        const SizedBox(height: 20),
        _RowInfo(label: 'Quantité', value: product.quantity ?? 'Inconnue'),
        _RowInfo(label: 'Vendu', value: 'France'),
      ],
    );
  }

  Widget _buildFeaturesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Ingrédients'),
        if (product.ingredients != null)
           ...product.ingredients!.map((ing) => Padding(
             padding: const EdgeInsets.symmetric(vertical: 4),
             child: Text(ing),
           )).toList()
        else
          const Text('Données non disponibles'),
        
        const SizedBox(height: 20),
        _SectionHeader(title: 'Substances allergènes'),
        Text(product.allergens?.join(', ') ?? 'Aucune'),

        const SizedBox(height: 20),
        _SectionHeader(title: 'Additifs'),
        if (product.additives != null && product.additives!.isNotEmpty)
          ...product.additives!.values.map((val) => Text(val)).toList()
        else
          const Text('Aucune'),
      ],
    );
  }

  Widget _buildNutritionTab() {
    final levels = product.nutrientLevels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repères nutritionnels pour 100g', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        _NutritionLevelRow(
          label: 'Matières grasses / lipides',
          value: '${product.nutritionFacts?.fat?.per100g ?? 0}g',
          level: levels?.fat,
        ),
        _NutritionLevelRow(
          label: 'Acides gras saturés',
          value: '${product.nutritionFacts?.saturatedFat?.per100g ?? 0}g',
          level: levels?.saturatedFat,
        ),
        _NutritionLevelRow(
          label: 'Sucres',
          value: '${product.nutritionFacts?.sugar?.per100g ?? 0}g',
          level: levels?.sugars,
        ),
        _NutritionLevelRow(
          label: 'Sel',
          value: '${product.nutritionFacts?.salt?.per100g ?? 0}g',
          level: levels?.salt,
        ),
      ],
    );
  }

  Widget _buildTableTab() {
    final facts = product.nutritionFacts;
    return Table(
      border: const TableBorder(horizontalInside: BorderSide(color: Colors.grey, width: 0.2)),
      children: [
        const TableRow(children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('')),
          Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Pour 100g', style: TextStyle(fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Par part', style: TextStyle(fontWeight: FontWeight.bold))),
        ]),
        _buildTableRow('Énergie', '${facts?.energy?.per100g ?? "?"} kj', '${facts?.energy?.perServing ?? "?"}'),
        _buildTableRow('Matières grasses', '${facts?.fat?.per100g ?? "?"} g', '${facts?.fat?.perServing ?? "?"}'),
        _buildTableRow('dont Acides gras saturés', '${facts?.saturatedFat?.per100g ?? "?"} g', '${facts?.saturatedFat?.perServing ?? "?"}'),
        _buildTableRow('Glucides', '${facts?.carbohydrate?.per100g ?? "?"} g', '${facts?.carbohydrate?.perServing ?? "?"}'),
        _buildTableRow('dont Sucres', '${facts?.sugar?.per100g ?? "?"} g', '${facts?.sugar?.perServing ?? "?"}'),
        _buildTableRow('Fibres alimentaires', '${facts?.fiber?.per100g ?? "?"} g', '${facts?.fiber?.perServing ?? "?"}'),
        _buildTableRow('Protéines', '${facts?.proteins?.per100g ?? "?"} g', '${facts?.proteins?.perServing ?? "?"}'),
        _buildTableRow('Sel', '${facts?.salt?.per100g ?? "?"} g', '${facts?.salt?.perServing ?? "?"}'),
        _buildTableRow('Sodium', '${facts?.sodium?.per100g ?? "?"} g', '${facts?.sodium?.perServing ?? "?"}'),
      ],
    );
  }

  TableRow _buildTableRow(String label, String per100, String perServing) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(label)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(per100)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(perServing)),
    ]);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2652))),
    );
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;
  const _RowInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}

class _NutritionLevelRow extends StatelessWidget {
  final String label;
  final String value;
  final String? level;

  const _NutritionLevelRow({required this.label, required this.value, this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (level?.toLowerCase()) {
      case 'low':
        color = Colors.green;
        text = 'Faible quantité';
        break;
      case 'moderate':
        color = Colors.orange;
        text = 'Quantité modérée';
        break;
      case 'high':
        color = Colors.red;
        text = 'Quantité élevée';
        break;
      default:
        color = Colors.grey;
        text = 'Inconnu';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(text, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class Scores extends StatelessWidget {
  final Product product;
  const Scores({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 44,
                child: _Nutriscore(nutriscore: product.nutriScore ?? ProductNutriScore.unknown),
              ),
              const VerticalDivider(),
              Expanded(
                flex: 56,
                child: _NovaGroup(novaScore: product.novaScore ?? ProductNovaScore.unknown),
              ),
            ],
          ),
        ),
        const Divider(),
        _GreenScore(greenScore: product.greenScore ?? ProductGreenScore.unknown),
      ],
    );
  }
}

class _Nutriscore extends StatelessWidget {
  const _Nutriscore({required this.nutriscore});

  final ProductNutriScore nutriscore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.nutriscore,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        if (_findAssetName() != null)
          Image.asset(_findAssetName()!, height: 42.0),
      ],
    );
  }

  String? _findAssetName() {
    return switch (nutriscore) {
      ProductNutriScore.A => 'res/drawables/nutriscore_a.png',
      ProductNutriScore.B => 'res/drawables/nutriscore_b.png',
      ProductNutriScore.C => 'res/drawables/nutriscore_c.png',
      ProductNutriScore.D => 'res/drawables/nutriscore_d.png',
      ProductNutriScore.E => 'res/drawables/nutriscore_e.png',
      ProductNutriScore.unknown => null,
    };
  }
}

class _NovaGroup extends StatelessWidget {
  const _NovaGroup({required this.novaScore});

  final ProductNovaScore novaScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.nova_group,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        Text(_findLabel(), style: const TextStyle(color: AppColors.grey2)),
      ],
    );
  }

  String _findLabel() {
    return switch (novaScore) {
      ProductNovaScore.group1 =>
        'Aliments non transformés ou transformés minimalement',
      ProductNovaScore.group2 => 'Ingrédients culinaires transformés',
      ProductNovaScore.group3 => 'Aliments transformés',
      ProductNovaScore.group4 =>
        'Produits alimentaires et boissons ultra-transformés',
      ProductNovaScore.unknown => 'Score non calculé',
    };
  }
}

class _GreenScore extends StatelessWidget {
  const _GreenScore({required this.greenScore});

  final ProductGreenScore greenScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.greenscore,
          style: context.theme.title3,
        ),
        const SizedBox(height: 5.0),
        Row(
          children: <Widget>[
            Icon(_findIcon(), color: _findIconColor()),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                _findLabel(),
                style: const TextStyle(color: AppColors.grey2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _findIcon() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppIcons.ecoscore_a_plus,
      ProductGreenScore.A => AppIcons.ecoscore_a,
      ProductGreenScore.B => AppIcons.ecoscore_b,
      ProductGreenScore.C => AppIcons.ecoscore_c,
      ProductGreenScore.D => AppIcons.ecoscore_d,
      ProductGreenScore.E => AppIcons.ecoscore_e,
      ProductGreenScore.F => AppIcons.ecoscore_f,
      ProductGreenScore.unknown => AppIcons.ecoscore_e,
    };
  }

  Color _findIconColor() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppColors.greenScoreAPlus,
      ProductGreenScore.A => AppColors.greenScoreA,
      ProductGreenScore.B => AppColors.greenScoreB,
      ProductGreenScore.C => AppColors.greenScoreC,
      ProductGreenScore.D => AppColors.greenScoreD,
      ProductGreenScore.E => AppColors.greenScoreE,
      ProductGreenScore.F => AppColors.greenScoreF,
      ProductGreenScore.unknown => Colors.transparent,
    };
  }

  String _findLabel() {
    return switch (greenScore) {
      ProductGreenScore.APlus => 'Très faible impact environnemental',
      ProductGreenScore.A => 'Très faible impact environnemental',
      ProductGreenScore.B => 'Faible impact environnemental',
      ProductGreenScore.C => "Impact modéré sur l'environnement",
      ProductGreenScore.D => 'Impact environnemental élevé',
      ProductGreenScore.E => 'Impact environnemental très élevé',
      ProductGreenScore.F => 'Impact environnemental très élevé',
      ProductGreenScore.unknown => 'Score non calculé',
    };
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
