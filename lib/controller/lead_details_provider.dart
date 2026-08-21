import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_history.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class LeadDetailsProvider with ChangeNotifier {
  List<LeadDetails> _leadDetails = [];
  List<FollowUpHistory> _followUpHistory = [];
  bool _isLoading = false;
  bool _isFetchLoading = false;

  List<LeadDetails>? get leadDetails => _leadDetails;
  List<FollowUpHistory>? get followUpHistory => _followUpHistory;
  bool get isLoading => _isLoading;
  bool get isFetchLoading => _isFetchLoading;

  Future<void> fetchLeadDetails(String customerId, BuildContext context) async {
    _isFetchLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.leadDetails}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final leadProvider =
              Provider.of<LeadsProvider>(context, listen: false);
          final dropDownProvider =
              Provider.of<DropDownProvider>(context, listen: false);
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          leadProvider.clearAllLeadControllers(context);
          dropDownProvider.setSelectedEnquirySourceId(0);
          dropDownProvider.updateDistrict(null, '');
          settingsProvider.selectedDepartmentId = 0;
          settingsProvider.selectedBranchId = 0;
          dropDownProvider.setSourceCategoryId(0);

          dropDownProvider.updateEnquiryForName(null, '');
          _leadDetails = (data as List<dynamic>)
              .map((item) => LeadDetails.fromJson(item))
              .toList();

          if (_leadDetails.isNotEmpty) {
            final leadData = _leadDetails[0];

            leadProvider.leadNameController.text = leadData.customerName;
            leadProvider.contactNoController.text =
                leadData.contactNumber.toString();
            leadProvider.emailIdController.text = leadData.email;
            leadProvider.enquirySourceController.text =
                leadData.enquirySourceName;
            leadProvider.enquiryForController.text = leadData.enquiryForName;
            leadProvider.addressController.text = leadData.address ?? '';
            leadProvider.mapLinkController.text = leadData.location ?? '';
            leadProvider.referenceNameController.text =
                leadData.referenceName ?? '';
            leadProvider.priorityId = leadData.priorityId;
            leadProvider.leadSubsidyController.text = leadData.subsidyAmount;

            leadProvider.cityController.text = leadData.address1 ?? '';
            leadProvider.districtController.text = leadData.address2 ?? '';
            leadProvider.stateController.text = leadData.address3 ?? '';
            leadProvider.latitudeController.text = leadData.latitude ?? '';
            leadProvider.longitudeController.text = leadData.longitude ?? '';
            leadProvider.pincodeController.text = leadData.pinCode ?? '';
            leadProvider.landmarkController.text = leadData.landmark ?? '';
            leadProvider.followUpStatusController.text = leadData.statusName;
            leadProvider.inverterTypeController.text =
                leadData.inverterTypeName;
            leadProvider.panelBrandController.text = leadData.panelTypeName;
            leadProvider.panelPhaseController.text = leadData.phaseName;
            leadProvider.costIncludesController.text = leadData.costIncName;
            leadProvider.workTypeController.text = leadData.workTypeName;
            leadProvider.roofTypeController.text = leadData.roofTypeName;
            leadProvider.amountPaidController.text =
                leadData.amountPaidThroughName;
            leadProvider.searchUserController.text = leadData.byUserName;
            leadProvider.assignToController.text = leadData.toUserName;
            leadProvider.remarksController.text = leadData.remark;
            leadProvider.consumerNoController.text = leadData.consumerNumber;
            leadProvider.electricalSectionController.text =
                leadData.electricalSection ?? '';
            leadProvider.invertorCapacityController.text =
                leadData.inverterCapacity == 0
                    ? ""
                    : leadData.inverterCapacity
                        .toString()
                        .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.projectCostController.text = leadData.projectCost == 0
                ? ""
                : leadData.projectCost
                    .toString()
                    .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.panelCapacityController.text =
                leadData.panelCapacity == 0
                    ? ""
                    : leadData.panelCapacity
                        .toString()
                        .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.additionalCostControler.text =
                leadData.additionalCost == 0
                    ? ""
                    : leadData.additionalCost
                        .toString()
                        .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.advanceAmountController.text =
                leadData.advanceAmount == 0
                    ? ""
                    : leadData.advanceAmount
                        .toString()
                        .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.commissionController.text = leadData.commission == 0
                ? ""
                : leadData.commission
                    .toString()
                    .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.repController.text = leadData.rep ?? '';
            leadProvider.leadByController.text = leadData.leadBy ?? '';
            leadProvider.additionalCommentscONTROLLER.text =
                leadData.additionalComments ?? '';

            leadProvider.leadAgeController.text = leadData.age.toString() ?? '';

            leadProvider.branchController.text = leadData.branchName ?? '';
            leadProvider.departmentController.text =
                leadData.departmentName ?? '';
            leadProvider.referenceNameController.text =
                leadData.referenceName ?? '';
            leadProvider.districtController.text = leadData.districtName ?? '';
            leadProvider.connectedLoadController.text =
                leadData.connectedLoad == 0
                    ? ""
                    : leadData.connectedLoad
                        .toString()
                        .replaceAll(RegExp(r'\.0$'), '');
            leadProvider.aadharImage = leadData.adhaarCardBack ?? '';
            leadProvider.passportImage = leadData.passportSizePhoto ?? '';
            leadProvider.upiImage = leadData.upiTransferPhoto ?? '';
            leadProvider.electricityBillImage =
                leadData.electricityBillPhoto ?? '';
            leadProvider.cancelledPassBookImage =
                leadData.cancelledChequePassbook ?? '';
            leadProvider.passportImage = leadData.passportSizePhoto ?? '';
            dropDownProvider.setSourceCategoryId(leadData.sourceCategoryId);
            leadProvider.sourceCategoryController.text =
                leadData.sourceCategoryName;
            dropDownProvider
                .filterEnquiryForByCategory(leadData.sourceCategoryId);
            dropDownProvider.updateEnquiryForName(
                leadData.enquiryForId, leadData.enquiryForName);
            dropDownProvider.updateDistrict(
                leadData.districtId, leadData.districtName ?? '');
            dropDownProvider.selectedSourceId = leadData.sourceCategoryId;

            settingsProvider.selectedBranchId = leadData.branchId;
            settingsProvider.selectedDepartmentId = leadData.departmentId;

            leadProvider.selectedInverterId = leadData.inverterTypeId;
            leadProvider.selectedAmountPaidId = leadData.amountPaidThroughId;
            leadProvider.selectedCostIncId = leadData.costIncludesId;
            leadProvider.selectedPanelId = leadData.panelTypeId;
            leadProvider.selectedPhaseId = leadData.phaseId;
            leadProvider.selectedRoofId = leadData.roofTypeId;
            leadProvider.selectedWorkTypeId = leadData.workTypeId;
            leadProvider.selectedSubsidyId = leadData.subsidyTypeId;
            dropDownProvider.setSelectedcreUserId(leadData.creId);
            dropDownProvider.setSelectedleadtypeUserId(leadData.leadTypeId);

            dropDownProvider.setSelectedpeUserId(leadData.peId);
            dropDownProvider.selectedLocationId =
                leadData.locationId; // Added this line
            leadProvider.creController.text = leadData.creName;
            leadProvider.peController.text = leadData.peName;
            leadProvider.leadtypeController.text = leadData.leadTypeName;
            leadProvider.consumerNameController.text = leadData.consumerName;
            leadProvider.consumerContactNoController.text =
                leadData.consumerContactNo;

            // Set IDs in dropdown provider to ensure they are available for saving
            dropDownProvider.setSelectedFollowUPId(leadData.statusId);
            dropDownProvider
                .setSelectedEnquirySourceId(leadData.enquirySourceId);
            dropDownProvider.setSelectedUserId(leadData.toUserId);

            if (leadData.nextFollowUpDate.isNotEmpty) {
              leadProvider.followUpDateController.text =
                  leadData.nextFollowUpDate;
            }
            if (leadData.workCompletionDateDisplay.isNotEmpty) {
              leadProvider.workCompletionDateController.text =
                  leadData.workCompletionDateDisplay;
              leadProvider.installationDateController.text =
                  leadData.workCompletionDateDisplay;
            }
            log(leadProvider.enquirySourceController.text);
            notifyListeners();
          } else {
            showToastInDialog("Lead data not found", context);
          }
        }
      } else {
        throw Exception('Failed to load lead details');
      }
    } catch (error) {
      print('Exception occurred: $error');
    }

    _isFetchLoading = false;
    notifyListeners();
  }

//no context only for back in customer detail
  Future<void> fetchLeadDetailsNoContext(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.leadDetails}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _leadDetails = (data as List<dynamic>)
              .map((item) => LeadDetails.fromJson(item))
              .toList();
        }
      } else {
        throw Exception('Failed to load lead details');
      }
    } catch (error) {
      print('Exception occurred: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool _isUpdatingRemark = false;
  bool get isUpdatingRemark => _isUpdatingRemark;

  Future<void> fetchFollowUpHistory(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.followUpHistory}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _followUpHistory = (data as List)
              .map((item) => FollowUpHistory.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load lead details');
      }
    } catch (error) {
      print('Exception occurred: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateRemark({
    required BuildContext context,
    required String customerId,
    required String followUpId,
    required String updatedRemark,
    int? statusId,
    String? statusName,
    int? toUserId,
    String? toUserName,
    String? followUpDate,
  }) async {
    if (updatedRemark.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remark cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    _isUpdatingRemark = true;
    notifyListeners();

    try {
      final bodyData = {
        "FollowUp": {
          if (followUpId.isNotEmpty && followUpId != "0")
            "FollowUp_Id": int.tryParse(followUpId) ?? followUpId,
          "Remark": updatedRemark.trim(),
          if (statusId != null && statusId != 0) "Status_Id": statusId,
          if (statusName != null && statusName.isNotEmpty)
            "Status_Name": statusName,
          if (toUserId != null && toUserId != 0) "To_User_Id": toUserId,
          if (toUserName != null && toUserName.isNotEmpty)
            "To_User_Name": toUserName,
          if (followUpDate != null && followUpDate.isNotEmpty)
            "Next_FollowUp_date": followUpDate,
        },
        "Customer_Id": int.tryParse(customerId) ?? customerId,
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveFollowUp,
        bodyData: bodyData,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remark updated successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        await fetchFollowUpHistory(customerId);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update remark. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating remark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      _isUpdatingRemark = false;
      notifyListeners();
    }
  }
}
