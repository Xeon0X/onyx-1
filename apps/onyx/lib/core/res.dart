import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

part 'generated/res.g.dart';

class Res {
  static Duration get animationDuration => const Duration(milliseconds: 300);

  static double get bottomNavBarItemWidth => 20.w;

  static double get bottomNavBarHeight =>
      (Device.orientation == Orientation.portrait) ? 10.h : 5.w;

  static double get topBarHeight => (Device.orientation == Orientation.portrait)
      ? bottomNavBarHeight
      : bottomNavBarHeight * 1.5;

  static bool get isPhone {
    return ((isPortrait && Device.width <= 599) ||
        (isLandscape && Device.height <= 599));
  }

  static bool get isWide => Device.width >= 600;

  static bool get isPortrait => Device.orientation == Orientation.portrait;

  static bool get isLandscape => Device.orientation == Orientation.landscape;

  static bool mock = false;

  static const String corsProxy = "https://192.168.220.102:3000/";

  static const String ivPath = "assets/iv.txt";
  static const String keyPath = "assets/key.txt";
  static const String agendaIdsPath = "assets/agenda_ids.json.enc";

  static const String colloscopeIdsPath = "assets/colloscope_ids.enc";

  static const Duration agendaDayStart = Duration(hours: 6);
  static const Duration agendaDayEnd = Duration(hours: 22);
  static const Duration agendaDayDuration = Duration(
      hours: 16); // be careful to change this value accordingly to the previous
// 22 - 6 = 16

  static final logger = Logger(
    level: (kDebugMode) ? Level.all : Level.fatal,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
}

@HiveType(typeId: 18)
enum Functionalities {
  @HiveField(0)
  tomuss,
  @HiveField(1)
  agenda,
  @HiveField(2)
  mail,
  @HiveField(3)
  map,
  @HiveField(4)
  izly,
  @HiveField(5)
  settings,
  @HiveField(6)
  colloscope,
}
