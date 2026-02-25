import 'package:pocketbase/pocketbase.dart';
import '../model/product.dart';

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService({String? url})
      : pb = PocketBase(url ?? 'http://127.0.0.1:8090');

  Future<void> saveScan(Product product) async {
    final user = pb.authStore.model as RecordModel?;
    print('DEBUG: saveScan - user ID: ${user?.id}');
    if (user == null) return;

    final body = {
      "user": user.id,
      "barcode": product.barcode,
      "product_name": product.name,
      "brand": product.brands?.join(', '),
      "image_url": product.picture,
      "nutriscore": product.nutriScore?.name,
    };

    try {
      print('DEBUG: saveScan - accessing collection "scans"');
      final existing = await pb.collection('scans').getList(
        filter: 'user = "${user.id}" && barcode = "${product.barcode}"',
        page: 1,
        perPage: 1,
      );

      if (existing.items.isEmpty) {
        await pb.collection('scans').create(body: body);
      } else {
        await pb.collection('scans').update(existing.items.first.id, body: body);
      }
    } catch (e) {
      print('Error saving scan: $e');
    }
  }

  Future<List<RecordModel>> getScans() async {
    final user = pb.authStore.model as RecordModel?;
    print('DEBUG: getScans - user ID: ${user?.id}');
    if (user == null) return [];
    try {
      print('DEBUG: getScans - accessing collection "scans" with filter: user = "${user.id}"');
      final result = await pb.collection('scans').getList(
        filter: 'user = "${user.id}"',
      );
      print('DEBUG: getScans - found ${result.items.length} records');
      return result.items;
    } catch (e) {
      print('DEBUG: Error getting scans: $e');
      return [];
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final user = pb.authStore.model as RecordModel?;
    if (user == null) return;

    try {
      print('DEBUG: toggleFavorite - accessing collection "favorites"');
      final existing = await pb.collection('favorites').getList(
        filter: 'user = "${user.id}" && barcode = "${product.barcode}"',
        page: 1,
        perPage: 1,
      );

      if (existing.items.isNotEmpty) {
        await pb.collection('favorites').delete(existing.items.first.id);
      } else {
        final body = {
          "user": user.id,
          "barcode": product.barcode,
          "product_name": product.name,
          "brand": product.brands?.join(', '),
          "image_url": product.picture,
          "nutriscore": product.nutriScore?.name,
        };
        await pb.collection('favorites').create(body: body);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<List<RecordModel>> getFavorites() async {
    final user = pb.authStore.model as RecordModel?;
    print('DEBUG: getFavorites - user ID: ${user?.id}');
    if (user == null) return [];

    try {
      print('DEBUG: getFavorites - accessing collection "favorites" with filter: user = "${user.id}"');
      final result = await pb.collection('favorites').getList(
        filter: 'user = "${user.id}"',
      );
      print('DEBUG: getFavorites - found ${result.items.length} records');
      return result.items;
    } catch (e) {
      print('DEBUG: Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String barcode) async {
    final user = pb.authStore.model as RecordModel?;
    if (user == null) return false;

    try {
      final existing = await pb.collection('favorites').getList(
        filter: "user = '${user.id}' && barcode = '$barcode'",
        page: 1,
        perPage: 1,
      );
      return existing.items.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}
