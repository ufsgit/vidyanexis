import 'package:flutter/material.dart';
import 'form_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';

class FormProvider extends ChangeNotifier {
  List<FormModel> _forms = [];
  List<FormModel> get forms => _forms;

  String searchQuery = "";

  List<String> departments = [];

  List<String> taskTypes = [];

  List<FieldModel> availableFields = [];

  bool isLoadingFields = false;
  bool isLoadingDepartments = false;
  bool isLoadingTaskTypes = false;

  void fetchDepartments(BuildContext context) async {
    isLoadingDepartments = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchDepartment}?Search_department=');
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          final List<dynamic> departmentList = data['data'][0];
          departments = departmentList
              .map((item) => item['Department_Name'].toString())
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchDepartments: $e');
    }
    isLoadingDepartments = false;
    notifyListeners();
  }

  void fetchTaskTypes(BuildContext context) async {
    isLoadingTaskTypes = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchTaskType}?Task_Type_Name=');
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final List<dynamic> tList = data as List<dynamic>;
          taskTypes =
              tList.map((item) => item['Task_Type_Name'].toString()).toList();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchTaskTypes: $e');
    }
    isLoadingTaskTypes = false;
    notifyListeners();
  }

  Future<void> fetchAvailableFields(BuildContext context) async {
    isLoadingFields = true;
    notifyListeners();
    try {
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getCustomField);
      if (response != null && response.statusCode == 200) {
        final body = response.data;
        if (body != null) {
          final customFieldModelList = (body as List<dynamic>)
              .map((item) => CustomFieldModel.fromJson(item))
              .toList();

          availableFields =
              customFieldModelList.where((f) => f.deletedStatus != 1).map((cf) {
            FieldType type;
            switch (cf.customFieldTypeId) {
              case 2:
                type = FieldType.number;
                break;
              case 3:
                type = FieldType.dropdown;
                break;
              case 4:
                type = FieldType.date;
                break;
              default:
                type = FieldType.text;
            }
            return FieldModel(
              id: cf.customFieldId.toString(),
              label: cf.customFieldName ?? "Unknown",
              type: type,
              options: cf.dropDownValues,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchAvailableFields: $e');
    }
    isLoadingFields = false;
    notifyListeners();
  }

  bool isLoadingForms = false;

  Future<void> fetchForms(BuildContext context) async {
    isLoadingForms = true;
    notifyListeners();

    if (availableFields.isEmpty) {
      await fetchAvailableFields(context);
    }
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchFormData}?Form_Name=');
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<dynamic> formsList = [];
          if (data is List) {
            formsList = data;
          } else if (data is Map && data.containsKey('data')) {
            var nestedData = data['data'];
            if (nestedData is List &&
                nestedData.isNotEmpty &&
                nestedData[0] is List) {
              formsList = nestedData[0];
            } else if (nestedData is List) {
              formsList = nestedData;
            }
          }

          _forms = formsList.map((item) {
            List<FieldModel> parsedFields = [];
            if (item['Custom_Fields'] != null &&
                item['Custom_Fields'] is List) {
              parsedFields = (item['Custom_Fields'] as List).map((f) {
                final cfId = f['Custom_Field_Id'].toString();
                final availableField = availableFields.firstWhere(
                  (a) => a.id == cfId,
                  orElse: () => FieldModel(
                    id: cfId,
                    label: f['Custom_Field_Name']?.toString() ?? 'Field $cfId',
                    type: FieldType.text,
                  ),
                );
                return FieldModel(
                  id: availableField.id,
                  label: availableField.label,
                  type: availableField.type,
                  options: availableField.options,
                  isMandatory:
                      (f['Is_Mandatory'] == 1 || f['Is_Mandatory'] == true),
                );
              }).toList();
            }

            return FormModel(
              id: item['Form_Id']?.toString() ?? '',
              name: item['Form_Name']?.toString() ?? '',
              department: item['Department_Name']?.toString() ?? '',
              taskType: item['Task_Type_Name']?.toString() ?? '',
              fields: parsedFields,
            );
          }).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchForms: $e');
    }
    isLoadingForms = false;
    notifyListeners();
  }

  Future<void> addForm(BuildContext context, FormModel form) async {
    try {
      final payload = {
        "Form_Name": form.name,
        "Department_Name": form.department,
        "Task_Type_Name": form.taskType,
        "Custom_Fields": form.fields
            .map((f) => {
                  "Custom_Field_Id": int.tryParse(f.id) ?? 0,
                  "Is_Mandatory": f.isMandatory ? 1 : 0
                })
            .toList(),
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveFormData,
        bodyData: payload,
      );

      if (response != null && response.statusCode == 200) {
        _forms.add(form);
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save form')),
        );
      }
    } catch (e) {
      debugPrint('Exception in addForm: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void updateForm(String id, FormModel updatedForm) {
    // Currently relying on local state update for edits
    final index = _forms.indexWhere((e) => e.id == id);
    if (index != -1) {
      _forms[index] = updatedForm;
      notifyListeners();
    }
  }

  void deleteForm(String id) {
    _forms.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  List<FormModel> get filteredForms {
    if (searchQuery.isEmpty) return _forms;
    return _forms
        .where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }
}
