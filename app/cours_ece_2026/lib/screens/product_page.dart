import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';

import 'package:provider/provider.dart';
import 'package:formation_flutter/providers/recall_fetcher.dart';
import 'package:formation_flutter/widgets/product_recall_banner.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  static const double IMAGE_HEIGHT = 300.0;
  final Product product = Product(
    barcode: '3383883752028',
    name: 'Coulommiers au lait cru',
    brands: ['Franprix', 'Société Fromagère de la Brie'],
    picture:
        'https://images.openfoodfacts.org/images/products/338/388/375/2028/front_fr.30.400.jpg',
    nutriScore: ProductNutriScore.D,
    novaScore: ProductNovaScore.group3,
    greenScore: ProductGreenScore.C,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecallFetcher>().checkProduct('3383883752028');
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: IMAGE_HEIGHT,
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
                  const Scores(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Scores extends StatelessWidget {
  const Scores({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                flex: 44,
                child: _Nutriscore(nutriscore: ProductNutriScore.B),
              ),
              VerticalDivider(),
              Expanded(
                flex: 56,
                child: _NovaGroup(novaScore: ProductNovaScore.group4),
              ),
            ],
          ),
        ),
        Divider(),
        _GreenScore(greenScore: ProductGreenScore.A),
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
        Image.asset(_findAssetName(), height: 42.0),
      ],
    );
  }

  String _findAssetName() {
    return switch (nutriscore) {
      ProductNutriScore.A => 'res/drawables/nutriscore_a.png',
      ProductNutriScore.B => 'res/drawables/nutriscore_b.png',
      ProductNutriScore.C => 'res/drawables/nutriscore_c.png',
      ProductNutriScore.D => 'res/drawables/nutriscore_d.png',
      ProductNutriScore.E => 'res/drawables/nutriscore_e.png',
      ProductNutriScore.unknown => 'TODO',
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
