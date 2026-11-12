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

            // 跟随系统时浅色用绿色、深色用同一套绿色；手动深色仍用原有红色方案。
            darkTheme: _fitnessTheme(
              dark: true,
              scheme: box.read('mode') == 'dark'
                  ? FlexScheme.mandyRed
                  : FlexScheme.greenM3,
            ),

            /// 卡片、顶栏和底栏的圆角与留白在 _fitnessTheme 里统一收过。
            theme: box.read('mode') == 'dark'
                ? _fitnessTheme(dark: true, scheme: FlexScheme.mandyRed)
                : box.read('mode') == 'light'
                ? _fitnessTheme(dark: false, scheme: FlexScheme.aquaBlue)
                : _fitnessTheme(dark: false, scheme: FlexScheme.greenM3),
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

/// 在现有 Flex 配色上收一版界面：浅底、无阴影顶栏、圆角卡片。
ThemeData _fitnessTheme({required bool dark, required FlexScheme scheme}) {
  final base = dark
      ? FlexThemeData.dark(scheme: scheme, useMaterial3: false)
      : FlexThemeData.light(scheme: scheme, useMaterial3: false);
  final primary = base.colorScheme.primary;
  final bar = dark ? const Color(0xFF1A2420) : Colors.white;
  final canvas = dark ? const Color(0xFF101614) : const Color(0xFFF3F6F4);

  return base.copyWith(
    scaffoldBackgroundColor: canvas,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: primary,
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
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 2,
      highlightElevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bar,
      selectedItemColor: primary,
      unselectedItemColor: dark
          ? const Color(0xFF9AA59E)
          : const Color(0xFF8A938C),
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: dark ? const Color(0xFF2A3330) : const Color(0xFFE3EAE4),
      thickness: 1,
      space: 1,
    ),
  );
}
