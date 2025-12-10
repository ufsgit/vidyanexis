import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/audio_file_provider.dart';
import 'package:techtify/controller/check_in_out_provider.dart';
import 'package:techtify/controller/followup_reports_provider.dart';
import 'package:techtify/controller/form_builder_provider.dart';
import 'package:techtify/controller/notification_provider.dart';
import 'package:techtify/controller/quotation_report_provider.dart';
import 'package:techtify/presentation/pages/reports/quotation_report.dart';
import 'package:techtify/presentation/widgets/notification_overlay.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/amc_report_provider.dart';
import 'package:techtify/controller/attendance_report_provider.dart';
import 'package:techtify/controller/conversion_report_provider.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/customer_provider.dart';
import 'package:techtify/controller/dashboard_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/enquiry_report_provider.dart';
import 'package:techtify/controller/enquiry_source_provider.dart';
import 'package:techtify/controller/expense_provider.dart';
import 'package:techtify/controller/feedback_provider.dart';
import 'package:techtify/controller/feedback_report_provider.dart';
import 'package:techtify/controller/image_upload_provider.dart';
import 'package:techtify/controller/inovoice_report_provider.dart';
import 'package:techtify/controller/lead_details_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/login_controller.dart';
import 'package:techtify/controller/models/task_page_provider.dart';
import 'package:techtify/controller/process_flow_provider.dart';
import 'package:techtify/controller/reports_provider.dart';
import 'package:techtify/controller/service_report_provider.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/controller/task_report_provider.dart';
import 'package:techtify/controller/warrenty_report_provider.dart';
import 'package:techtify/controller/work_report_provider.dart';
import 'package:techtify/controller/work_summary_provider.dart';
import 'package:techtify/firebase_options.dart';
import 'package:techtify/routes/routes.dart';
import 'package:techtify/controller/side_bar_provider.dart';
import 'package:techtify/utils/firebase_notification_service.dart';

final GlobalKey<ScaffoldMessengerState> navigatorKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final notificationService = FirebaseNotificationService();
    await notificationService.initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => LeadsProvider()),
        ChangeNotifierProvider(create: (context) => DropDownProvider()),
        ChangeNotifierProvider(create: (context) => LeadDetailsProvider()),
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
        ChangeNotifierProvider(create: (context) => CustomerDetailsProvider()),
        ChangeNotifierProvider(create: (context) => ReportsProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (context) => TaskReportProvider()),
        ChangeNotifierProvider(create: (context) => TaskPageProvider()),
        ChangeNotifierProvider(create: (context) => ServiceReportProvider()),
        ChangeNotifierProvider(create: (context) => AMCReportProvider()),
        ChangeNotifierProvider(create: (context) => ConversionReportProvider()),
        ChangeNotifierProvider(create: (context) => WorkSummaryProvider()),
        ChangeNotifierProvider(create: (context) => WorkReportProvider()),
        ChangeNotifierProvider(create: (context) => InvoiceReportProvider()),
        ChangeNotifierProvider(create: (context) => AttendanceReportProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => FeedbackProvider()),
        ChangeNotifierProvider(create: (context) => FeedbackReportProvider()),
        ChangeNotifierProvider(create: (context) => WarrentyReportProvider()),
        ChangeNotifierProvider(create: (context) => FollowupReportsProvider()),
        ChangeNotifierProvider(create: (context) => QuotationReportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => EnquirySourceProvider()),
        ChangeNotifierProvider(create: (_) => EnquiryReportProvider()),
        ChangeNotifierProvider(create: (_) => ProcessFlowProvider()),
        ChangeNotifierProvider(create: (_) => CheckInOutProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FormBuilderProvider()),
        ChangeNotifierProvider(create: (context) => AudioFileProvider()),

        
        ChangeNotifierProvider(
          create: (_) => SidebarProvider(),
          child: const MyApp(),
        ),
      ],
      child: MaterialApp.router(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        scaffoldMessengerKey: navigatorKey,
        color:  const Color.fromARGB(255, 0, 90, 69),
        title: '${AppStyles.name()} Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor:   const Color.fromARGB(255, 0, 90, 69),),
          useMaterial3: true,
          fontFamily: 'PlusJakartaSans',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
            bodyMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
            bodySmall: TextStyle(fontFamily: 'PlusJakartaSans'),
            labelLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
            labelMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
            labelSmall: TextStyle(fontFamily: 'PlusJakartaSans'),
            titleLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
            titleMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
            titleSmall: TextStyle(fontFamily: 'PlusJakartaSans'),
            displayLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
            displayMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
            displaySmall: TextStyle(fontFamily: 'PlusJakartaSans'),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
