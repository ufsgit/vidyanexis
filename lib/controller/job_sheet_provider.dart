import 'dart:ui';
import 'package:vidyanexis/controller/models/job_sheet_model.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class JobSheetProvider extends ChangeNotifier {
  // Task ID (should be provided when creating job sheet)
  int taskId = 0;
  int jobSheetId = 0;

  // Dropdown data
  List<DropdownItem<int>> serviceTypes = [
    DropdownItem(id: 1, name: "Routine Maintenance"),
    DropdownItem(id: 2, name: "Complaint Visit"),
    DropdownItem(id: 3, name: "Follow-up"),
  ];

  List<DropdownItem<int>> satisfactionLevels = [
    DropdownItem(id: 1, name: "Excellent"),
    DropdownItem(id: 2, name: "Good"),
    DropdownItem(id: 3, name: "Average"),
    DropdownItem(id: 4, name: "Poor"),
  ];

  List<DropdownItem<int>> scheduleDateTypes = [
    DropdownItem(id: 1, name: "Quarterly"),
    DropdownItem(id: 2, name: "Half-Yearly"),
    DropdownItem(id: 3, name: "Annual"),
  ];

  // Controllers
  final TextEditingController serviceTypeController = TextEditingController();
  final TextEditingController selectedSatisfactionName =
      TextEditingController();
  final TextEditingController selectedScheduleDateName =
      TextEditingController();
  final TextEditingController weatherConditionController =
      TextEditingController();
  final TextEditingController actionTakenController = TextEditingController();
  final TextEditingController nextScheduledDateController =
      TextEditingController();
  final TextEditingController satisfactionController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController observationController = TextEditingController();
  final TextEditingController nextMeterReadingController =
      TextEditingController();
  final TextEditingController techniController = TextEditingController();
  final TextEditingController technicianSignatureDate = TextEditingController();
  final TextEditingController customerSignatureDate = TextEditingController();

  // Selected values
  int? selectedServiceType;
  int? selectedSatisfactionId;
  int? selectedScheduleDateType;

  String _customerSignatureImage = '';
  String get customerSignatureImage => _customerSignatureImage;
  String _technicianSignatureImage = '';
  String get technicianSignatureImage => _technicianSignatureImage;

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<JobSheetData> _jobSheet = [];
  List<JobSheetData> get jobSheet => _jobSheet;

  void setSignature(String customerSign, String serviceEngSign) {
    _customerSignatureImage = customerSign;
    _technicianSignatureImage = serviceEngSign;
  }

  // System Performance Checks
  List<SystemComponentCheck> systemCheckControllers = [
    SystemComponentCheck(component: "Solar Modules"),
    SystemComponentCheck(component: "Mounting Structure"),
    SystemComponentCheck(component: "DC Wiring"),
    SystemComponentCheck(component: "AC Wiring"),
    SystemComponentCheck(component: "Inverter (String/Micro)"),
    SystemComponentCheck(component: "ACDB/DCDB"),
    SystemComponentCheck(component: "Earthing System"),
    SystemComponentCheck(component: "SPD (Surge Protection)"),
    SystemComponentCheck(component: "Net Meter"),
    SystemComponentCheck(component: "Generation Monitoring"),
  ];

  // Cleaning and Maintenance Tasks
  List<MaintenanceTask> maintenanceTasks = [
    MaintenanceTask(taskName: "Cleaned condenser"),
    MaintenanceTask(taskName: "Checked ducts"),
    MaintenanceTask(taskName: "Panel Cleaning Performed"),
    MaintenanceTask(taskName: "Visual Inspection Done"),
    MaintenanceTask(taskName: "Loose Connections Checked"),
    MaintenanceTask(taskName: "Error Logs Checked"),
    MaintenanceTask(taskName: "Firmware Updated"),
  ];

  Future<void> saveCustomerSignature(BuildContext context) async {
    if (signatureController.isNotEmpty) {
      // Convert the signature to an image
      final signature = await signatureController.toImage();
      final byteData = await signature!.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      _customerSignatureImage = await CloudflareUpload.uploadToCloudflare(
              pngBytes, 'image/jpeg', taskId.toString(), context) ??
          '';
      
      signatureController.clear();
      Navigator.of(context).pop();

      notifyListeners();
      // You can now use the filePath to access the saved image later
      print("Signature saved at $_customerSignatureImage");
    } else {
      print("Please draw a signature before saving!");
    }
  }

  Future<void> saveTechnicianSignature(BuildContext context) async {
    if (signatureController.isNotEmpty) {
      // Convert the signature to an image
      final signature = await signatureController.toImage();
      final byteData = await signature!.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      _technicianSignatureImage = await CloudflareUpload.uploadToCloudflare(
              pngBytes, 'image/jpeg', taskId.toString(), context) ??
          '';
      
      signatureController.clear();
      Navigator.of(context).pop();

      notifyListeners();
      // You can now use the filePath to access the saved image later
      print("Signature saved at $_technicianSignatureImage");
    } else {
      print("Please draw a signature before saving!");
    }
  }

  // Dropdown setters
  void setServiceType(int? id) {
    selectedServiceType = id;
    serviceTypeController.text = serviceTypes
        .firstWhere((item) => item.id == id,
            orElse: () => DropdownItem(id: 0, name: ''))
        .name;
    notifyListeners();
  }

  void setSatisfactionId(int? id) {
    selectedSatisfactionId = id;
    selectedSatisfactionName.text = satisfactionLevels
        .firstWhere((item) => item.id == id,
            orElse: () => DropdownItem(id: 0, name: ''))
        .name;
    notifyListeners();
  }

  void setScheduleDateType(int? id) {
    selectedScheduleDateType = id;
    selectedScheduleDateName.text = scheduleDateTypes
        .firstWhere((item) => item.id == id,
            orElse: () => DropdownItem(id: 0, name: ''))
        .name;
    notifyListeners();
  }

  void setSystemComponentStatus(SystemComponentCheck component, bool? status) {
    component.componentStatus = status == true ? 1 : 0;
    notifyListeners();
  }

  // Maintenance toggles
  void toggleTask(MaintenanceTask task, String type) {
    switch (type) {
      case 'yes':
        task.isYes = 1;
        if (task.isYes == 1) {
          task.isNo = 0;
          task.notApplicable = 0;
        }
        break;
      case 'no':
        task.isNo = 1;
        if (task.isNo == 1) {
          task.isYes = 0;
          task.notApplicable = 0;
        }
        break;
      case 'na':
        task.notApplicable = 1;
        if (task.notApplicable == 1) {
          task.isYes = 0;
          task.isNo = 0;
        }
        break;
    }
    notifyListeners();
  }

  // Date Picker
  Future<void> selectNextScheduledDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      nextScheduledDateController.text =
          picked.toIso8601String().split('T').first;
      notifyListeners();
    }
  }

  // NEW METHOD: Populate form with existing data
  void populateFormWithExistingData() {
    try {
      final jobSheetData = jobSheet[0];
      // Populate values
      final serviceTypeItem = serviceTypes.firstWhere(
        (item) => item.name == jobSheetData.serviceType,
        orElse: () => DropdownItem(id: 0, name: ''),
      );
      if (serviceTypeItem.id != 0) {
        setServiceType(serviceTypeItem.id);
      }
      setJobSheetId(jobSheetData.jobSheetId);

      weatherConditionController.text = jobSheetData.weatherCondition;
      actionTakenController.text = jobSheetData.actionTaken;
      observationController.text = jobSheetData.observation;
      nextScheduledDateController.text =
          jobSheetData.nextScheduledDate.split('T').first;
      setScheduleDateType(jobSheetData.nextScheduledDateType);
      setSatisfactionId(jobSheetData.customerOverallSatisfactionId);
      remarkController.text = jobSheetData.additionalRemark;
      nextMeterReadingController.text = jobSheetData.nextMeterReading;

      _customerSignatureImage = jobSheetData.customerSignature;
      _technicianSignatureImage = jobSheetData.technicianSignature;

      customerSignatureDate.text =
          jobSheetData.customerSignatureDate.split('T').first;
      technicianSignatureDate.text =
          jobSheetData.technicianSignatureDate.split('T').first;

      // Populate system performance
      print(
          "Populating system performance: ${jobSheetData.systemPerformanceCheck.length} items from API");
      for (var system in jobSheetData.systemPerformanceCheck) {
        final name = system.component;
        final status = system.componentStatus;
        final remark = system.remarkController.text;

        print("Processing system component from API: '$name'");

        final match = systemCheckControllers.firstWhere(
          (e) => e.component.trim().toLowerCase() == name.trim().toLowerCase(),
          orElse: () => SystemComponentCheck(component: ''),
        );

        if (match.component.isNotEmpty) {
          print("Found match in local controllers: '${match.component}'");
          match.componentStatus = status;
          match.remarkController.text = remark;
        } else {
          print("No match found for '$name' in systemCheckControllers");
        }
      }

      // Populate cleaning maintenance
      print(
          "Populating maintenance tasks: ${jobSheetData.cleaningMaintenanceTask.length} items from API");

      if (jobSheetData.cleaningMaintenanceTask.isNotEmpty) {
        maintenanceTasks = jobSheetData.cleaningMaintenanceTask;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error populating form with existing data: $e");
    }
  }

  // Prepare data for API
  JobSheetData prepareJobSheetData() {
    // Update net meter reading for all maintenance tasks

    return JobSheetData(
      jobSheetId: jobSheetId,
      taskId: taskId,
      serviceType: serviceTypeController.text,
      serviceTypeId: selectedServiceType ?? 0,
      weatherCondition: weatherConditionController.text,
      actionTaken: actionTakenController.text,
      nextScheduledDate: nextScheduledDateController.text,
      nextScheduledDateType: selectedScheduleDateType ?? 0,
      nextScheduledDateName: selectedScheduleDateName.text,
      customerOverallSatisfactionName: selectedSatisfactionName.text,
      customerOverallSatisfactionId: selectedSatisfactionId ?? 0,
      additionalRemark: remarkController.text,
      nextMeterReading: nextMeterReadingController.text,
      observation: observationController.text,
      technicianSignature: _technicianSignatureImage,
      customerSignature: _customerSignatureImage,
      technicianSignatureDate: technicianSignatureDate.text,
      customerSignatureDate: customerSignatureDate.text,
      systemPerformanceCheck: systemCheckControllers,
      cleaningMaintenanceTask: maintenanceTasks,
    );
  }

  String validateForm() {
    String errorMessage = '';

    if (selectedServiceType == null) {
      errorMessage += '• Service type is required.\n';
    }
    if (selectedSatisfactionId == null) {
      errorMessage += '• Satisfaction level is required.\n';
    }
    if (selectedScheduleDateType == null) {
      errorMessage += '• Schedule date type is required.\n';
    }

    if (weatherConditionController.text.trim().isEmpty) {
      errorMessage += '• Weather condition is required.\n';
    }
    if (actionTakenController.text.trim().isEmpty) {
      errorMessage += '• Action taken is required.\n';
    }
    if (nextScheduledDateController.text.trim().isEmpty) {
      errorMessage += '• Next scheduled date is required.\n';
    }
    if (nextMeterReadingController.text.trim().isEmpty) {
      errorMessage += '• Next meter reading is required.\n';
    }
    if (observationController.text.trim().isEmpty) {
      errorMessage += '• Observation is required.\n';
    }
    // if (satisfactionController.text.trim().isEmpty) {
    //   errorMessage += '• Satisfaction comment is required.\n';
    // }
    if (remarkController.text.trim().isEmpty) {
      errorMessage += '• Remark is required.\n';
    }
    // if (techniController.text.trim().isEmpty) {
    //   errorMessage += '• Technician name is required.\n';
    // }
    if (technicianSignatureDate.text.trim().isEmpty) {
      errorMessage += '• Technician signature date is required.\n';
    }
    if (customerSignatureDate.text.trim().isEmpty) {
      errorMessage += '• Customer signature date is required.\n';
    }

    if (_customerSignatureImage.isEmpty) {
      errorMessage += '• Customer signature image is required.\n';
    }
    if (_technicianSignatureImage.isEmpty) {
      errorMessage += '• Technician signature image is required.\n';
    }

    return errorMessage;
  }

  // Submit function
  Future<void> submitJobSheet(BuildContext context) async {
    final errors = validateForm();
    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Fields'),
          content: Text(errors),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    bool success = false;
    try {
      Loader.showLoader(context);
      final jobSheetData = prepareJobSheetData();

      //  Log the size of the lists
      print("Preparing Job Sheet Data:");
      print(
          "System Performance Check Count: ${jobSheetData.systemPerformanceCheck.length}");
      print(
          "Cleaning Maintenance Task Count: ${jobSheetData.cleaningMaintenanceTask.length}");

      final jsonData = jobSheetData.toJson();

      // Log the JSON payload for specific keys
      print(
          "JSON 'system_performance_check': ${jsonData['system_performance_check']}");
      print(
          "JSON 'cleaning_maintenance_task': ${jsonData['cleaning_maintenance_task']}");

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveJobSheet,
          bodyData: jsonData);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        print(data);
        success = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
      debugPrint("Job Sheet submitted successfully!");
    } catch (e) {
      debugPrint("Error submitting job sheet: $e");
    } finally {
      Loader.stopLoader(context);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job sheet saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  // Set task ID (call this when initializing the form)
  void setTaskId(int id) {
    taskId = id;
    notifyListeners();
  }

  void setJobSheetId(int id) {
    jobSheetId = id;
    notifyListeners();
  }

  Future<void> getJobSheet(BuildContext context, int taskId) async {
    try {
      setTaskId(taskId);
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getJobSheet}/$taskId');

      if (response.statusCode == 200) {
        final data = response.data;
        print("GetJobSheet Response Data: $data");

        if (data != null) {
          if (data is List) {
            _jobSheet = data.map((item) => JobSheetData.fromJson(item)).toList();
          } else if (data is Map<String, dynamic>) {
            // Check if it's an error/empty response masked as a Map
            if (data.containsKey('status') && data['status'] == false) {
              _jobSheet = [];
            } else {
              _jobSheet = [JobSheetData.fromJson(data)];
            }
          }
          
          if (_jobSheet.isNotEmpty) {
            populateFormWithExistingData();
          }
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
    } finally {
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  // NEW METHOD: Clear form data (useful for creating new job sheets)
  void clearFormData() {
    jobSheetId = 0;
    _jobSheet.clear();
    // Clear all text controllers
    serviceTypeController.clear();
    selectedSatisfactionName.clear();
    selectedScheduleDateName.clear();
    weatherConditionController.clear();
    actionTakenController.clear();
    nextScheduledDateController.clear();
    satisfactionController.clear();
    remarkController.clear();
    observationController.clear();
    nextMeterReadingController.clear();
    techniController.clear();
    technicianSignatureDate.clear();
    customerSignatureDate.clear();

    // Reset selected values
    selectedServiceType = null;
    selectedSatisfactionId = null;
    selectedScheduleDateType = null;

    // Clear signatures
    _customerSignatureImage = '';
    _technicianSignatureImage = '';
    signatureController.clear();

    // Reset system check controllers
    for (var check in systemCheckControllers) {
      check.componentStatus = 0;
      check.remarkController.clear();
    }

    // Reset maintenance tasks
    for (var task in maintenanceTasks) {
      task.isYes = 0;
      task.isNo = 0;
      task.notApplicable = 0;
    }

    notifyListeners();
  }
}
