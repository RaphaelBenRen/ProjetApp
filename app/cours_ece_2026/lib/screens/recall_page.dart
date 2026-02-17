import 'package:flutter/material.dart';
import 'package:formation_flutter/model/recall.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class RecallPage extends StatelessWidget {
  const RecallPage({super.key, required this.recall});

  final Recall recall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappel produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: recall.pdfUrl != null ? () => _launchUrl(recall.pdfUrl!) : null,
            tooltip: recall.pdfUrl != null ? 'Ouvrir la fiche PDF' : 'Document non disponible',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (recall.imageUrl != null)
              Image.network(
                recall.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox(
                  height: 250,
                  child: Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              ),
            
            _SectionHeader(title: 'Dates de commercialisation'),
            _SectionContent(
              content:
                  'Du ${_formatDate(recall.dateDebutCommercialisation)} au ${_formatDate(recall.dateFinCommercialisation)}',
            ),

            _SectionHeader(title: 'Distributeurs'),
            _SectionContent(content: recall.distributeurs ?? 'Non spécifié'),

            _SectionHeader(title: 'Zone géographique'),
            _SectionContent(content: recall.zoneGeographique ?? 'Non spécifié'),

            _SectionHeader(title: 'Motif du rappel'),
            _SectionContent(content: recall.motifRappel ?? 'Non spécifié'),

             if (recall.risquesEncourus != null) ...[
              _SectionHeader(title: 'Risques encourus'),
              _SectionContent(content: recall.risquesEncourus!),
            ],

            if (recall.conduitesATenir != null) ...[
              _SectionHeader(title: 'Conduite à tenir'),
              _SectionContent(content: recall.conduitesATenir!),
            ],

            if (recall.infosComplementaires != null) ...[
              _SectionHeader(title: 'Informations complémentaires'),
              _SectionContent(content: recall.infosComplementaires!),
            ],
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {

    return dateStr ?? 'Inconnue';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.only(top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF171766),
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  final String content;
  const _SectionContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
