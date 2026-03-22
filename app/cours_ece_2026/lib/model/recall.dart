class Recall {
  final String id;
  final String identificationProduits;
  final String? libelle;
  final String? motifRappel;
  final String? risquesEncourus;
  final String? conduitesATenir;
  final String? imageUrl;
  final String? pdfUrl;
  final String? dateDebutCommercialisation;
  final String? dateFinCommercialisation;
  final String? distributeurs;
  final String? zoneGeographique;
  final String? infosComplementaires;

  Recall({
    required this.id,
    required this.identificationProduits,
    this.libelle,
    this.motifRappel,
    this.risquesEncourus,
    this.conduitesATenir,
    this.imageUrl,
    this.pdfUrl,
    this.dateDebutCommercialisation,
    this.dateFinCommercialisation,
    this.distributeurs,
    this.zoneGeographique,
    this.infosComplementaires,
  });

  factory Recall.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Recall JSON: $json');
    String? rawImageUrl = json['liens_vers_les_images'] as String?;
    print('DEBUG: rawImageUrl: $rawImageUrl');
    String? firstImageUrl;
    if (rawImageUrl != null && rawImageUrl.trim().isNotEmpty) {
      // Split by space/newline in case there are multiple URLs
      final urls = rawImageUrl.trim().split(RegExp(r'\s+'));
      if (urls.isNotEmpty) {
        firstImageUrl = urls.first;
        print('DEBUG: firstImageUrl: $firstImageUrl');
      }
    }

    return Recall(
      id: json['id']?.toString() ?? '',
      identificationProduits: json['identification_produits']?.toString() ?? '',
      libelle: json['libelle']?.toString(),
      motifRappel: json['motif_rappel']?.toString(),
      risquesEncourus: json['risques_encourus']?.toString(),
      conduitesATenir: json['conduites_a_tenir_par_le_consommateur']?.toString(),
      imageUrl: firstImageUrl,
      pdfUrl: json['lien_vers_affichette_pdf']?.toString(),
      dateDebutCommercialisation: json['date_debut_commercialisation']?.toString(),
      dateFinCommercialisation: json['date_date_fin_commercialisation']?.toString(),
      distributeurs: json['distributeurs']?.toString(),
      zoneGeographique: json['zone_geographique_de_vente']?.toString(),
      infosComplementaires: json['informations_complementaires']?.toString(),
    );
  }
}
