import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ExtInt on int {
  SizedBox get verticalSpacer => SizedBox(height: toDouble().height);

  SizedBox get horizontalSpacer => SizedBox(width: toDouble().width);

  double get height => toDouble().h;

  double get width => toDouble().w;

  double get font => toDouble().sp;

  double get screenWidth => toDouble().sw;

  double get screenHeight => toDouble().sh;

  double get radius => toDouble().r;
}

extension ExtDouble on double {
  SizedBox get verticalSpacer => SizedBox(height: this);

  SizedBox get horizontalSpacer => SizedBox(width: this);

  double get height => h;

  double get width => w;

  double get font => sp;

  double get screenWidth => sw;

  double get screenHeight => sh;

  double get radius => r;
}
