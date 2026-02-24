import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/model/recall.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';

class RecallFetcher extends ChangeNotifier {
  final PocketBaseService _pbService;
  

  RecallFetcher(this._pbService); 

  List<Recall> _recalls = [];
  bool _isLoading = false;
  String? _error;

  List<Recall> get recalls => _recalls;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> checkProduct(String gtin) async {
    _isLoading = true;
    _error = null;
    _recalls = [];
    notifyListeners();

    try {

      final resultList = await _pbService.pb.collection('rappels').getList(
        page: 1,
        perPage: 50,
        filter: 'identification_produits ~ "$gtin"',
      );

      _recalls = resultList.items.map((item) {

          return Recall.fromJson(item.toJson());
      }).toList();

    } catch (e) {
      _error = e.toString();

      _recalls = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
