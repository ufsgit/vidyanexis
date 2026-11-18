import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Jb_Task_search Permission in SettingsProvider', () {
    test('CompanyPermission correctly parses Jb_Task_search from JSON', () {
      final json1 = {
        'Company_Permission_Id': 99,
        'Caption': 'Jb_Task_search',
        'Value': 1,
      };
      final perm1 = CompanyPermission.fromJson(json1);
      expect(perm1.caption, 'Jb_Task_search');
      expect(perm1.displayCaption, 'Jb_Task_search');
      expect(perm1.value, 1);

      final json0 = {
        'Company_Permission_Id': 99,
        'Caption': 'jb_task_search',
        'Value': 0,
      };
      final perm0 = CompanyPermission.fromJson(json0);
      expect(perm0.caption, 'jb_task_search');
      expect(perm0.value, 0);
    });

    test('SettingsProvider resolves isJbTaskSearchEnabled correctly', () {
      final settings = SettingsProvider();

      // Default should be 0 (disabled)
      expect(settings.jbTaskSearch, 0);
      expect(settings.isJbTaskSearchEnabled, false);

      // When company permission has Jb_Task_search with value 1
      final company = Company(
        companyId: 1,
        companyName: 'Test Company',
        address1: '',
        address2: '',
        address3: '',
        address4: '',
        mobileNumber: '',
        phoneNumber: '',
        email: '',
        website: '',
        logo: '',
        gstNo: '',
        panNo: '',
        cinNo: '',
        companyCode: '',
        userCount: '1',
        deleteStatus: 0,
        isLocation: 0,
        notificationTopic: '',
        enquiryForMandatory: 0,
        enquirySourceMandatory: 0,
        consumerNameMandatory: 0,
        consumerContactNoMandatory: 0,
        leadInSales: 0,
        quotationItemValue: 0,
        additionalExpense: 0,
        commercialProposal: 0,
        districtCityMandatory: 0,
        leadMobileExistedCheck: 0,
        taskRemarkMandatory: 0,
        residentialScopeOfWork: 0,
        commercialScopeOfWork: 0,
        permissions: [
          CompanyPermission(
            companyPermissionId: 99,
            caption: 'Jb_Task_search',
            value: 1,
          ),
        ],
      );

      settings.companyDetails.add(company);
      expect(settings.jbTaskSearch, 1);
      expect(settings.isJbTaskSearchEnabled, true);

      // Toggle off
      settings.setJbTaskSearch(0);
      expect(settings.jbTaskSearch, 0);
      expect(settings.isJbTaskSearchEnabled, false);

      // Toggle on
      settings.setJbTaskSearch(1);
      expect(settings.jbTaskSearch, 1);
      expect(settings.isJbTaskSearchEnabled, true);
    });
  });

  group('TaskReportModel Custom Fields and Raw JSON Parsing', () {
    test('TaskReportModel parses custom_fields list correctly', () {
      final json = {
        'Task_Id': 101,
        'Customer_Name': 'Sabeesh',
        'Consumer_Name': 'Consumer S',
        'Customer_Contact': '8078540367',
        'Task_Type_Name': 'Loan Application',
        'Task_Status_Name': 'Pending',
        'Task_Date': '2026-11-17',
        'User_Details_Name': 'Sudharma',
        'Remarks': 'Account to be Started',
        'custom_fields': [
          {
            'order': 1,
            'data_value': 'Solar Roof Top 3KW',
            'custom_field_id': 10,
            'custom_field_name': 'System Capacity',
          },
        ],
      };

      final task = TaskReportModel.fromJson(json);
      expect(task.taskId, 101);
      expect(task.customerName, 'Sabeesh');
      expect(task.consumerName, 'Consumer S');
      expect(task.customFields.length, 1);
      expect(task.customFields.first.customFieldName, 'System Capacity');
      expect(task.customFields.first.datavalue, 'Solar Roof Top 3KW');
      expect(task.rawJson, isNotNull);
    });
  });

  group('TaskPageProvider JB Search Filtering Across All Data on Page', () {
    final task1 = TaskReportModel.fromJson({
      'Task_Id': 1,
      'Customer_Name': 'Sabeesh',
      'Consumer_Name': 'Arun',
      'Contact_Number': '8078540367',
      'Task_Type_Name': 'Loan Application',
      'Task_Status_Name': 'Pending',
      'Task_Date': '2026-11-17',
      'Entry_Date': '2026-11-10 10:00:00',
      'next_followup_date': '2026-11-20',
      'To_User_Name': 'Sudharma',
      'consumer_number': 'CONS-001',
      'Remark': 'Account to be Started',
      'Description': 'Initial bank verification',
      'custom_fields': [
        {
          'custom_field_id': 1,
          'custom_field_name': 'Inverter Model',
          'data_value': 'Growatt 5kW',
        }
      ],
    });

    final task2 = TaskReportModel.fromJson({
      'Task_Id': 2,
      'Customer_Name': 'Ummer Challil',
      'Consumer_Name': 'Basheer',
      'Contact_Number': '8156976769',
      'Task_Type_Name': 'Document Collection',
      'Task_Status_Name': 'Completed',
      'Task_Date': '2026-10-05',
      'Entry_Date': '2026-10-01 11:30:00',
      'next_followup_date': '2026-10-15',
      'To_User_Name': 'Jijeesh',
      'consumer_number': 'CONS-002',
      'Remark': 'Customer Went Abroad',
      'Description': 'Passport and visa copy needed',
      'custom_fields': [
        {
          'custom_field_id': 2,
          'custom_field_name': 'Panel Brand',
          'data_value': 'Tata Power 400W',
        }
      ],
    });

    final taskList = [task1, task2];

    test('Searches across corresponding data on that page without choosing dropdown', () {
      final provider = TaskPageProvider();

      // Match by customer name
      var res = provider.applyJbSearchFilter(taskList, 'Sabeesh');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      // Match by consumer name
      res = provider.applyJbSearchFilter(taskList, 'Basheer');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Match by mobile
      res = provider.applyJbSearchFilter(taskList, '8078540367');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      // Match by task type
      res = provider.applyJbSearchFilter(taskList, 'Document Collection');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Match by task date
      res = provider.applyJbSearchFilter(taskList, '2026-11-17');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      // Match by next followup date
      res = provider.applyJbSearchFilter(taskList, '2026-10-15');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Match by staff
      res = provider.applyJbSearchFilter(taskList, 'Jijeesh');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Match by remark
      res = provider.applyJbSearchFilter(taskList, 'Abroad');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Match by description
      res = provider.applyJbSearchFilter(taskList, 'bank verification');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      // Match by custom field value
      res = provider.applyJbSearchFilter(taskList, 'Growatt');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      // Match by custom field name
      res = provider.applyJbSearchFilter(taskList, 'Inverter Model');
      expect(res.length, 1);
      expect(res.first.taskId, 1);

      res = provider.applyJbSearchFilter(taskList, 'Tata Power');
      expect(res.length, 1);
      expect(res.first.taskId, 2);

      // Non-existent search query returns empty
      res = provider.applyJbSearchFilter(taskList, 'NonExistentData');
      expect(res.isEmpty, true);
    });

    test('setJbSearch and clearJbSearch update taskReport state', () {
      final provider = TaskPageProvider();

      expect(provider.taskReport.isEmpty, true);
      expect(provider.isJbSearchActive, false);

      provider.setJbSearch('Loan');
      expect(provider.jbSearchQuery, 'Loan');
      expect(provider.isJbSearchActive, true);

      provider.clearJbSearch();
      expect(provider.jbSearchQuery, '');
      expect(provider.isJbSearchActive, false);
    });
  });
}
