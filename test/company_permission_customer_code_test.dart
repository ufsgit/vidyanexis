import 'package:flutter_test/flutter_test.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Company Permission 56 (Customer code) Tests', () {
    test('CompanyPermission.fromJson handles int and string values correctly', () {
      final jsonInt = {
        'Company_Permission_Id': 56,
        'Caption': 'Customer code',
        'Value': 0,
      };
      final perm1 = CompanyPermission.fromJson(jsonInt);
      expect(perm1.companyPermissionId, 56);
      expect(perm1.caption, 'Customer code');
      expect(perm1.displayCaption, 'Customer code');
      expect(perm1.value, 0);

      final jsonStr = {
        'company_permission_id': '56',
        'caption': '',
        'value': '1',
      };
      final perm2 = CompanyPermission.fromJson(jsonStr);
      expect(perm2.companyPermissionId, 56);
      expect(perm2.displayCaption, 'Customer code');
      expect(perm2.value, 1);
    });

    test('SearchLeadModel displays customerCode or registrationNo correctly', () {
      final leadWithCode = SearchLeadModel.fromJson({
        'Customer_Name': 'Customer A',
        'Lead_Code': '-14',
        'Customer_Code': '27',
        'Registration_No': '27',
      });
      expect(leadWithCode.displayCustomerCode, '27');

      final leadWithRegOnly = SearchLeadModel.fromJson({
        'Customer_Name': 'Customer B',
        'Lead_Code': '-1',
        'Registration_No': '23',
      });
      expect(leadWithRegOnly.displayCustomerCode, '23');

      final leadWithNoCode = SearchLeadModel.fromJson({
        'Customer_Name': 'Customer C',
        'Lead_Code': '-6',
      });
      expect(leadWithNoCode.displayCustomerCode, '');
    });

    test('Permission 56 resolution logic', () {
      int resolveShowCustomerCode(List<CompanyPermission> permissions, int fallback) {
        if (permissions.isNotEmpty) {
          for (var p in permissions) {
            if (p.companyPermissionId == 56 || p.companyPermissionId.toString() == '56') {
              return (p.value == 1 || p.value.toString() == '1') ? 1 : 0;
            }
          }
          for (var p in permissions) {
            final cap = (p.caption.isNotEmpty ? p.caption : p.displayCaption).trim().toLowerCase();
            if (cap == 'customer code' || cap == 'customer_code') {
              return (p.value == 1 || p.value.toString() == '1') ? 1 : 0;
            }
          }
        }
        return (fallback == 1 || fallback.toString() == '1') ? 1 : 0;
      }

      // Disabled: value = 0
      final disabledPerms = [
        CompanyPermission(companyPermissionId: 56, caption: 'Customer code', value: 0),
      ];
      expect(resolveShowCustomerCode(disabledPerms, 0), 0);
      expect(resolveShowCustomerCode(disabledPerms, 1), 0); // Perm 56 overrides fallback!

      // Enabled: value = 1
      final enabledPerms = [
        CompanyPermission(companyPermissionId: 56, caption: 'Customer code', value: 1),
      ];
      expect(resolveShowCustomerCode(enabledPerms, 0), 1);

      // Not found, fallback to state
      final emptyPerms = <CompanyPermission>[];
      expect(resolveShowCustomerCode(emptyPerms, 0), 0);
      expect(resolveShowCustomerCode(emptyPerms, 1), 1);
    });
  });
}
