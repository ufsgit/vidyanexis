import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/pages/feedback/feeback.dart';
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/home_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';
import 'package:vidyanexis/presentation/pages/login/login_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/login/splash_screen.dart';
import 'package:vidyanexis/presentation/pages/login/company_code_page.dart';
import 'package:vidyanexis/presentation/pages/reports/enquiry_source_reports_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/expense_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_report.dart';
import 'package:vidyanexis/presentation/pages/reports/task_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/work_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_status_report_screen.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/customer_outstanding_report_page.dart';
import 'package:vidyanexis/presentation/pages/customer/lead_search_page.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_use_report.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_return_report.dart';
import 'package:vidyanexis/presentation/pages/reports/ta_report_screen.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/travel_allowance_page.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true, // Helpful for debugging
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        return fadeTransition(const SplashScreen());
      },
    ),
    GoRoute(
      path: CompanyCodePage.route,
      pageBuilder: (context, state) {
        return fadeTransition(const CompanyCodePage());
      },
    ),
    GoRoute(
      path: LoginPage.route,
      pageBuilder: (context, state) {
        return fadeTransition(
            AppStyles.isWebScreen(context) ? LoginPage() : LoginPageMobile());
      },
    ),
    // GoRoute(
    //   path: '${TaskDetailsPagePhone.route}:taskId/:taskMasterId',
    //   pageBuilder: (context, state) {
    //     final taskId = state.pathParameters['taskId']!;
    //     final taskMasterId = state.pathParameters['taskMasterId']!;
    //     return fadeTransition(TaskDetailsPagePhone(
    //       taskId: taskId,
    //       taskMasterId: taskMasterId,
    //     ));
    //   },
    // ),
    // GoRoute(
    //   path: '${QuotationDetailsPagePhone.route}:quotationId',
    //   pageBuilder: (context, state) {
    //     final quotationId = state.pathParameters['quotationId']!;
    //     return fadeTransition(QuotationDetailsPagePhone(
    //       quotationId: quotationId,
    //     ));
    //   },
    // ),
    // GoRoute(
    //   path: '${ComplaintsDetailsPageMobile.route}:serviceId',
    //   pageBuilder: (context, state) {
    //     final serviceId = state.pathParameters['serviceId']!;
    //     return fadeTransition(ComplaintsDetailsPageMobile(
    //       serviceId: serviceId,
    //     ));
    //   },
    // ),
    GoRoute(
      path: HomePage.route,
      pageBuilder: (context, state) {
        return fadeTransition(AppStyles.isWebScreen(context)
            ? const HomePage()
            : const HomePageMobile());
      },
    ),
    GoRoute(
      path: BulkImportScreen.route,
      pageBuilder: (context, state) {
        return fadeTransition(const BulkImportScreen());
      },
    ),
    GoRoute(
      path: '${WorkReportScreen.route}:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return fadeTransition(WorkReportScreen(
          userId: userId,
        ));
      },
    ),
    GoRoute(
      path: '${EnquirySourceReportsScreen.route}:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return fadeTransition(EnquirySourceReportsScreen(
          userId: userId,
        ));
      },
    ),

    GoRoute(
      path:
          '${CustomerDetailsScreen.route}:customerId/:report', // Add customerName to the URL
      pageBuilder: (context, state) {
        final customerId = state.pathParameters['customerId']!;
        final report = state.pathParameters['report']!;
        return fadeTransition(CustomerDetailsScreen(
          customerId: customerId,
          report: report,
        ));
      },
    ),
    GoRoute(
      path: '${CustomerDetailPageMobile.route}:customerId/:fromLead',
      pageBuilder: (context, state) {
        final customerId = int.parse(state.pathParameters['customerId']!);
        final fromLead = state.pathParameters['fromLead']! == 'true';
        final initialTab = state.uri.queryParameters['tab'];
        return fadeTransition(CustomerDetailPageMobile(
          customerId: customerId,
          fromLead: fromLead,
          initialTab: initialTab,
        ));
      },
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) {
        final customerId = state.uri.queryParameters['customerId'] ?? '';
        final taskId = state.uri.queryParameters['taskId'] ?? '';

        return FeedbackPage(customerId: customerId, taskId: taskId);
      },
    ),
    GoRoute(
      path: ExpenseReportScreen.route,
      pageBuilder: (context, state) {
        return fadeTransition(const ExpenseReportScreen());
      },
    ),
    GoRoute(
      path: StockReport.route,
      pageBuilder: (context, state) {
        return fadeTransition(const StockReport());
      },
    ),
    GoRoute(
      path: '/taskSummaryReport',
      pageBuilder: (context, state) {
        return fadeTransition(const TaskSummaryReportScreen());
      },
    ),
    GoRoute(
      path: LeadStatusReportScreen.route,
      pageBuilder: (context, state) {
        return fadeTransition(const LeadStatusReportScreen());
      },
    ),
    GoRoute(
      path: CustomerOutstandingReportPage.route,
      pageBuilder: (context, state) {
        return fadeTransition(const CustomerOutstandingReportPage());
      },
    ),
    GoRoute(
      path: LeadSearchPage.route,
      pageBuilder: (context, state) {
        return fadeTransition(const LeadSearchPage());
      },
    ),
    GoRoute(
      path: StockUseReport.route,
      pageBuilder: (context, state) {
        return fadeTransition(const StockUseReport());
      },
    ),
    GoRoute(
      path: StockReturnReport.route,
      pageBuilder: (context, state) {
        return fadeTransition(const StockReturnReport());
      },
    ),
    GoRoute(
      path: TravelAllowancePage.route,
      pageBuilder: (context, state) {
        return fadeTransition(const TravelAllowancePage());
      },
    ),
    GoRoute(
      path: TAReportScreen.route,
      pageBuilder: (context, state) {
        return fadeTransition(const TAReportScreen());
      },
    ),
  ],
);

// Custom transition builder for dissolve effect
Page fadeTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, a, b, child) => CupertinoPageTransition(
      linearTransition: true,
      primaryRouteAnimation: a,
      secondaryRouteAnimation: b,
      child: child,
    ),
  );
}
