import 'package:equatable/equatable.dart';

class TnsEntity extends Equatable {
  final String? message;
  final String? username;
  final bool? isAvailable;

  const TnsEntity({this.username, this.message, this.isAvailable});

  @override
  List<Object?> get props => [username, message, isAvailable];
}
