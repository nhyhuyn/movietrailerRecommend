import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the same base URL defined in ApiService
  String get apiBaseUrl => ApiService.apiBaseUrl;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kiểm tra xem người dùng đã đăng nhập thành công chưa
      if (userCredential.user != null) {
        // Lấy thông tin người dùng từ Firebase
        User user = userCredential.user!;

        // Xác thực với backend bằng cách gửi thông tin người dùng
        final response = await http.post(
          Uri.parse('$apiBaseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firebase_uid': user.uid,
            'email': user.email,
            'display_name': user.displayName,
            'photo_url': user.photoURL,
          }),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          // Save token to SharedPreferences
          preferences.setString('auth_token', data['token']);
          authToken = data['token'];

          // Fetch user data from server
          await _fetchUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Sign In Successfully',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          );

          return userCredential;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Backend authentication failed: ${response.body}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          );
          return null;
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email!';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password you entered is wrong';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            errorMessage,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user!.updateDisplayName(name);
      User user = userCredential.user!;

      // Gửi thông tin người dùng đến server thay vì sử dụng idToken
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': user.uid,
          'name': name,
          'email': email,
          'display_name': name,
          'photo_url': user.photoURL,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Save token to SharedPreferences
        preferences.setString('auth_token', data['token']);
        preferences.setString('keyusername', name);
        authToken = data['token'];
        username = name;

        // // Sync current preferences to server
        // if (persistedGenres.isNotEmpty || persistedLanguages.isNotEmpty) {
        //   await ApiService.syncPreferencesToServer();
        // }

        // // Sync watchlist if any
        // if (remembermovies.isNotEmpty) {
        //   await ApiService.syncWatchlist();
        // }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Registered Successfully',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );

        return userCredential;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Backend registration failed: ${response.body}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
        // Delete Firebase account if backend registration fails
        await userCredential.user?.delete();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak!';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists with this email';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            errorMessage,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Remove token from SharedPreferences
      preferences.remove('auth_token');
      authToken = null;

      // Clear user data
      username = "";
      preferences.remove('keyusername');

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Fetch user data from server
  Future<void> _fetchUserData() async {
    if (authToken == null) return;

    try {
      // Get user information
      final userResponse = await http.get(
        Uri.parse('$apiBaseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (userResponse.statusCode == 200) {
        var userData = jsonDecode(userResponse.body);

        // Save username
        username = userData['name'] ?? "";
        preferences.setString('keyusername', username);

        // Use ApiService methods to fetch user data
        await ApiService.fetchPreferences();
        await ApiService.fetchWatchlist();
        // await ApiService.getRecommendations();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Check and restore session
  Future<bool> checkAndRestoreSession() async {
    try {
      String? token = preferences.getString('auth_token');

      if (token == null || token.isEmpty) {
        return false;
      }

      // Verify token validity
      final response = await http.get(
        Uri.parse('$apiBaseUrl/auth/verify'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        authToken = token;
        // Fetch user data using the stored token
        await _fetchUserData();
        return true;
      } else {
        // Token is invalid, remove from SharedPreferences
        preferences.remove('auth_token');
        authToken = null;
        return false;
      }
    } catch (e) {
      print('Error checking session: $e');
      return false;
    }
  }
}
