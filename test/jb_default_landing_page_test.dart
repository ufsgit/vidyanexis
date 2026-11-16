import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Jb default Landing Page Tests', () {
    test('SidebarProvider initLandingPage sets Dashboard when jbDefault is 1', () {
      final sidebarProvider = SidebarProvider();

      sidebarProvider.initLandingPage(jbDefault: 1, force: true);

      expect(sidebarProvider.selectedName, 'Dashboard');
      expect(sidebarProvider.selectedIndex, 0);
      expect(sidebarProvider.selectedIndexMobile, 0);
      expect(sidebarProvider.hasUserNavigated, false);
    });

    test('SidebarProvider initLandingPage sets Leads when jbDefault is 0', () {
      final sidebarProvider = SidebarProvider();

      sidebarProvider.initLandingPage(jbDefault: 0, force: true);

      expect(sidebarProvider.selectedName, 'Leads');
      expect(sidebarProvider.selectedIndex, 0);
      expect(sidebarProvider.selectedIndexMobile, 0);
      expect(sidebarProvider.hasUserNavigated, false);
    });

    test('SidebarProvider preserves user navigation once user navigates', () {
      final sidebarProvider = SidebarProvider();

      // Initial state: landing page is Dashboard
      sidebarProvider.initLandingPage(jbDefault: 1, force: true);
      expect(sidebarProvider.selectedName, 'Dashboard');
      expect(sidebarProvider.hasUserNavigated, false);

      // User clicks Customers
      sidebarProvider.selectOption(name: 'Customers', index: 2);
      expect(sidebarProvider.selectedName, 'Customers');
      expect(sidebarProvider.selectedIndex, 2);
      expect(sidebarProvider.hasUserNavigated, true);

      // Background sync or company reload runs without force
      sidebarProvider.initLandingPage(jbDefault: 0, force: false);
      // Selected page should remain Customers because user navigated
      expect(sidebarProvider.selectedName, 'Customers');
      expect(sidebarProvider.selectedIndex, 2);
      expect(sidebarProvider.hasUserNavigated, true);

      // On logout / explicit login (force: true), landing page resets
      sidebarProvider.initLandingPage(jbDefault: 0, force: true);
      expect(sidebarProvider.selectedName, 'Leads');
      expect(sidebarProvider.selectedIndex, 0);
      expect(sidebarProvider.hasUserNavigated, false);
    });

    test('SidebarProvider mobile tab navigation marks user navigated', () {
      final sidebarProvider = SidebarProvider();

      sidebarProvider.initLandingPage(jbDefault: 1, force: true);
      expect(sidebarProvider.hasUserNavigated, false);

      sidebarProvider.setSelectedIndexMobile(1);
      expect(sidebarProvider.selectedIndexMobile, 1);
      expect(sidebarProvider.hasUserNavigated, true);
    });

    test('Jb default permission caption matching logic', () {
      bool isJbDefault(String caption) {
        final cap = caption.trim().toLowerCase();
        return cap.contains('jb default') ||
            cap.contains('jb_default') ||
            cap.contains('jbdefault') ||
            (cap.contains('jb') && cap.contains('default'));
      }

      expect(isJbDefault('Jb default'), true);
      expect(isJbDefault('jb default'), true);
      expect(isJbDefault('JB DEFAULT'), true);
      expect(isJbDefault('jb_default'), true);
      expect(isJbDefault('jbdefault'), true);
      expect(isJbDefault('Jb Default Setting'), true);
      expect(isJbDefault('Status wise count'), false);
      expect(isJbDefault('Hide warranty'), false);
    });

    test('CompanyPermission correctly parses Jb default from JSON', () {
      final jsonOn = {
        'Company_Permission_Id': 99,
        'Caption': 'Jb default',
        'Value': 1,
      };
      final permOn = CompanyPermission.fromJson(jsonOn);
      expect(permOn.caption, 'Jb default');
      expect(permOn.displayCaption, 'Jb default');
      expect(permOn.value, 1);

      final jsonOff = {
        'Company_Permission_Id': 99,
        'Caption': 'Jb default',
        'Value': 0,
      };
      final permOff = CompanyPermission.fromJson(jsonOff);
      expect(permOff.caption, 'Jb default');
      expect(permOff.displayCaption, 'Jb default');
      expect(permOff.value, 0);
    });
  });
}

