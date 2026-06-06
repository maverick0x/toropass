import 'package:equatable/equatable.dart';

class OAuthAuthorizeResultEntity extends Equatable {
  final String? code;

  const OAuthAuthorizeResultEntity({this.code});

  @override
  List<Object?> get props => [code];
}
