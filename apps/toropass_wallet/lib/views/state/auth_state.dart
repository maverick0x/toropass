import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final authProvider = ChangeNotifierProvider<AuthState>((ref) => AuthState());

class AuthState extends ChangeNotifier {
  AuthState();

  @override
  String toString() {
    return 'AuthState';
  }
}
