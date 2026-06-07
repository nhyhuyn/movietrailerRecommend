// lib/screens/auth/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Authentication/SignIn.dart';
import 'package:movie_app/Authentication/services/AuthService.dart';
import 'package:movie_app/Navigation/Navigation.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/GenreSelection.dart';
import 'package:movie_app/main.dart'; // Import for accessing preferences

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _hasPreferences = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Check if user has saved preferences
  Future<void> _checkUserStatus() async {
    final User? user = _authService.currentUser;

    if (user != null) {
      // Try to restore session and check if user has preferences
      final bool sessionRestored = await _authService.checkAndRestoreSession();

      if (sessionRestored) {
        // Check if the user has already selected genres
        setState(() {
          _hasPreferences = persistedGenres.isNotEmpty;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking user status
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // If the user is authenticated
        if (snapshot.hasData) {
          // If user has preferences, go to homepage
          if (_hasPreferences) {
            return MyHomePage();
          } else {
            // If user doesn't have preferences, go to genre selection
            return const GenreSelection();
          }
        }

        // If the user is not authenticated, show the SignIn screen
        return const SignIn();
      },
    );
  }
}
