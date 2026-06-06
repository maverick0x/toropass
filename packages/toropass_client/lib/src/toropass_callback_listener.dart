import 'package:app_links/app_links.dart';

abstract class ToroPassCallbackListener {
  Stream<Uri> get uriStream;
}

class AppLinksToroPassCallbackListener implements ToroPassCallbackListener {
  final AppLinks _appLinks;

  AppLinksToroPassCallbackListener({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;
}
