import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/check_in_out_provider.dart';
import 'package:vidyanexis/controller/followup_reports_provider.dart';
import 'package:vidyanexis/controller/form_builder_provider.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/controller/quotation_report_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report.dart';
import 'package:vidyanexis/presentation/widgets/notification_overlay.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/amc_report_provider.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/conversion_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/enquiry_report_provider.dart';
import 'package:vidyanexis/controller/enquiry_source_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/feedback_provider.dart';
import 'package:vidyanexis/controller/feedback_report_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/inovoice_report_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/login_controller.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/process_flow_provider.dart';
import 'package:vidyanexis/controller/reports_provider.dart';
import 'package:vidyanexis/controller/service_report_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/time_track_report_provider.dart';
import 'package:vidyanexis/controller/work_report_provider.dart';
import 'package:vidyanexis/controller/work_summary_provider.dart';
import 'package:vidyanexis/firebase_options.dart';
import 'package:vidyanexis/routes/routes.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/utils/firebase_notification_service.dart';

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
        ChangeNotifierProvider(create: (context) => TimeTrackReportProvider()),
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
        color: const Color.fromARGB(255, 0, 90, 69),
        title: '${AppStyles.name()} Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 90, 69),
          ),
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
