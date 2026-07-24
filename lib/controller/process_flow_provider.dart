import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/process_flow_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/task_flow_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';

class ProcessFlowProvider extends ChangeNotifier {
  ProcessFlowModel processFlowModel = ProcessFlowModel();
  List<TaskFlowModel> taskFlowList = [];
  List<MandatoryTaskModel> mandatoryTaskList = [];
  TaskFlowModel taskFlowModel = TaskFlowModel();
  MandatoryTaskModel mandatoryTaskModel = MandatoryTaskModel();
  List<ProcessFlowModel> processFlowFilteredList = [];
  List<ProcessFlowModel> processFlowList = [];
  List<Map<String, dynamic>> savedCustomFields = [];
  List<CustomFieldModel> showCustomFields = [];
  List<TaskTypeStatusModel> dynamicTaskTypeStatusList = [];
  bool isLoadingTaskTypeStatuses = false;

  int? _selectedEnquiryForId;
  int? get selectedEnquiryForId => _selectedEnquiryForId;
  void setEnquiryForFilter(int? id) {
    _selectedEnquiryForId = id;
    notifyListeners();
  }

  int? _selectedEnquirySourceId;
  int? get selectedEnquirySourceId => _selectedEnquirySourceId;
  void setEnquirySourceFilter(int? id) {
    _selectedEnquirySourceId = id;
    notifyListeners();
  }

  void filterData(String searchText) {
    processFlowFilteredList = processFlowList.where((element) {
      final matchesSearch = searchText.isEmpty ||
          (element.taskTypeName ?? '')
              .toLowerCase()
              .startsWith(searchText.toLowerCase());
      final matchesEnquiry = _selectedEnquiryForId == null ||
          _selectedEnquiryForId == 0 ||
          element.enquiryForId == _selectedEnquiryForId;
      return matchesSearch && matchesEnquiry;
    }).toList();
    notifyListeners();
  }

  bool _showLeadStatus = false;
  bool get showLeadStatus => _showLeadStatus;
  set showLeadStatus(bool value) {
    _showLeadStatus = value;
    notifyListeners();
  }

  void clearData() {
    processFlowModel = ProcessFlowModel();
    taskFlowList = [];
    mandatoryTaskList = [];
    taskFlowModel = TaskFlowModel();
    mandatoryTaskModel = MandatoryTaskModel();
    _selectedDocuments = [];
    savedCustomFields = [];
    showCustomFields = [];
    dynamicTaskTypeStatusList = [];
    isLoadingTaskTypeStatuses = false;
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
        List<EnquiryForModel>,
        List<SearchLeadStatusModel>,
      )> getAllTskTypeStatus(BuildContext context) async {
    List<TaskTypeModel> taskTypeList = [];
    List<TaskTypeStatusModel> taskTypeStatusList = [];
    List<DepartmentModel> departmentList = [];
    List<BranchModel> branchList = [];
    List<DocumentTypeModel> documentTypeList = [];
    List<EnquiryForModel> enquiryForList = [];
    List<SearchLeadStatusModel> searchLeadStatusList = [];
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getProcessFlowData);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.isNotEmpty && data["success"] == true) {
          var taskTypeData = (data["data"]?["task_type"] as List?) ?? [];
          var departmentData = (data["data"]?["department"] as List?) ?? [];
          var branchData = (data["data"]?["branch"] as List?) ?? [];
          var taskTypeStatusData = (data["data"]?["task_type_status"] as List?) ?? [];
          var documentTypeData = (data["data"]?["document"] as List?) ?? [];
          var enquiryForData = (data["data"]?["enquiry_for"] as List?) ?? [];
          var searchLeadStatusData = (data["data"]?["search_lead_status"] as List?) ?? [];
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
          searchLeadStatusList = searchLeadStatusData
              .map((item) => SearchLeadStatusModel.fromJson(item))
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
      enquiryForList,
      searchLeadStatusList,
    );
  }

  Future<List<TaskTypeStatusModel>> getStatusAndSubStatusByTaskType(
      BuildContext context, int taskTypeId) async {
    isLoadingTaskTypeStatuses = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              "${HttpUrls.getStatusAndSubStatusByTaskType}?Task_Type_Id=$taskTypeId");

      if (response.statusCode == 200) {
        final rawData = response.data;
        if (rawData is List) {
          List<Map<String, dynamic>> statusData = [];
          for (var item in rawData) {
            if (item is Map) {
              statusData.add(Map<String, dynamic>.from(item));
            }
          }

          dynamicTaskTypeStatusList = statusData.map((item) {
            var model = TaskTypeStatusModel.fromJson(item);
            model.subStatuses = []; // Disable secondary dropdown
            return model;
          }).toList();

          return dynamicTaskTypeStatusList;
        } else if (rawData is Map) {
          final rawMap = Map<String, dynamic>.from(rawData);
          if (rawMap.containsKey("success") && rawMap["success"] == true) {
            var taskTypeStatusData = (rawMap["data"] as List?) ?? [];
            List<Map<String, dynamic>> statusData = [];
            for (var item in taskTypeStatusData) {
              if (item is Map) {
                statusData.add(Map<String, dynamic>.from(item));
              }
            }

            dynamicTaskTypeStatusList = statusData.map((item) {
              var model = TaskTypeStatusModel.fromJson(item);
              model.subStatuses = []; // Disable secondary dropdown
              return model;
            }).toList();
            return dynamicTaskTypeStatusList;
          }
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      isLoadingTaskTypeStatuses = false;
      notifyListeners();
    }
    return [];
  }

  Future<List<ProcessFlowModel>> getProcessFlow(BuildContext context) async {
    try {
      // Build endpoint – optionally append enquiry_source_id for server-side filtering
      String endpoint = HttpUrls.getAllProcessFlow;
      if (_selectedEnquirySourceId != null && _selectedEnquirySourceId != 0) {
        endpoint = '$endpoint?enquiry_source_id=$_selectedEnquirySourceId';
      }

      final response = await HttpRequest.httpGetRequest(endPoint: endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey("success") && data["success"] == true) {
          var rawFlows = data["data"] as List<dynamic>? ?? [];
          processFlowFilteredList = rawFlows
              .where((item) => item != null)
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

      Loader.stopLoader(context);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        // Refresh the list after successful delete
        await getProcessFlow(context);
        showFriendlySnackBar(context, 'Process flow deleted successfully');
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Process flow')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
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

        if (data.containsKey("success") && data["success"] == true) {
          var rawTasks = data["data"] as List<dynamic>? ?? [];
          taskList = rawTasks
              .where((item) => item != null)
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

        if (data.containsKey("success") && data["success"] == true) {
          final resData = data["data"] as Map<String, dynamic>?;

          if (resData != null) {
            var flowData = (resData["flow_tasks"] as List?) ?? [];
            var mandatoryData = (resData["mandatory_tasks"] as List?) ?? [];
            var documentsData = (resData["flow_documents"] as List?) ?? [];

            var rawCustomFields = resData["custom_fields"] ??
                resData["flow_custom_fields"] ??
                resData["custom_field"];
            var customFieldsData = (rawCustomFields as List?) ?? [];

            int? taskTypeId = resData["task_type_id"] != null
                ? int.tryParse(resData["task_type_id"].toString())
                : null;
            if (taskTypeId != null) {
              processFlowModel.taskTypeId = taskTypeId;
            }

            taskFlowList = flowData
                .where((item) => item != null)
                .map((item) => TaskFlowModel.fromJson(item))
                .toList();

            savedCustomFields = customFieldsData
                .where((item) => item is Map)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();

            if (mandatoryData.isNotEmpty) {
              mandatoryTaskList = mandatoryData
                  .where((item) => item != null)
                  .map((item) => MandatoryTaskModel.fromJson(item))
                  .toList();
            } else {
              mandatoryTaskList = [];
            }

            _selectedDocuments = documentsData
                .where((item) => item != null)
                .map((item) => DocumentTypeModel.fromJson(item))
                .toList();

            processFlowModel.templateId = resData["template_id"]?.toString();

            if (resData["lead_status_id"] != null) {
              processFlowModel.leadStatusId =
                  int.tryParse(resData["lead_status_id"].toString());
            }
            processFlowModel.leadStatusName =
                resData["lead_status_name"]?.toString();

            if (resData["task_sub_status_id"] != null) {
              processFlowModel.taskSubStatusId =
                  int.tryParse(resData["task_sub_status_id"].toString());
            }
            processFlowModel.taskSubStatusName =
                resData["task_sub_status_name"]?.toString();

            if (resData["lead_sub_status_id"] != null) {
              processFlowModel.leadSubStatusId =
                  int.tryParse(resData["lead_sub_status_id"].toString());
            }
            processFlowModel.leadSubStatusName =
                resData["lead_sub_status_name"]?.toString();

            if (resData["enquiry_for_id"] != null) {
              processFlowModel.enquiryForId =
                  int.tryParse(resData["enquiry_for_id"].toString());
            }
            if (resData["enquiry_for_name"] != null) {
              processFlowModel.enquiryForName =
                  resData["enquiry_for_name"]?.toString();
            }

            _showLeadStatus = resData["Show_Lead_Status"]?.toString() == "1" ||
                resData["show_lead_status"]?.toString() == "1";

            var rawShowCustomFields = resData["show_custom_fields"] ??
                resData["show_custom_field"];
            var showCustomFieldsData = (rawShowCustomFields as List?) ?? [];

            showCustomFields = showCustomFieldsData
                .where((item) => item != null)
                .map((item) => CustomFieldModel.fromJson(item))
                .toList();
          }

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
      print('Exception occurred in getProcessFlowById: $e');
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
            "template_id": processFlowModel.templateId ?? '',
            "flow_tasks": taskFlowList.map((item) => item.toJson()).toList(),
            "mandatory_tasks":
                mandatoryTaskList.map((item) => item.toJson()).toList(),
            "documents":
                _selectedDocuments.map((item) => item.toJson()).toList(),
            "custom_fields": savedCustomFields,
            "custom_field": savedCustomFields,
            "show_custom_fields": showCustomFields
                .map((item) => {
                      "custom_field_id": item.customFieldId,
                      "custom_field_name": item.customFieldName,
                      "is_checked": item.isChecked ?? 0,
                    })
                .toList(),
            "show_custom_field": showCustomFields
                .map((item) => {
                      "custom_field_id": item.customFieldId,
                      "custom_field_name": item.customFieldName,
                      "is_checked": item.isChecked ?? 0,
                    })
                .toList(),
            "lead_status_id": processFlowModel.leadStatusId ?? 0,
            "lead_status_name": processFlowModel.leadStatusName ?? '',
            "lead_sub_status_id": processFlowModel.leadSubStatusId ?? 0,
            "lead_sub_status_name": processFlowModel.leadSubStatusName ?? '',
            "task_sub_status_id": processFlowModel.taskSubStatusId ?? 0,
            "task_sub_status_name": processFlowModel.taskSubStatusName ?? '',
            "Show_Lead_Status": _showLeadStatus ? "1" : "0",
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
