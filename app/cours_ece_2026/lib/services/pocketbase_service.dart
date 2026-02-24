import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService({String? url})
      : pb = PocketBase(url ?? 'http://127.0.0.1:8090');
}
