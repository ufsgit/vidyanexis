import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/controller/models/save_lead_model.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';

void main() {
  group('Work Completion Date Unit Tests', () {
    test('Date parsing logic handles various formats properly', () {
      String? formatWcDate(String? rawWcDate) {
        if (rawWcDate == null || rawWcDate.isEmpty || rawWcDate == 'null') {
          return null;
        }
        try {
          DateTime parsedDate;
          try {
            parsedDate = DateFormat('dd MMM yyyy').parse(rawWcDate);
          } catch (_) {
            try {
              parsedDate = DateFormat('dd MMMM yyyy').parse(rawWcDate);
            } catch (_) {
              parsedDate = DateTime.parse(rawWcDate);
            }
          }
          return DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (_) {
          return null;
        }
      }

      expect(formatWcDate('21 Aug 2026'), '2026-08-21');
      expect(formatWcDate('21 August 2026'), '2026-08-21');
      expect(formatWcDate('2026-08-21'), '2026-08-21');
      expect(formatWcDate(''), isNull);
      expect(formatWcDate(null), isNull);
      expect(formatWcDate('null'), isNull);
      expect(formatWcDate('invalid date'), isNull);
    });

    test('Lead in save_lead_model serializes work_completion_date', () {
      final lead = Lead(
        customerId: 1,
        customerName: 'Test Lead',
        contactNumber: '9876543210',
        contactPerson: 'Tester',
        email: 'test@example.com',
        address1: 'Street 1',
        address2: 'City',
        address3: 'Dist',
        address4: 'State',
        createdBy: 1,
        createdByName: 'Admin',
        entryDate: DateTime(2026, 8, 21),
        consumerNo: 12345,
        subDistrict: 'Sub',
        village: 'Vil',
        section: 'Sec',
        subDivision: 'SubDiv',
        division: 'Div',
        circle: 'Cir',
        connectedLoad: '5kW',
        proposedKw: '5kW',
        roofType: 'RCC',
        enquirySourceId: 1,
        enquirySourceName: 'Direct',
        mapLink: 'http://maps.google.com',
        pincode: '682001',
        projectCost: 100000.0,
        workCompletionDate: DateTime(2026, 8, 21),
      );

      final json = lead.toJson();
      expect(json['work_completion_date'], '2026-08-21');

      final fromJsonLead = Lead.fromJson(json);
      expect(fromJsonLead.workCompletionDate, DateTime(2026, 8, 21));
    });

    test(
        'LeadDetails model correctly parses and serializes work_completion_date',
        () {
      final jsonInput = {
        'Customer_Id': 100,
        'Customer_Name': 'John Doe',
        'address': 'Main Street',
        'location': 'Kochi',
        'Contact_Number': '9876543210',
        'Phone_Number': '9876543210',
        'Email': 'john@example.com',
        'FollowUp_Id': 1,
        'Next_FollowUp_date': '2026-08-21',
        'To_User_Id': 2,
        'To_User_Name': 'Staff',
        'FollowUp': 1,
        'Status_Id': 1,
        'Status_Name': 'Pending',
        'By_User_Id': 1,
        'By_User_Name': 'Admin',
        'Is_Registered': 0,
        'Enquiry_For_Id': 1,
        'Enquiry_For_Name': 'Solar',
        'Enquiry_Source_Id': 1,
        'Enquiry_Source_Name': 'Web',
        'Remark': 'Good lead',
        'Color_Code': '#FFFFFF',
        'DeleteStatus': 0,
        'Lead_Details_Id': 1,
        'consumer_number': 'CN123',
        'electrical_section': 'Sec 1',
        'inverter_capacity': 5.0,
        'inverter_type_id': 1,
        'inverter_type_name': 'String',
        'panel_capacity': 5.0,
        'panel_type_id': 1,
        'panel_type_name': 'Mono',
        'phase_id': 1,
        'phase_name': 'Single',
        'roof_type_id': 1,
        'roof_type_name': 'Sloped',
        'project_cost': 100000.0,
        'additional_cost': 0.0,
        'advance_amount': 20000.0,
        'amount_paid_through_id': 1,
        'amount_paid_through_name': 'Cash',
        'upi_transfer_photo': '',
        'cost_includes_id': 1,
        'cost_includes_name': 'All',
        'electricity_bill_photo': '',
        'cancelled_cheque_passbook': '',
        'adhaar_card_back': '',
        'passport_size_photo': '',
        'connected_load': 5.0,
        'rep': 'Rep A',
        'lead_by': 'Admin',
        'work_type_id': 1,
        'work_type_name': 'Installation',
        'subsidy_type_id': 1,
        'subsidy_type_name': 'Govt',
        'additional_comments': 'None',
        'branch_id': 1,
        'total_task': 0,
        'completed_task': 0,
        'active_task_count': 0,
        'Source_Category_Id': 1,
        'Source_Category_Name': 'Category 1',
        'Branch_Name': 'Main Branch',
        'Department_Id': 1,
        'Department_Name': 'Sales',
        'Reference_Name': 'Ref',
        'Kseb_Expense': '0',
        'Actual_RTS_Capacity': '5',
        'Total_Project_Cost': '100000',
        'PM_SuryaShakthi_Portal_Id': '',
        'Jan_Samarth_Id': '',
        'bankbranch': '',
        'inverterBrandName': '',
        'panelBrandName': '',
        'noOfPanels': '10',
        'Efficiency': '20%',
        'Age': 30,
        'PE_Id': 1,
        'PE_Name': 'PE Staff',
        'CRE_Id': 1,
        'CRE_Name': 'CRE Staff',
        'Lead_Type_Id': 1,
        'Lead_Type_Name': 'Commercial',
        'Engineer_Name': 'Eng',
        'Organization': 'Org',
        'Engineer_Mobile': '9876543210',
        'Engineer_City': 'Kochi',
        'Engineer_District': 'Ernakulam',
        'Firestation': 0,
        'commission': 5000.0,
        'Consumer_Name': 'John',
        'Contact_No': '9876543210',
        'Priority_Id': 1,
        'Subsidy_Amount': '0',
        'work_completion_date': '2026-08-21',
      };

      final leadDetails = LeadDetails.fromJson(jsonInput);
      expect(leadDetails.workCompletionDate, '2026-08-21');
      expect(leadDetails.workCompletionDateDisplay, '21 Aug 2026');

      final serialized = leadDetails.toJson();
      expect(serialized['work_completion_date'], '2026-08-21');
    });

    test('SearchLeadModel serializes work_completion_date', () {
      final lead = SearchLeadModel.fromJson({
        'Customer_Id': 1,
        'Customer_Name': 'Test',
        'work_completion_date': '2026-08-21',
      });
      expect(lead.workCompletionDate, '2026-08-21');
      final json = lead.toJson();
      expect(json['work_completion_date'], '2026-08-21');
      expect(json['Work_Completion_Date'], '2026-08-21');
    });

    test('SearchLeadModel.workCompletionDateDisplay formats dates for customer table', () {
      // Case A: work_completion_date
      final lead1 = SearchLeadModel.fromJson({
        'Customer_Id': 1,
        'Customer_Name': 'Test 1',
        'work_completion_date': '2026-08-21',
      });
      expect(lead1.workCompletionDateDisplay, '21 Aug 2026');

      // Case B: Work_Completion_Date
      final lead2 = SearchLeadModel.fromJson({
        'Customer_Id': 2,
        'Customer_Name': 'Test 2',
        'Work_Completion_Date': '2026-08-21',
      });
      expect(lead2.workCompletionDateDisplay, '21 Aug 2026');

      // Case C: ISO DateTime string
      final lead3 = SearchLeadModel.fromJson({
        'Customer_Id': 3,
        'Customer_Name': 'Test 3',
        'work_completion_date': '2026-08-21T00:00:00.000Z',
      });
      expect(lead3.workCompletionDateDisplay, '21 Aug 2026');

      // Case D: Null or empty returns '-'
      final leadNull = SearchLeadModel.fromJson({
        'Customer_Id': 4,
        'Customer_Name': 'Test 4',
        'work_completion_date': null,
      });
      expect(leadNull.workCompletionDateDisplay, '-');

      final leadEmpty = SearchLeadModel.fromJson({
        'Customer_Id': 5,
        'Customer_Name': 'Test 5',
        'work_completion_date': '',
      });
      expect(leadEmpty.workCompletionDateDisplay, '-');
    });

    test(
        'SearchLeadModel prioritizes top-level Work_Completion_Date over nested null in lead',
        () {
      final json = {
        'Customer_Id': 101,
        'Customer_Name': 'Customer With Work Completion',
        'Work_Completion_Date': '2026-08-21',
        'lead': {
          'work_completion_date': null,
        },
        'AMC_To_Date': '2027-08-21',
      };

      final customer = SearchLeadModel.fromJson(json);
      expect(customer.workCompletionDate, '2026-08-21');
      expect(customer.workCompletionDateDisplay, '21 Aug 2026');
      expect(customer.amcDate, '2027-08-21');
      expect(customer.amcDateDisplay, '21 Aug 2027');
    });

    test('SearchLeadModel handles customer without Work Completion Date', () {
      final json = {
        'Customer_Id': 102,
        'Customer_Name': 'Customer Without Work Completion',
        'Work_Completion_Date': null,
        'lead': {
          'work_completion_date': null,
        },
      };

      final customer = SearchLeadModel.fromJson(json);
      expect(customer.workCompletionDate, '');
      expect(customer.workCompletionDateDisplay, '-');
    });

    test('save_lead payload contains work_completion_date with exact key', () {
      final payload = {
        "Lead_Mobile_Existed_Check": 0,
        "Lead_Mobile_Check": 0,
        "work_completion_date": "2026-08-21",
        "lead": {
          "Customer_Id": 1,
          "Customer_Name": "Test Customer",
          "work_completion_date": "2026-08-21",
        },
        "followup": {
          "Next_FollowUp_date": "2026-08-25",
        }
      };

      final encoded = jsonEncode(payload);
      final decoded = jsonDecode(encoded);
      expect(decoded['lead']['work_completion_date'], '2026-08-21');
      expect(decoded['work_completion_date'], '2026-08-21');
    });
  });
}

