import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/document_list_model.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/process_flow_model.dart';
import 'package:vidyanexis/controller/models/task_document_model.dart';
import 'package:vidyanexis/controller/models/task_flow_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/utils/util_functions.dart';

class ProcessFlowProvider extends ChangeNotifier {
  ProcessFlowModel processFlowModel = ProcessFlowModel();
  List<TaskFlowModel> taskFlowList = [];
  List<MandatoryTaskModel> mandatoryTaskList = [];
  TaskFlowModel taskFlowModel = TaskFlowModel();
  MandatoryTaskModel mandatoryTaskModel = MandatoryTaskModel();
  List<ProcessFlowModel> processFlowFilteredList = [];
  List<ProcessFlowModel> processFlowList = [];

  void filterData(String searchText) {
    processFlowFilteredList = processFlowList
        .where((element) => element.taskTypeName!
            .toLowerCase()
            .startsWith(searchText.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void clearData() {
    processFlowModel = ProcessFlowModel();
    taskFlowList = [];
    mandatoryTaskList = [];
    taskFlowModel = TaskFlowModel();
    mandatoryTaskModel = MandatoryTaskModel();
    _selectedDocuments = [];
  }

  void removeTaskFlow(int index) {
    taskFlowList.removeAt(index);
  }

  void updateTaskFlow(int index, TaskFlowModel value) {
    if (index == -1) {
      taskFlowList.add(value);
    } else {
      taskFlowList[index] = value;
    }
  }

  void removeMandatory(int index) {
    mandatoryTaskList.removeAt(index);
  }

  void updateMandatoryTask(int index, MandatoryTaskModel value) {
    if (index == -1) {
      mandatoryTaskList.add(value);
    } else {
      mandatoryTaskList[index] = value;
    }
  }

  void setTaskFlowModel(TaskFlowModel value) {
    taskFlowModel = value.copyWith();
    notifyListeners();
  }

  void setMandatoryTaskModel(MandatoryTaskModel value) {
    mandatoryTaskModel = value.copyWith();
    notifyListeners();
  }

  void setProcessFlowModel(ProcessFlowModel value) {
    processFlowModel = value;
  }

  Future<
      (
        List<TaskTypeModel>,
        List<TaskTypeStatusModel>,
        List<DepartmentModel>,
        List<BranchModel>,
        List<DocumentTypeModel>,
        List<EnquiryForModel>
      )> getAllTskTypeStatus(BuildContext context) async {
    List<TaskTypeModel> taskTypeList = [];
    List<TaskTypeStatusModel> taskTypeStatusList = [];
    List<DepartmentModel> departmentList = [];
    List<BranchModel> branchList = [];
    List<DocumentTypeModel> documentTypeList = [];
    List<EnquiryForModel> enquiryForList = [];
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getProcessFlowData);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.isNotEmpty && data["success"]) {
          var taskTypeData = data["data"]["task_type"] as List;
          var departmentData = data["data"]["department"] as List;
          var branchData = data["data"]["branch"] as List;
          var taskTypeStatusData = data["data"]["task_type_status"] as List;
          var documentTypeData = data["data"]["document"] as List;
          var enquiryForData = data["data"]["enquiry_for"] as List;
          taskTypeList =
              taskTypeData.map((item) => TaskTypeModel.fromJson(item)).toList();
          taskTypeStatusList = taskTypeStatusData
              .map((item) => TaskTypeStatusModel.fromJson(item))
              .toList();
          departmentList = departmentData
              .map((item) => DepartmentModel.fromJson(item))
              .toList();
          branchList =
              branchData.map((item) => BranchModel.fromJson(item)).toList();
          branchList.insert(
              0,
              BranchModel(
                branchId: 0,
                branchName: "Customer branch",
              ));
          documentTypeList = documentTypeData
              .map((item) => DocumentTypeModel.fromJson(item))
              .toList();
          enquiryForList = enquiryForData
              .map((item) => EnquiryForModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
    return (
      taskTypeList,
      taskTypeStatusList,
      departmentList,
      branchList,
      documentTypeList,
      enquiryForList
    );
  }

  Future<List<ProcessFlowModel>> getProcessFlow(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getAllProcessFlow);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey("success") && data["success"]) {
          processFlowFilteredList = (data["data"] as List<dynamic>)
              .map((item) => ProcessFlowModel.fromJson(item))
              .toList();
          processFlowList = processFlowFilteredList;
          notifyListeners();
        }
        return processFlowFilteredList;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        return processFlowFilteredList;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return processFlowFilteredList;
    }
  }

  Future deleteProcessFlowById(BuildContext context, int flowId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteProcessFlowById,
          bodyData: {"flow_id": flowId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['department_id'] == -1) {
          Loader.stopLoader(context);
        } else {
          showFriendlySnackBar(context, 'Process flow deleted successfully');
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Process flow')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<List<TaskTypeModel>> getTaskTypeByDepartment(
      BuildContext context, String departmentId) async {
    List<TaskTypeModel> taskList = [];
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getTaskTypeByDepartment}/$departmentId");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey("success") && data["success"]) {
          taskList = (data["data"] as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();
          notifyListeners();
        }
        return taskList;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        return taskList;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return taskList;
    }
  }

  Future<List<ProcessFlowModel>> getProcessFlowById(
      BuildContext context, int flowId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getProcessFlowById}/$flowId");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey("success") && data["success"]) {
          final data = response.data as Map<String, dynamic>;

          var flowData = data["data"]["flow_tasks"] as List;
          var mandatoryData = data["data"]["mandatory_tasks"] ?? [];
          var documentsData = data["data"]["flow_documents"] ?? [];
          int taskTypeId = data["data"]["task_type_id"];

          taskFlowList =
              flowData.map((item) => TaskFlowModel.fromJson(item)).toList();
          if (mandatoryData.isNotEmpty) {
            mandatoryTaskList = (mandatoryData as List)
                .map((item) => MandatoryTaskModel.fromJson(item))
                .toList();
          }
          _selectedDocuments = (documentsData as List)
              .map((item) => DocumentTypeModel.fromJson(item))
              .toList();
          print(documentsData);

          // departmentList = departmentData
          //     .map((item) => DepartmentModel.fromJson(item))
          //     .toList();
          // branchList =
          //     branchData.map((item) => BranchModel.fromJson(item)).toList();
          // branchList.insert(
          //     0,
          //     BranchModel(
          //       branchId: 0,
          //       branchName: "Customer branch",
          //     ));
          notifyListeners();
        }
        return processFlowFilteredList;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        return processFlowFilteredList;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return processFlowFilteredList;
    }
  }

  Future<(bool, String)> saveFollowUp(BuildContext context) async {
    try {
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveProcessFlow,
          bodyData: {
            "task_type_id": processFlowModel.taskTypeId,
            "flow_id": processFlowModel.flowId ?? 0,
            "status_id": processFlowModel.statusId,
            "enquiry_for_id": processFlowModel.enquiryForId ?? 0,
            "enquiry_for_name": processFlowModel.enquiryForName ?? '',
            "flow_tasks": taskFlowList.map((item) => item.toJson()).toList(),
            "mandatory_tasks":
                mandatoryTaskList.map((item) => item.toJson()).toList(),
            "documents":
                _selectedDocuments.map((item) => item.toJson()).toList(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        int flowId = 0;
        if (data != null) {
          String message = "";
          bool isError = data["Error"] == 1;
          if (isError) {
            message = data["Message"];
          } else {
            flowId = data["Flow_Id"];
          }
          return (flowId > 0, message);
        } else {
          return (false, "Failed to save process flow");
        }
      } else {
        return (false, "Failed to save process flow");
      }
    } catch (e) {
      return (false, "An error occurred");
    }
  }

  List<DocumentTypeModel> _selectedDocuments = [];
  List<DocumentTypeModel> get selectedDocuments => _selectedDocuments;

  void toggleDocumentSelection(DocumentTypeModel doc) {
    if (_selectedDocuments.any((d) => d.documentTypeId == doc.documentTypeId)) {
      _selectedDocuments
          .removeWhere((d) => d.documentTypeId == doc.documentTypeId);
    } else {
      _selectedDocuments.add(doc);
    }
    print(_selectedDocuments.map((item) => item.toJson()).toList());
    notifyListeners();
  }
}
