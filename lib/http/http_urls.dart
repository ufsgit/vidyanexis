class HttpUrls {
//baseurls
//live

  // static String baseUrl = 'https://bay_mentapi.trackbox.net.in/';
  // static String baseUrl = 'https://surya_prabhaapi.trackbox.net.in/';
  static String baseUrl = 'https://oxysolarapi.trackbox.net.in/';
  // static String baseUrl = 'https://vidyanexisapi.trackbox.net.in/';
  // static String baseUrl = 'https://jibinsolarapi.trackbox.net.in/';
  // static String baseUrl = 'https://a3secosaveapi.trackbox.net.in/';
  // static String baseUrl = 'https://risingsunsolarapi.trackbox.net.in/';
  // static String baseUrl = 'https://ecoamicatradersapi.trackbox.net.in/';
  // static String baseUrl = 'https://solarisadmin.trackbox.net.in/';
  // static String baseUrl = 'https://papscoapi.trackbox.net.in/';
  //static String baseUrl = 'https://demo3api.trackbox.net.in/';
  // static String baseUrl = 'https://ckredencesoesyapi.trackbox.net.in/';
  // static String baseUrl = 'https://glpowerapi.trackbox.net.in/';
//   static String baseUrl = 'https://ckredencesoesyapi.trackbox.net.in/';
  // static String baseUrl = 'https://lumiosapi.trackbox.net.in/';

//dev
  // static String baseUrl = 'https://3pm19pm4-3512.inc1.devtunnels.ms/';

  static String imgBaseUrl =
      'https://pub-b2e3330da2344ea490c08dd119392728.r2.dev/';
  //endpoints
  static String savePayment = "service/Save_payment";

  static String getPaymentByCustomer = "service/Get_Payment_By_Customer";
  static String deletePayment = "service/Delete_payment";
  static String loginCheck = "Login/Login_Check";
  static String searchLead = "lead/Search_lead";
  static String saveLead = "lead/Save_lead";
  static String saveCustomer = "lead/Update_Customer";
  static String saveFollowUp = "followup/Save_followup";
  static String timeTrack = "followup/Time_track_reports";
  static String followupByuser = "followup/Get_followup";
  static String deleteLead = "lead/Delete_lead";
  static String deleteCustomer = "lead/Delete_Customer";
  static String convertLead = "followup/Convert_lead";
  static String enquirySource = "lead/Search_Enquiry_Source";
  // static String getAllFollowUpStatus = "status/Search_status";
  static String getItemListStock = "item/Get_All_Items_from_stock";
  static String saveStockUse = "item/Save_stock_use_master";
  static String searchSupplier = "item/get_all_suppliers";
  static String getItemListPurchase = "item/get_all_items_purchase";
  static String getPurchaseDetails = "item/Get_Purchase_Details";

  static String enquiryFor = "lead/Search_Enquiry_For";
  static String searchUserDetails = "user_details/Search_user_details";
  // static String searchFollowUpStatus = "status/Search_status";
  static String leadDetails = "lead/Get_lead";
  static String followUpHistory = "lead/Get_FollowUp_History";
  static String searchCustomer = "lead/Search_Customer";
  static String getTaskByCustomer = "task/Get_task_By_Customer";
  static String getTaskDetails = "task/Get_task";
  static String searchLeadReports = "lead/Search_lead_Report";
  static String saveTask = "task/Save_task";
  static String saveService = "service/Save_service";
  static String getServiceByCustomer = "service/Get_Service_By_Customer";
  static String getServiceDetails = "service/Get_service";
  static String saveAmcDetails = "amc/Save_amc";
  static String searchTaskType = "task_status/Search_task_type";
  static String getTaskHistory = "task_data/Get_Task_History";
  static String getAmc = "amc/Get_Amc_By_Customer";
  static String getQuatationByCustomer =
      "quotation_master/Get_Quotation_By_Customer";
  static String saveQuotationMaster = "quotation_master/Save_quotation_master";
  static String getQuotationByMasterId =
      "quotation_master/Get_quotation_master";
  static String searchAMCStatus = 'amc_status/Search_amc_status';
  static String amcDuration = "amc_duration/Search_amc_duration";
  static String amcInterval = "amc_interval/Search_amc_intervals";
  static String searchTaskReport = "task/Search_task_Report";
  static String searchFollowupReports = "lead/Search_Pending_Followup_Report";
  static String searchQuotationReports =
      "quotation_master/Search_Quotaion_Report";

  static String searchTaskByCustomer = "task/Search_task_by_customer";
  static String changeTaskStatus = "task/Change_Task_Status";
  static String getStatusByTaskTypeId = "status/Get_status_by_task_type_id";
  static String searchServiceReport = "service/Search_Service_Report";
  static String searchConversionReport = "lead/Conversion_Report";
  static String searchInvoiceReport = "lead/Search_Invoice_Report";
  static String searchAmcReport = "amc/Search_AMC_Report";
  static String searchUser =
      'user_details/Search_user_details?user_details_Name';
  static String addUser = "user_details/Save_user_details";
  static String searchWorkingStatus =
      "working_status/Search_working_status?working_status_Name";
  static String addUnit = "item/Save_Unit";
  static String deleteUnit = "item/Delete_Unit";
  static String searchUnit = "item/Get_All_unit";

  static String searchUserType = "user_type/Search_user_type?user_type_Name";
  static String getMenuPermission = "user_details/Get_Menu_Permission";
  static String saveMenuPermission =
      "user_menu_selection/Save_user_menu_selection";
  // static String searchLeadStatus = "status/Search_status";
  static String addLeadStatus = "status/Save_status";
  static String addEnquirySource = "lead/Save_Enquiry_Source";
  static String searchEnquiryStatus = "lead/Search_Enquiry_Source";
  static String deleteEnquiry = "lead/Delete_Enquiry_Source";

  static String saveStage = "lead/Save_Stage";
  static String searchStage = "lead/Get_All_Stage";
  static String deleteStage = "lead/Delete_Stage";

  static String saveSourceCategory = "lead/Save_Source_Category";
  static String searchSourceCategoty = "lead/Get_All_Source_Category";
  static String deleteSourceCategory = "lead/Delete_Source_Category";
  static String enquirySourceConversionReport =
      "lead/Enquiry_Source_Conversion_Report";
  static String leadProgressReport = "lead/Lead_Progress_Report";
  static String followUpSummary = "followup/Dashboard_FollowUp_Summary";
  static String taskAllocationSummary = "lead/Task_Allocation_Summary";
  static String dashboardCount = "lead/Get_Dashboard_Count";
  static String getLeadDashboard = "lead/Get_Lead_Dashboard";
  static String searchLeadDashboard = "lead/Search_lead_Dashboard";
  static String workSummary = "lead/Customer_Work_Summary";
  static String searchDocumentType = "settings/Search_document_type";
  static String saveImage = "lead/Save_Image";
  static String getDocumentList = "lead/Get_Images_By_Customer";
  static String getRecieptList = "service/Get_Receipt_By_Customer";
  static String saveRecieptUrl = "service/Save_Receipt";
  static String deleteImage = "lead/Delete_image";
  static String bulkImport = 'lead/Lead_Import';
  static String unregisterCustomer = 'lead/Remove_Registration';
  static String deleteUser = 'user_details/Delete_user_details';
  static String addEnquiryFor = "lead/Save_Enquiry_For";
  static String searchEnquiryFor = "lead/Search_Enquiry_For";
  static String deleteEnquiryFor = "lead/Delete_Enquiry_For";
  static String getCompany = "settings/Get_Company_Details";
  static String saveCompany = "settings/Save_Company";
  static String searchmenu = "menu/Search_menu";
  static String deleteTask = "task/Delete_task";
  static String deleteService = "service/Delete_service";
  static String deleteAMC = "amc/Delete_amc";
  static String deleteQuotation = "quotation_master/Delete_quotation_master";
  static String deleteReciept = "service/Delete_Receipt";
  static String addDocumentType = "settings/Save_document_type";
  static String deleteDocumentType = "settings/Delete_document_type";
  static String searchWorkSummary = "user_details/Search_Work_Summary";
  static String searchWorkReport = "user_details/Search_Work_report";
  static String addCheckListType = "lead/Save_Checklist";
  static String deleteCheckListType = "lead/Delete_Checklist";
  static String searchCheckListType = "lead/Search_Checklist";
  static String getTaskDocumetsByCustomer =
      "task/Get_task_By_Customer_With_Documents";
  static String getStockUse = "item/Get_stock_use_master";
  static String deleteCategory = "item/Delete_Category";

  static String saveVersion = "task/Save_Version";
  static String getVersion = "task/Get_Version";
  static String saveAttendance = "attendance/mark_attendance";
  static String getAttendance = "attendance/attendance_report";
  static String saveItem = "item/create_Item";
  static String getItemList = "item/get_all_items";
  static String getItemMaterials = "item/get_item_details";
  static String deleteItem = "item/delete_item_details";
  static String getFormPrint = 'item/get_solar_panel_details';
  static String addCategory = "item/save_category";

  static String getStockList = "item/get_all_stocks";
  static String getTaskUsers = "task/Get_Task_Users";
  static String saveStock = "item/Save_Stock";
  static String getExpenseTypes = "item/get_expense_types";
  static String addExpenseType = "item/save_expense_type";
  static String deleteExpenseType = "item/Delete_Expense_Type";
  static String getExpenseManagement = "item/get_expense_management";
  static String saveExpenseManagement = "item/save_expense_management";
  static String deleteExpenseManagement = "item/Delete_Expense_Management";
  static String saveProjectType = "project/Save_Project_Type";
  static String searchProjectType = "project/Get_Project_Type";
  static String saveProjects = "project/Save_Project";
  static String deleteProjects = "project/Delete_Project";
  static String searchProjects = "project/Get_Project";
  static String deleteProjectType = "project/Delete_Project_Type";

  // Expense Tab Endpoints
  static String getExpenseReport = "service/Get_Expense_Report";
  static String saveExpense = "service/Save_expense";
  static String getExpenseByCustomer = "service/Get_Expense_By_Customer";
  static String deleteExpense = "service/Delete_Expense";
  static String getExpenseById = "service/Get_Expense_By_Id";
  static String getPurchaseData = "item/get_purchase_details";
  static String savePurchase = "item/save_purchase_master";
  static String getInvoiceList = "service/Get_Customer_Invoice";
  static String saveInvoiceUrl = "service/Save_Customer_Invoice";
  static String invoiceRecieptTotal = "service/Invoice_Reciept_Total";

  static String searchOutofwarrentyReport =
      "service/Search_Outofwarrenty_Report";
  static String searchUpcomingWarrantyReport =
      "service/Search_Upcoming_Warranty_Report";
  static String billPayementReport = "service/Billing_Payment_Report";
  static String addTaskType = "task_status/Save_task_type";
  static String deleteTaskType = "task_status/Delete_task_type";
  static String warrentyReport = "lead/Search_Warranty_Report";
  static String feedbackReport = "task/Get_feedback_reports";
  static String searchDepartment = "department/Search_department";
  static String saveStatus = "status/Save_status";
  static String searchStatus = "status/Search_status";
  static String deleteStatus = "status/Delete_status";
  static String getLeadDropdowns = "lead/Get_Lead_Dropdown";
  static String getProcessFlowData =
      "process_flow/get_all_dropDown_processFlow";
  static String getTaskTypeByDepartment =
      "process_flow/Get_Task_Type_Of_Department";
  static String saveProcessFlow = "process_flow/Save_Process_Flow";
  static String getAllProcessFlow = "process_flow/Get_All_Process_Flow";
  static String getProcessFlowById = "process_flow/Get_Process_Flow_By_Id";
  static String deleteProcessFlowById =
      "process_flow/Delete_Process_Flow_By_Id";
  static String saveSubUsers = "user_details/Save_Sub_Users";
  static String getUsersSub = "user_details/Get_Sub_Users";
  static String getTaskTypesOfProcessFlow =
      "process_flow/Get_Task_Types_Of_Process_Flow";

  static String saveDepartment = "department/Save_department";
  static String deleteDepartment = "department/Delete_department";
  static String fetchDashBoardTaskData = "dashboard/Fetch_dashboard";

  static String getLeadReportByEnquirySource =
      "lead/Get_Lead_Report_By_Enquiry_Source";

  static String searchCategory = "item/Get_All_category";
  static String saveCheckListCategory = "category/Save_Check_List_Category";
  static String searchCheckListCategory = "category/Search_Check_List_Category";
  static String deleteCheckListCategory = "category/Delete_Check_List_Category";
  static String searchCheckListItem = "category/Search_Check_List_Item";
  static String saveCheckListItem = "category/Save_Check_List_Item";
  static String deleteCheckListItem = "category/Delete_Check_List_Item";
  static String getDocumentChecklistDetails =
      "category/Get_Document_Check_List_Details";
  static String getDocumentCheckList = "category/Get_Document_Check_List";
  static String saveDocumentCheckList =
      "category/Save_Complete_Document_Check_List";
  static String deleteDocumentCheckList = "category/Delete_Document_Check_List";
  static String getAttendanceDetails = "attendance/Get_User_Attendance_Details";
  static String getAttendanceByDate = "attendance/Get_Attendance_By_DateRange";
  static String saveAttendanceMultiple =
      "attendance/Save_Multiple_Attendance_Details";
  static String getUserLocationDetails =
      "user_details/Get_All_User_Location_Details";
  static String getLocation = "lead/get_location";
  static String saveLocation = "lead/save_location";
  static String deleteLocation = "lead/delete_location";
  static String getTaskInfoDashBoard = "task/Get_Task_Info_Dashboard";
  static String saveBranch = "branch/save_branch";
  static String deleteBranch = "branch/delete_branch";
  static String getAllBranch = "branch/get_all_branch";
  static String getDistricts = "lead/Get_Districts";
  static String getCustomFieldType = "settings/Get_custom_field_type";
  static String getAllCustomField = "settings/Get_All_custom_field";
  static String saveCustomField = "settings/Save_custom_field";
  static String getCustomField = "settings/Get_All_custom_field";
  static String deleteCustomField = "settings/Delete_custom_field";
  static String getCustomFieldByStatusId =
      "status/Get_CustomFields_On_StatusChange";
  static String getCustomFieldByEnquiryForId =
      "lead/Get_CustomFields_On_EnquiryFor";
  static String saveRefund = "service/Save_Refund_Details";
  static String getRefundDetails = "service/Get_Refund_Details";
  static String getAllLeadDropDown = "lead/Get_All_Lead_Dropdown";
  static String getAllTax = "tax/Get_Tax";
  static String saveTaskData = "task_data/Save_Task_Data";
  static String getTaskData = "task_data/Get_Task_Data";
  static String updateTaskData = "task_data/Update_Task_Status";
  static String getFollowUpStatusCustomer =
      "status/get_followupstatus_customer";
  static String leadEnquiryReport = "lead/Lead_Enquiry_Report";
  static String leadReport = "lead/Lead_Report";
  static String getQuotationTypes = "quotation_master/get_quotation_types";
  static String getCustomFieldQuotation =
      "quotation_details/get_custom_field_for_quotation";
  static String loadQuotationFromCustomFields =
      "quotation_master/load_quotation_from_custom_fields";

  static String getPaymentReport = "service/Get_Payment_Report";
  static String getPaymentSchedule = "service/Get_Payment_Schedule_By_Customer";
  static String savePaymentSchedule = "service/save_schedule";
  static String deletePaymentSchedule = "service/Delete_Payment_Schedule";
  static String getQuotationMasterPdf =
      "quotation_master/Get_quotation_master_pdf";
  static String balanceReport = "service/Payment_Balance_Report";
  static String upcomingPaymentReport = "service/Get_Upcoming_Payment_Report";
  static String totalOutstandingReport = "service/Get_Total_Outstanding_Report";
  static String outstandingReport = "service/Get_Outstanding_Report";
  static String amcNotification = "task/Get_AMC_Notification";
  static String getPaymentReminders = "task/Get_Payment_Reminders";
  static String saveInvoiceTab = "service/Save_Invoice";
  static String getInvoiceByCustomer = "service/Get_All_Invoices";
  static String getInvoiceDetails = "service/Get_Invoice";
  static String deleteInvoiceTab = "service/Delete_Invoice";
  static String getHSNDetails = "service/Get_HSN_Details";
  static String getAllItemsInvoice = "item/get_all_items_invoice";
  static String getInvoicePrintItems = "service/Get_Invoice_Items_Print";
  static String getQuotationDropDown =
      "quotation_master/Get_Quotation_Dropdown";
  static String getQuotationItems =
      "quotation_master/Get_Quotation_Dropdown_Details";
  static String saveStockReturn = "item/Save_stock_return_master";
  static String getStockReturn = "item/Get_stock_return_master";
  static String deleteStockUse = "item/Delete_Stock_Use_Master";
  static String deleteStockReturn = "item/Delete_Stock_Return_Master";
  static String getStockUseDetails = "item/Get_stock_use_details";
  static String getStockreturnDetails = "item/Get_stock_return_details";
  static String saveSupplier = "item/save_supplier";
  static String deleteSupplier = "item/delete_supplier";
  static String getPurchaseDataMaster = "item/get_purchase_master";
  static String deletePurchase = "item/Delete_Purchase_Master";
}
