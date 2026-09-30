import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. เชื่อมต่อ Firebase (ไฟล์ firebase_options.dart สร้างจาก flutterfire configure)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. โหลดรูปแบบวันที่ภาษาไทย/อังกฤษ
  await initializeDateFormatting();

  // 3. โหลดการตั้งค่า (ธีม/ภาษา) ที่เก็บไว้ใน SharedPreferences
  final settings = SettingsProvider();
  await settings.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settings),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // เฝ้าดูการตั้งค่า ถ้าเปลี่ยนธีม/ภาษา แอปจะวาดใหม่ทันที
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Questly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(settings.isThai ? 'th' : 'en'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
      // Responsive (บทที่ 4): เมื่อเปิดบน Chrome จอกว้าง ให้แอปอยู่ตรงกลางกว้างไม่เกิน 480px เหมือนมือถือ
      builder: (context, child) {
        final isDark = settings.isDark;
        return Container(
          color: isDark ? Colors.black : const Color(0xFFE9EDF5),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        );
      },
      home: const SplashPage(),
    );
  }
}
