import 'package:flutter/material.dart';
import 'form_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';

class FormProvider extends ChangeNotifier {
  List<FormModel> _forms = [];
  List<FormModel> get forms => _forms;

  List<FormModel> _customerForms = [];
  List<FormModel> get customerForms => _customerForms;

  String searchQuery = "";

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> taskTypes = [];

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
              .map((item) => {
                    'id': item['Department_Id'],
                    'name': item['Department_Name'].toString()
                  })
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
          final List<dynamic> tList = data as List<dynamic>;
          taskTypes = tList
              .map((item) => {
                    'id': item['Task_Type_Id'],
                    'name': item['Task_Type_Name'].toString()
                  })
              .toList();
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
            final label = (cf.customFieldName ?? "Field ${cf.customFieldId}");
            return FieldModel(
              id: cf.customFieldId.toString(),
              label: label.isEmpty || label == "null" ? "Field ${cf.customFieldId}" : label,
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
                final cfId =
                    (f['Custom_Field_Id'] ?? f['custom_field_id'])?.toString() ??
                        '0';
                final cfName =
                    (f['Custom_Field_Name'] ?? f['custom_field_name'])?.toString();
                final isMandatoryValue = f['Is_Mandatory'] ?? f['isMandatory'];

                // Match by ID first, then by Label as a fallback to "repair" corrupted IDs
                final availableField = availableFields.firstWhere(
                  (a) => a.id == cfId,
                  orElse: () => availableFields.firstWhere(
                    (a) => cfName != null && a.label.toLowerCase() == cfName.toLowerCase(),
                    orElse: () => FieldModel(
                      id: cfId,
                      label: cfName ?? 'Field $cfId',
                      type: FieldType.text,
                    ),
                  ),
                );
                return FieldModel(
                  id: availableField.id,
                  label: availableField.label.isEmpty || availableField.label == "null" 
                      ? (cfName ?? "Field $cfId") 
                      : availableField.label,
                  type: availableField.type,
                  options: availableField.options,
                  isMandatory: (isMandatoryValue == 1 ||
                      isMandatoryValue == true ||
                      isMandatoryValue == "1"),
                );
              }).toList();
            }

            return FormModel(
              id: item['Form_Id']?.toString() ?? '',
              name: item['Form_Name']?.toString() ?? '',
              department: item['Department_Name']?.toString() ?? '',
              departmentId: item['Department_Id'],
              taskType: item['Task_Type_Name']?.toString() ?? '',
              taskTypeId: item['Task_Type_Id'],
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
        "Form_Id": 0, // Use 0 for new forms
        "Form_Name": form.name,
        "Department_Id": form.departmentId,
        "Department_Name": form.department,
        "Task_Type_Id": form.taskTypeId,
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

  Future<void> updateForm(BuildContext context, String id, FormModel form) async {
    try {
      final payload = {
        "Form_Id": int.tryParse(id) ?? 0,
        "Form_Name": form.name,
        "Department_Id": form.departmentId,
        "Department_Name": form.department,
        "Task_Type_Id": form.taskTypeId,
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
        final index = _forms.indexWhere((e) => e.id == id);
        if (index != -1) {
          _forms[index] = form;
        }
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form updated successfully')),
        );
        fetchForms(context); // Refresh from server
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update form')),
        );
      }
    } catch (e) {
      debugPrint('Exception in updateForm: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while updating')),
      );
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

  Future<void> getFormDataByCustomer(String customerId,
      {String? taskTypeId, String? enquiryForId}) async {
    isLoadingForms = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('userId') ?? "0";

      final Map<String, dynamic> queryParams = {
        "Customer_Id": customerId,
        "Login_User_Id": userId,
      };

      if (enquiryForId != null && enquiryForId != "0" && enquiryForId.isNotEmpty) {
        queryParams["Enquiry_For_Id"] = enquiryForId;
      }

      if (taskTypeId != null && taskTypeId.isNotEmpty && taskTypeId != "0") {
        queryParams["Task_Type_Id"] = taskTypeId;
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getFormDataDetails,
        bodyData: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          bool hasData = false;
          if (data is Map) {
            hasData = (data['forms'] is List && data['forms'].isNotEmpty) ||
                      (data['form_data'] is List && data['form_data'].isNotEmpty) ||
                      (data['data'] is List && data['data'].isNotEmpty);
          } else if (data is List) {
            hasData = data.isNotEmpty;
          }

          if (hasData) {
            setCustomerForms(data);
          }
        }
      }
    } catch (e) {
      debugPrint('Exception occurred in getFormDataByCustomer: $e');
    } finally {
      isLoadingForms = false;
      notifyListeners();
    }
  }

  void setCustomerForms(dynamic data) {
    if (data == null) return;
    try {
      debugPrint("DEBUG: setCustomerForms received data: $data");
      List<dynamic> formsList = [];
      if (data is Map) {
        var fForms = data['forms'];
        var fData = data['form_data'] ?? data['data'];

        if (fForms is List && fForms.isNotEmpty) {
          formsList = fForms;
        } else if (fData is List && fData.isNotEmpty) {
          formsList = fData;
        }
      } else if (data is List) {
        formsList = data;
      }

      debugPrint("DEBUG: parsed formsList size: ${formsList.length}");

      _customerForms = formsList.map((item) {
        List<FieldModel> parsedFields = [];
        // ...
        if (item['Custom_Fields'] != null && item['Custom_Fields'] is List) {
          parsedFields = (item['Custom_Fields'] as List).map((f) {
            // Try both PascalCase and snake_case keys as seen in user's JSON
            final cfId =
                (f['Custom_Field_Id'] ?? f['custom_field_id'])?.toString() ??
                    '0';
            final cfName =
                (f['Custom_Field_Name'] ?? f['custom_field_name'])?.toString();
            final isMandatoryValue = f['Is_Mandatory'] ?? f['isMandatory'];

            // Match by ID first, then by Label as a fallback to "repair" corrupted IDs
            final availableField = availableFields.firstWhere(
              (a) => a.id == cfId,
              orElse: () => availableFields.firstWhere(
                (a) => cfName != null && a.label.toLowerCase() == cfName.toLowerCase(),
                orElse: () => FieldModel(
                  id: cfId,
                  label: cfName ?? 'Field $cfId',
                  type: FieldType.text,
                ),
              ),
            );
            return FieldModel(
              id: availableField.id,
              label: availableField.label.isEmpty || availableField.label == "null"
                  ? (cfName ?? 'Field $cfId')
                  : availableField.label,
              type: availableField.type,
              options: availableField.options,
              isMandatory: (isMandatoryValue == 1 ||
                  isMandatoryValue == true ||
                  isMandatoryValue == "1"),
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
      
      isLoadingForms = false; // Reset loading state when forms are set
      notifyListeners();
      debugPrint("DEBUG: customerForms updated, size: ${_customerForms.length}");
    } catch (e) {
      debugPrint('Error in setCustomerForms: $e');
    }
  }

  Future<void> saveTaskFormData({
    required BuildContext context,
    required int taskId,
    required int formId,
    required List<dynamic> customFields, // Keeping dynamic or Map for flexibility
    int formDataDetailsId = 0,
    int customerId = 0,
    String? taskTypeId,
  }) async {
    try {
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveTaskFormData,
          bodyData: {
            "Form_Data_Details_Id": formDataDetailsId,
            "Form_Id": formId,
            "Customer_Id": customerId,
            "Custom_Fields": customFields,
          });

      if (response != null && response.statusCode == 200) {
        Navigator.pop(context); // Close the form fields dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form data saved successfully')),
        );
        getFormDataByCustomer(customerId.toString(), taskTypeId: taskTypeId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save form data')),
        );
      }
    } catch (e) {
      debugPrint('Exception occurred in saveTaskFormData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }
}
