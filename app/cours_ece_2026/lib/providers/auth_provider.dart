import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';

class AuthProvider extends ChangeNotifier {
  final PocketBaseService _pbService;
  RecordModel? _user;

  AuthProvider(this._pbService) {
    _user = _pbService.pb.authStore.model as RecordModel?;
    
    _pbService.pb.authStore.onChange.listen((event) {
      _user = event.model as RecordModel?;
      notifyListeners();
    });
  }

  RecordModel? get user => _user;
  bool get isAuthenticated => _pbService.pb.authStore.isValid;

  Future<void> signIn(String email, String password) async {
    try {
      await _pbService.pb.collection('users').authWithPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "passwordConfirm": password,
      };
      await _pbService.pb.collection('users').create(body: body);
      // Auto login after signup
      await signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    _pbService.pb.authStore.clear();
  }
}
