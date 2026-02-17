import 'package:flutter/material.dart';
import 'package:formation_flutter/model/recall.dart';
import 'package:formation_flutter/screens/recall_page.dart';

class ProductRecallBanner extends StatelessWidget {
  final Recall recall;

  const ProductRecallBanner({super.key, required this.recall});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecallPage(recall: recall),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // Background #FF0000 with 36% opacity
          color: const Color(0xFFFF0000).withOpacity(0.36),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Ce produit fait l'objet d'un rappel produit",
                style: TextStyle(
                  // Foreground #A60000 with 100% opacity
                  color: const Color(0xFFA60000),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFFA60000),
            ),
          ],
        ),
      ),
    );
  }
}
