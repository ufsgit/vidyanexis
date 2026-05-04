import 'package:flutter/material.dart';
import 'form_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';

class FormProvider extends ChangeNotifier {
  List<FormModel> _forms = [];
  List<FormModel> get forms => _forms;

  List<FormModel> _customerForms = [];
  List<FormModel> get customerForms => _customerForms;

  bool _isFetchingCustomerForms = false;
  bool get isFetchingCustomerForms => _isFetchingCustomerForms;
  set isFetchingCustomerForms(bool value) {
    _isFetchingCustomerForms = value;
    notifyListeners();
  }

  void clearForms() {
    _customerForms = [];
    _lastFetchedCustomerId = null;
    _lastFetchedTaskTypeId = null;
    _lastFetchedEnquiryForId = null;
    _lastFetchedTaskId = null;
    notifyListeners();
  }

  String searchQuery = "";

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> taskTypes = [];
  List<Map<String, dynamic>> customers = [];

  List<FieldModel> availableFields = [];

  bool isLoadingFields = false;
  bool isLoadingDepartments = false;
  bool isLoadingTaskTypes = false;
  bool isLoadingCustomers = false;

  void fetchDepartments(BuildContext context) async {
    isLoadingDepartments = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchDepartment}?Search_department=');
      if (response.statusCode == 200) {
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

  void fetchCustomers(BuildContext context) async {
    isLoadingCustomers = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=&Is_Date=0&Fromdate=&Todate=&To_User_Id=0&Status_Id=0&Page_Index1=1&Page_Index2=500');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          final list = List<dynamic>.from(data);
          // Last item is the total count sentinel — remove it
          if (list.isNotEmpty) list.removeLast();
          customers = list
              .map((item) => {
                    'id': item['Customer_Id'] ?? item['customer_id'],
                    'name':
                        (item['Customer_Name'] ?? item['customer_name'] ?? '')
                            .toString()
                  })
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchCustomers: $e');
    }
    isLoadingCustomers = false;
    notifyListeners();
  }

  void fetchTaskTypes(BuildContext context) async {
    isLoadingTaskTypes = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchTaskType}?Task_Type_Name=');
      if (response.statusCode == 200) {
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

  Future<void>? _activeFieldsFetch;

  Future<void> fetchAvailableFields([BuildContext? context]) async {
    if (isLoadingFields ||
        (availableFields.isNotEmpty && _activeFieldsFetch == null)) {
      return _activeFieldsFetch;
    }

    _activeFieldsFetch = _performFieldsFetch();
    return _activeFieldsFetch;
  }

  Future<void> _performFieldsFetch() async {
    isLoadingFields = true;
    notifyListeners();
    try {
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getCustomField);
      if (response.statusCode == 200) {
        final body = response.data;
        if (body != null) {
          final customFieldModelList = (body as List<dynamic>)
              .map((item) => CustomFieldModel.fromJson(item))
              .toList();

          availableFields =
              customFieldModelList.where((f) => f.deletedStatus != 1).map((cf) {
            FieldType type;
            switch (cf.customFieldTypeId) {
              case 1:
                type = FieldType.number;
                break;
              case 2:
                type = FieldType.text;
                break;
              case 3:
                type = FieldType.dropdown;
                break;
              case 4:
                type = FieldType.date;
                break;
              case 5:
                type = FieldType.checkbox;
                break;
              case 6:
                type = FieldType.file;
                break;
              case 7:
                type = FieldType.signature;
                break;
              default:
                type = FieldType.text;
            }
            final label = (cf.customFieldName ?? "Field ${cf.customFieldId}");
            return FieldModel(
              id: cf.customFieldId.toString(),
              label: label.isEmpty || label == "null"
                  ? "Field ${cf.customFieldId}"
                  : label,
              type: type,
              options: cf.dropDownValues,
              checkBoxOptions: cf.checkBoxValues,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchAvailableFields: $e');
    } finally {
      isLoadingFields = false;
      _activeFieldsFetch = null;
      notifyListeners();
    }
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
      if (response.statusCode == 200) {
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

          _forms = formsList
              .map((item) {
                List<FieldModel> parsedFields = [];
                if (item['Custom_Fields'] != null &&
                    item['Custom_Fields'] is List) {
                  parsedFields = (item['Custom_Fields'] as List).map((f) {
                    final cfId = (f['Custom_Field_Id'] ?? f['custom_field_id'])
                            ?.toString() ??
                        '0';
                    final cfName =
                        (f['Custom_Field_Name'] ?? f['custom_field_name'])
                            ?.toString();
                    final isMandatoryValue =
                        f['Is_Mandatory'] ?? f['isMandatory'];

                    final orderBy = f['Order_By'] ?? f['order_by'] ?? 0;

                    // Match by ID first, then by Label as a fallback to "repair" corrupted IDs
                    final availableField = availableFields.firstWhere(
                      (a) => a.id == cfId,
                      orElse: () => availableFields.firstWhere(
                        (a) =>
                            cfName != null &&
                            a.label.toLowerCase() == cfName.toLowerCase(),
                        orElse: () => FieldModel(
                          id: cfId,
                          label: cfName ?? 'Field $cfId',
                          type: FieldType.text,
                        ),
                      ),
                    );
                    return FieldModel(
                      id: availableField.id,
                      label: availableField.label.isEmpty ||
                              availableField.label == "null"
                          ? (cfName ?? "Field $cfId")
                          : availableField.label,
                      type: availableField.type,
                      options: availableField.options,
                      checkBoxOptions: availableField.checkBoxOptions,
                      isMandatory: (isMandatoryValue == 1 ||
                          isMandatoryValue == true ||
                          isMandatoryValue == "1"),
                      orderBy: int.tryParse(orderBy.toString()) ?? 0,
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
                  customerId: item['Customer_Id'],
                  fields: parsedFields,
                  taskId: item['Task_Id'] ?? item['task_id'],
                  deletedStatus: int.tryParse((item['Deleted_Status'] ??
                              item['deleted_status'] ??
                              0)
                          .toString()) ??
                      0,
                );
              })
              .where((f) => f.deletedStatus != 1)
              .toList();
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
        "Customer_Id": form.customerId ?? 0,
        "Custom_Fields": form.fields
            .map((f) => {
                  "Custom_Field_Id": int.tryParse(f.id) ?? 0,
                  "Is_Mandatory": f.isMandatory ? 1 : 0,
                  "Order_By": f.orderBy
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

  Future<void> updateForm(
      BuildContext context, String id, FormModel form) async {
    try {
      final payload = {
        "Form_Id": int.tryParse(id) ?? 0,
        "Form_Name": form.name,
        "Department_Id": form.departmentId,
        "Department_Name": form.department,
        "Task_Type_Id": form.taskTypeId,
        "Task_Type_Name": form.taskType,
        "Customer_Id": form.customerId ?? 0,
        "Custom_Fields": form.fields
            .map((f) => {
                  "Custom_Field_Id": int.tryParse(f.id) ?? 0,
                  "Is_Mandatory": f.isMandatory ? 1 : 0,
                  "Order_By": f.orderBy
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

  String? _lastFetchedCustomerId;
  String? _lastFetchedTaskTypeId;
  String? _lastFetchedEnquiryForId;
  String? _lastFetchedTaskId;
  int _currentFetchId = 0;
  Future<void>? _activeCustomerFetch;

  Future<void> getFormDataByCustomer(String customerId,
      {String? taskTypeId, String? enquiryForId, String? taskId}) async {
    // Avoid redundant fetches if parameters are identical
    if (_lastFetchedCustomerId == customerId &&
        _lastFetchedTaskTypeId == taskTypeId &&
        _lastFetchedEnquiryForId == enquiryForId &&
        _lastFetchedTaskId == taskId &&
        (_customerForms.isNotEmpty || isFetchingCustomerForms)) {
      debugPrint(
          "DEBUG: getFormDataByCustomer - skipping redundant or overlapping fetch");
      return _activeCustomerFetch;
    }

    _lastFetchedCustomerId = customerId;
    _lastFetchedTaskTypeId = taskTypeId;
    _lastFetchedEnquiryForId = enquiryForId;
    _lastFetchedTaskId = taskId;

    _currentFetchId++;
    final int fetchId = _currentFetchId;

    // Only clear and show spinner if we have no forms yet to prevent flicker
    // when data arrives from parallel sources like fetchTaskTypes.
    if (_customerForms.isEmpty) {
      _customerForms = [];
      isFetchingCustomerForms = true;
    } else {
      _isFetchingCustomerForms = true;
      notifyListeners();
    }

    _activeCustomerFetch =
        _performFetch(customerId, taskTypeId, enquiryForId, taskId, fetchId);
    return _activeCustomerFetch;
  }

  Future<void> _performFetch(String customerId, String? taskTypeId,
      String? enquiryForId, String? taskId, int fetchId) async {
    try {
      if (availableFields.isEmpty) {
        await fetchAvailableFields();
      }
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('userId') ?? "0";

      final Map<String, dynamic> queryParams = {
        "Customer_Id": customerId,
        "Login_User_Id": userId,
      };

      if (enquiryForId != null &&
          enquiryForId != "0" &&
          enquiryForId.isNotEmpty) {
        queryParams["Enquiry_For_Id"] = enquiryForId;
      }

      if (taskTypeId != null && taskTypeId.isNotEmpty && taskTypeId != "0") {
        queryParams["Task_Type_Id"] = taskTypeId;
      }

      if (taskId != null && taskId.isNotEmpty && taskId != "0") {
        queryParams["Task_Id"] = taskId;
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getFormDataDetails,
        bodyData: queryParams,
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          // If response is { "success": true, "data": { ... } } or { "success": true, "data": [ ... ] }
          // Only unwrap if the current map doesn't already contain the target form keys ('forms' or 'form_data')
          if (data is Map &&
              !data.containsKey('forms') &&
              !data.containsKey('form_data')) {
            if (data.containsKey('data') && data['data'] != null) {
              data = data['data'];
            } else if (data.containsKey('Data') && data['Data'] != null) {
              data = data['Data'];
            }
          }

          bool hasData = false;
          if (data is Map) {
            hasData = (data['forms'] is List && data['forms'].isNotEmpty) ||
                (data['form_data'] is List && data['form_data'].isNotEmpty);
          } else if (data is List) {
            hasData = data.isNotEmpty;
          }

          if (hasData) {
            if (fetchId == _currentFetchId) {
              _customerForms = _processCustomerFormsData(data);
              notifyListeners();
            }
          } else {
            if (fetchId == _currentFetchId) {
              // Only clear if we didn't already have forms (e.g. from fetchTaskTypes).
              // This prevents a race condition where history returns empty and kills the buttons.
              if (_customerForms.isEmpty) {
                _customerForms = [];
              }
              _isFetchingCustomerForms = false;
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Exception occurred in getFormDataByCustomer: $e');
    } finally {
      // Only reset loading state if this is the most recent request
      if (fetchId == _currentFetchId) {
        _isFetchingCustomerForms = false;
        _activeCustomerFetch = null;
        notifyListeners();
      }
    }
  }

  List<FormModel> _processCustomerFormsData(dynamic data) {
    if (data == null) return [];
    try {
      debugPrint("DEBUG: _processCustomerFormsData received data: $data");

      // Secondary check if data is wrapped here as well
      var processedData = data;
      // Only unwrap if the current map doesn't already contain the target form keys ('forms' or 'form_data')
      if (processedData is Map &&
          !processedData.containsKey('forms') &&
          !processedData.containsKey('form_data')) {
        if (processedData.containsKey('data') &&
            processedData['data'] != null) {
          processedData = processedData['data'];
        } else if (processedData.containsKey('Data') &&
            processedData['Data'] != null) {
          processedData = processedData['Data'];
        }
      }

      List<dynamic> formsList = [];
      if (processedData is Map) {
        var fForms = processedData['forms'];
        var fData = processedData['form_data'];

        // Merge both definitions and instances to provide a complete history in the tab
        if (fForms is List) formsList.addAll(fForms);
        if (fData is List) formsList.addAll(fData);
      } else if (processedData is List) {
        formsList = processedData;
      }

      return formsList
          .map((item) {
            List<FieldModel> parsedFields = [];

            if (item['Custom_Fields'] != null &&
                item['Custom_Fields'] is List) {
              parsedFields = (item['Custom_Fields'] as List).map((f) {
                final cfId = (f['Custom_Field_Id'] ?? f['custom_field_id'])
                        ?.toString() ??
                    '0';
                final cfName =
                    (f['Custom_Field_Name'] ?? f['custom_field_name'])
                        ?.toString();
                final isMandatoryValue = f['Is_Mandatory'] ?? f['isMandatory'];

                final availableField = availableFields.firstWhere(
                  (a) => a.id == cfId,
                  orElse: () => availableFields.firstWhere(
                    (a) =>
                        cfName != null &&
                        a.label.toLowerCase() == cfName.toLowerCase(),
                    orElse: () => FieldModel(
                      id: cfId,
                      label: cfName ?? 'Field $cfId',
                      type: FieldType.text,
                    ),
                  ),
                );

                final dataValue =
                    f['datavalue'] ?? f['DataValue'] ?? f['value'];
                final orderBy = f['Order_By'] ?? f['order_by'] ?? 0;

                return FieldModel(
                  id: availableField.id,
                  label: availableField.label.isEmpty ||
                          availableField.label == "null"
                      ? (cfName ?? 'Field $cfId')
                      : availableField.label,
                  type: availableField.type,
                  options: availableField.options,
                  checkBoxOptions: availableField.checkBoxOptions,
                  value: dataValue?.toString(),
                  isMandatory: (isMandatoryValue == 1 ||
                      isMandatoryValue == true ||
                      isMandatoryValue == "1"),
                  orderBy: int.tryParse(orderBy.toString()) ?? 0,
                );
              }).toList();
            }

            return FormModel(
              id: (item['Form_Id'] ?? item['form_id'] ?? '').toString(),
              name: (item['Form_Name'] ?? item['form_name'] ?? '').toString(),
              department:
                  (item['Department_Name'] ?? item['department_name'] ?? '')
                      .toString(),
              taskType: (item['Task_Type_Name'] ?? item['task_type_name'] ?? '')
                  .toString(),
              fields: parsedFields,
              instanceId:
                  item['Form_Data_Details_Id'] ?? item['form_data_details_id'],
              createdDate: (item['Created_Date'] ??
                      item['created_at'] ??
                      item['created_date'] ??
                      item['entry_date'] ??
                      item['Entry_Date'])
                  ?.toString(),
              createdUser: (item['created_user_name'] ??
                      item['Created_User_Name'] ??
                      item['created_by_name'] ??
                      item['Created_By_Name'] ??
                      item['user_name'])
                  ?.toString(),
              taskId: item['Task_Id'] ?? item['task_id'],
              deletedStatus: int.tryParse((item['Deleted_Status'] ??
                          item['deleted_status'] ??
                          item['Is_Delete'] ??
                          item['is_delete'] ??
                          0)
                      .toString()) ??
                  0,
            );
          })
          .where((f) => f.deletedStatus != 1)
          .toList();
    } catch (e) {
      debugPrint('Error in _processCustomerFormsData: $e');
      return [];
    }
  }

  // Deprecated - use internal processing
  void setCustomerForms(dynamic data) {
    _customerForms = _processCustomerFormsData(data);
    _isFetchingCustomerForms = false;
    notifyListeners();
  }

  Future<int?> saveTaskFormData({
    required BuildContext context,
    required int taskId,
    required int formId,
    required List<dynamic>
        customFields, // Keeping dynamic or Map for flexibility
    int formDataDetailsId = 0,
    int customerId = 0,
    String? taskTypeId,
    int? enquiryForId,
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
        int? resultId;
        if (response.data is Map) {
          debugPrint("DEBUG: Save status 200, response data: ${response.data}");

          final dataMap = response.data as Map;

          int? findIdFromMap(Map map) {
            Object? id = map['Form_Data_Details_Id'] ??
                map['itemID'] ??
                map['item_id'] ??
                map['Form_Data_Details_ID'] ??
                map['Form_data_details_id'];
            return id != null ? int.tryParse(id.toString()) : null;
          }

          resultId = findIdFromMap(dataMap);

          // Check for nested data fields if not found at top level
          if (resultId == null) {
            Object? nestedData = dataMap['data'] ?? dataMap['Data'];
            if (nestedData is Map) {
              resultId = findIdFromMap(nestedData);
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form data saved successfully')),
        );
        getFormDataByCustomer(customerId.toString(),
            taskTypeId: taskTypeId,
            enquiryForId: enquiryForId?.toString(),
            taskId: taskId.toString());

        debugPrint(
            "DEBUG: Determined resultId: $resultId (Original formDataDetailsId: $formDataDetailsId)");
        return resultId ?? (formDataDetailsId != 0 ? formDataDetailsId : null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save form data')),
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception occurred in saveTaskFormData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  bool isPrinting = false;
  Future<void> fetchAndPrintFormPdf({
    required BuildContext context,
    required String customerId,
    required int formDataDetailsId,
    int? taskId,
  }) async {
    debugPrint(
        "DEBUG: fetchAndPrintFormPdf called for customer: $customerId, FormDataDetailsId: $formDataDetailsId, taskId: $taskId");
    isPrinting = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getFormPrintPdf,
        bodyData: {
          "customerId": customerId,
          "Form_Data_Details_Id": formDataDetailsId,
        },
        returnBytes: true,
      );

      debugPrint(
          "DEBUG: fetchAndPrintFormPdf response status: ${response.statusCode}");
      debugPrint(
          "DEBUG: fetchAndPrintFormPdf data type: ${response.data.runtimeType}");

      if (response.statusCode == 200) {
        final Uint8List pdfBytes = response.data is Uint8List
            ? response.data
            : Uint8List.fromList(response.data.toString().codeUnits);
        debugPrint("DEBUG: fetchAndPrintFormPdf got ${pdfBytes.length} bytes");

        if (pdfBytes.isEmpty) {
          debugPrint("DEBUG: PDF bytes are empty!");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Received empty PDF from server')),
            );
          }
          return;
        }

        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Form_$formDataDetailsId.pdf',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch PDF')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error in fetchAndPrintFormPdf: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while printing')),
        );
      }
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }
}
