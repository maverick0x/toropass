import 'package:url_launcher/url_launcher.dart';

abstract class ToroPassWalletLauncher {
  Future<bool> canLaunch(Uri uri);

  Future<bool> launch(Uri uri);
}

class UrlLauncherToroPassWalletLauncher implements ToroPassWalletLauncher {
  const UrlLauncherToroPassWalletLauncher();

  @override
  Future<bool> canLaunch(Uri uri) => canLaunchUrl(uri);

  @override
  Future<bool> launch(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
