import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ScopeEntity extends Equatable {
  final String name;
  final String icon;
  final Color color;

  const ScopeEntity({
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [name, icon, color];
}
