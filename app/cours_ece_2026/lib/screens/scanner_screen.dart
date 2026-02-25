import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:formation_flutter/screens/product_page.dart';
import 'package:formation_flutter/services/product_service.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:provider/provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isScanning = false;
        });

        // Fetch product info
        final productService = ProductService();
        final productData = await productService.getProduct(code);

        if (mounted) {
          if (productData != null) {
            final product = Product.fromJson(productData);
            // Save scan to history
            await context.read<PocketBaseService>().saveScan(product);

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProductPage(
                    productData: productData,
                    barcode: code,
                  ),
                ),
              );
            }
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Produit non trouvé sur Open Food Facts")),
            );
             setState(() {
              _isScanning = true;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un produit"),
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }
}
