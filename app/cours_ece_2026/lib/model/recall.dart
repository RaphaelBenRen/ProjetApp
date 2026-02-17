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
    return Recall(
      id: json['id'] as String,
      identificationProduits: json['identification_produits'] as String,
      libelle: json['libelle'] as String?,
      motifRappel: json['motif_rappel'] as String?,
      risquesEncourus: json['risques_encourus'] as String?,
      conduitesATenir:
          json['conduites_a_tenir_par_le_consommateur'] as String?,
      imageUrl: json['liens_vers_les_images'] as String?,
      pdfUrl: json['lien_vers_affichette_pdf'] as String?,
      dateDebutCommercialisation: json['date_debut_commercialisation'] as String?,
      dateFinCommercialisation: json['date_date_fin_commercialisation'] as String?,
      distributeurs: json['distributeurs'] as String?,
      zoneGeographique: json['zone_geographique_de_vente'] as String?,
      infosComplementaires: json['informations_complementaires'] as String?,
    );
  }
}
