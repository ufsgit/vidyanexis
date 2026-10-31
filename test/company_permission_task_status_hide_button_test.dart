import 'package:flutter_test/flutter_test.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Company Permission 58 (Task status change hide button) Tests', () {
    test('CompanyPermission.fromJson handles permission 58 correctly', () {
      final jsonInt = {
        'Company_Permission_Id': 58,
        'Caption': 'Task status change hide button',
        'Value': 1,
      };
      final perm1 = CompanyPermission.fromJson(jsonInt);
      expect(perm1.companyPermissionId, 58);
      expect(perm1.caption, 'Task status change hide button');
      expect(perm1.displayCaption, 'Task status change hide button');
      expect(perm1.value, 1);

      final jsonEmptyCaption = {
        'company_permission_id': '58',
        'caption': '',
        'value': '0',
      };
      final perm2 = CompanyPermission.fromJson(jsonEmptyCaption);
      expect(perm2.companyPermissionId, 58);
      expect(perm2.displayCaption, 'Task status change hide button');
      expect(perm2.value, 0);
    });

    test('CompanyPermission.fromJson also supports fallback 57', () {
      final json57 = {
        'Company_Permission_Id': 57,
        'caption': '',
        'value': 1,
      };
      final perm = CompanyPermission.fromJson(json57);
      expect(perm.companyPermissionId, 57);
      expect(perm.displayCaption, 'Task status change hide button');
      expect(perm.value, 1);
    });

    test('Permission 58 resolution logic in permissions list', () {
      int resolveTaskStatusChangeHideButton(
          List<CompanyPermission> permissions, int fallback) {
        if (permissions.isNotEmpty) {
          for (var p in permissions) {
            if (p.companyPermissionId == 58 ||
                p.companyPermissionId.toString() == '58' ||
                p.companyPermissionId == 57 ||
                p.companyPermissionId.toString() == '57') {
              return (p.value == 1 || p.value.toString() == '1') ? 1 : 0;
            }
          }
          for (var p in permissions) {
            final cap = (p.caption.isNotEmpty ? p.caption : p.displayCaption)
                .trim()
                .toLowerCase();
            if (cap.contains('task status change hide button') ||
                cap.contains('task_status_change_hide_button')) {
              return (p.value == 1 || p.value.toString() == '1') ? 1 : 0;
            }
          }
        }
        return (fallback == 1 || fallback.toString() == '1') ? 1 : 0;
      }

      // Disabled: value = 0 with permission 58
      final disabledPerms = [
        CompanyPermission(
            companyPermissionId: 58,
            caption: 'Task status change hide button',
            value: 0),
      ];
      expect(resolveTaskStatusChangeHideButton(disabledPerms, 1), 0);

      // Enabled: value = 1 with permission 58
      final enabledPerms = [
        CompanyPermission(
            companyPermissionId: 58,
            caption: 'Task status change hide button',
            value: 1),
      ];
      expect(resolveTaskStatusChangeHideButton(enabledPerms, 0), 1);

      // Fallback 57 enabled
      final enabled57 = [
        CompanyPermission(
            companyPermissionId: 57,
            caption: 'Task status change hide button',
            value: 1),
      ];
      expect(resolveTaskStatusChangeHideButton(enabled57, 0), 1);

      // Caption match
      final captionMatch = [
        CompanyPermission(
            companyPermissionId: 999,
            caption: 'Task status change hide button',
            value: 1),
      ];
      expect(resolveTaskStatusChangeHideButton(captionMatch, 0), 1);

      // Empty list fallback
      expect(resolveTaskStatusChangeHideButton([], 0), 0);
      expect(resolveTaskStatusChangeHideButton([], 1), 1);
    });
  });
}

