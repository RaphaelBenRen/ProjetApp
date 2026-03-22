import 'package:flutter/material.dart';
import 'package:formation_flutter/model/recall.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/widgets/cors_image.dart';
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
            onPressed: recall.pdfUrl != null && recall.pdfUrl!.isNotEmpty ? () => _launchUrl(recall.pdfUrl!) : null,
            tooltip: recall.pdfUrl != null && recall.pdfUrl!.isNotEmpty ? 'Ouvrir la fiche PDF' : 'Document non disponible',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isValid(recall.imageUrl)) ...[
              CorsImage(
                url: recall.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) {
                  return SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('Image non disponible',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 10)
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            
            if (_isValid(recall.dateDebutCommercialisation) || _isValid(recall.dateFinCommercialisation)) ...[
              _SectionHeader(title: 'Dates de commercialisation'),
              _SectionContent(
                content:
                    'Du ${_formatDate(recall.dateDebutCommercialisation)} au ${_formatDate(recall.dateFinCommercialisation)}',
              ),
            ],

            if (_isValid(recall.distributeurs)) ...[
              _SectionHeader(title: 'Distributeurs'),
              _SectionContent(content: recall.distributeurs!),
            ],

            if (_isValid(recall.zoneGeographique)) ...[
              _SectionHeader(title: 'Zone géographique'),
              _SectionContent(content: recall.zoneGeographique!),
            ],

            if (_isValid(recall.motifRappel)) ...[
              _SectionHeader(title: 'Motif du rappel'),
              _SectionContent(content: recall.motifRappel!),
            ],

             if (_isValid(recall.risquesEncourus)) ...[
              _SectionHeader(title: 'Risques encourus'),
              _SectionContent(content: recall.risquesEncourus!),
            ],

            if (_isValid(recall.conduitesATenir)) ...[
              _SectionHeader(title: 'Conduite à tenir'),
              _SectionContent(content: recall.conduitesATenir!),
            ],

            if (_isValid(recall.infosComplementaires)) ...[
              _SectionHeader(title: 'Informations complémentaires'),
              _SectionContent(content: recall.infosComplementaires!),
            ],
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  bool _isValid(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.toLowerCase() == 'null' || trimmed.toLowerCase() == 'non spécifié') return false;
    
    // Check for empty HTML tags if it's from the editor
    final cleanTags = trimmed.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (cleanTags.isEmpty && trimmed.contains('<')) return false;

    return true;
  }

  String _formatDate(String? dateStr) {
    if (!_isValid(dateStr)) return 'Inconnue';
    return dateStr!;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
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
