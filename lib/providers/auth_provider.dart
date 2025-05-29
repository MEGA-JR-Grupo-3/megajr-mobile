import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isAuthenticated = false;
  String? _firebaseIdToken;
  String _registeredName = "";
  bool _isAuthDataLoaded = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get firebaseIdToken => _firebaseIdToken;
  String get registeredName => _registeredName;
  bool get isAuthDataLoaded => _isAuthDataLoaded;

  final String _backendUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://megajr-back-end.onrender.com/api',
  );

  AuthProvider() {
    _auth.authStateChanges().listen((User? currentUser) async {
      _user = currentUser;
      _isAuthenticated = currentUser != null;
      if (currentUser != null) {
        try {
          _firebaseIdToken = await currentUser.getIdToken();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _firebaseIdToken!);
          await _fetchUserData();
        } catch (e) {
          await _auth.signOut();
        }
      } else {
        _firebaseIdToken = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt_token');
        _registeredName = "";
        _isAuthDataLoaded = true;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user == null || _firebaseIdToken == null) {
      _isAuthDataLoaded = true;
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/user-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_firebaseIdToken',
        },
        body: json.encode({'email': _user!.email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _registeredName = data['name'] ?? '';
      } else {
        _registeredName = "";
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _auth.signOut();
        }
      }
    } catch (e) {
      _registeredName = "";
    } finally {
      _isAuthDataLoaded = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
