import 'package:bot_toast/bot_toast.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';
import '../models/cus_app_localizations.dart';
import '../services/app_restart_service.dart';
import 'splash_screen.dart';

class FreeFitnessApp extends StatefulWidget {
  const FreeFitnessApp({super.key});

  @override
  State<FreeFitnessApp> createState() => _FreeFitnessAppState();
}

class _FreeFitnessAppState extends State<FreeFitnessApp> {
  // 应用程序的根部件
  @override
  Widget build(BuildContext context) {
    // debugPrint("getUserId--${box.read(LocalStorageKey.userId)}");
    // debugPrint("language--${box.read('language')}; mode--${box.read('mode')}");

    return AppRestartWrapper(
      child: ScreenUtilInit(
        designSize: const Size(360, 640), // 1080p / 3 ,单位dp
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, widget) {
          return MaterialApp(
            // 显示右上角 Debug 标识：仅 debug 构建可见，用于与正式签名包肉眼区分
            // （2026-08-27 曾因 debug 包装作正式版残留手机导致覆盖安装失败，故恢复此标识）
            debugShowCheckedModeBanner: true,
            title: 'free_fitness',
            onGenerateTitle: (context) {
              return CusAL.of(context).appTitle;
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              // form builder表单验证的多国语言
              FormBuilderLocalizations.delegate,
              // flutter_quill多国语言
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CH'),
              Locale('en', 'US'),
              ...FormBuilderLocalizations.supportedLocales,
            ],

            // locale: null,
            // locale: const Locale('en'),
            locale: box.read('language') == 'system'
                ? null
                : Locale(box.read('language')),

            // theme: ThemeData(
            //   primarySwatch: Colors.blue,
            //   // ？？？2023-11-22：升级到flutter 3.16 之后默认为true，现在还没有兼容修改部件，后续再启用
            //   useMaterial3: false,
            //   appBarTheme: AppBarTheme(
            //     color: Colors.blue,
            //     iconTheme: const IconThemeData(color: Colors.white),
            //     titleTextStyle: TextStyle(fontSize: 20.sp),
            //   ),
            // ),

            // 浅色是陶土色，深色是同一套颜色的夜间版。手动深浅只切换明暗。
            darkTheme: _fitnessTheme(dark: true),
            theme: _fitnessTheme(dark: box.read('mode') == 'dark'),
            // 1. call BotToastInit
            builder: (context, child) {
              child = BotToastInit()(context, child ?? Container());
              return child;
            },
            // 2. registered route observer
            navigatorObservers: [BotToastNavigatorObserver()],

            // 使用了initalRoute就不能使用home了，参看文档：
            // https://flutter.cn/docs/cookbook/navigation/named-routes#2-define-the-routes
            // 使用SplashScreen作为入口，所有初始化在其中完成
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

/// 陶土色主题：浅底暖纸，主色是深陶土，深色模式用同一套颜色压暗。
ThemeData _fitnessTheme({required bool dark}) {
  const lightPrimary = Color(0xFF8C4032);
  const darkPrimary = Color(0xFFE7B2A4);
  final colors = dark
      ? const FlexSchemeColor(
          primary: darkPrimary,
          primaryContainer: Color(0xFF5C2E26),
          secondary: Color(0xFFD7C4B8),
          secondaryContainer: Color(0xFF3A2C28),
          tertiary: Color(0xFFE2C089),
        )
      : const FlexSchemeColor(
          primary: lightPrimary,
          primaryContainer: Color(0xFFF4D7CE),
          secondary: Color(0xFF3E4A5C),
          secondaryContainer: Color(0xFFD9E0EA),
          tertiary: Color(0xFFC48A3A),
        );
  final base = dark
      ? FlexThemeData.dark(colors: colors, useMaterial3: false)
      : FlexThemeData.light(colors: colors, useMaterial3: false);
  final primary = dark ? darkPrimary : lightPrimary;
  final bar = dark ? const Color(0xFF241C19) : Colors.white;
  final canvas = dark ? const Color(0xFF161311) : const Color(0xFFF7F2EC);
  final appBar = dark ? const Color(0xFF2C211E) : lightPrimary;

  return base.copyWith(
    scaffoldBackgroundColor: canvas,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: appBar,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: bar,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      highlightElevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bar,
      selectedItemColor: primary,
      unselectedItemColor: dark
          ? const Color(0xFFB3A69C)
          : const Color(0xFF8E847C),
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: dark ? const Color(0xFF3A302C) : const Color(0xFFE8DFD6),
      thickness: 1,
      space: 1,
    ),
  );
}
