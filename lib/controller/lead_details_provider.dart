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

            leadProvider.cityController.text = leadData.address1 ?? '';
            leadProvider.districtController.text = leadData.address2 ?? '';
            leadProvider.stateController.text = leadData.address3 ?? '';
            leadProvider.latitudeController.text = leadData.latitude ?? '';
            leadProvider.longitudeController.text = leadData.longitude ?? '';
            leadProvider.pincodeController.text = leadData.pinCode ?? '';
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
                leadData.inverterCapacity.toString() ?? '';
            leadProvider.projectCostController.text =
                leadData.projectCost.toString() ?? '';
            leadProvider.panelCapacityController.text =
                leadData.panelCapacity.toString() ?? '';
            leadProvider.additionalCostControler.text =
                leadData.additionalCost.toString() ?? '';
            leadProvider.advanceAmountController.text =
                leadData.advanceAmount.toString() ?? '';
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
                leadData.connectedLoad.toString();
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
            if (leadData.nextFollowUpDate.isNotEmpty) {
              leadProvider.followUpDateController.text =
                  leadData.nextFollowUpDate;
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
}
