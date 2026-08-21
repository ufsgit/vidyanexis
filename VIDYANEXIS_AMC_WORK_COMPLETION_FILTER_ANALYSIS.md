# VidyaNexis — AMC Date & Work Completion Date Filter Analysis

## 1. Executive Summary

This document provides a comprehensive, codebase-accurate architectural analysis of the **VidyaNexis Flutter application** to prepare for adding two new date filters to the **Customer Page**:
1. **AMC Date Filter** (From Date & To Date)
2. **Work Completion Date Filter** (From Date & To Date)

### Key Findings:
- **Display Status**: Both `AMC Date` and `Work Completion Date` columns are already displayed in the Web Customer Table (`customer_page.dart`) and exported to Excel in both Web and Mobile (`customer_page_phone.dart`).
- **Model Status**: `SearchLeadModel` already contains `amcDate` and `workCompletionDate` string fields, with robust fallback JSON key parsers (checking 12 variations each) and formatted getters (`amcDateDisplay`, `workCompletionDateDisplay`) using `toDayMonthYearFormat()`.
- **Current Filter Architecture**: Customer filtering is managed in `CustomerProvider`. It currently supports search, status multi-select, assigned staff, enquiry for, enquiry source, branch, ME/ALL entry toggle, sorting, and a **single date filter** (`_fromDate`, `_toDate`, `Is_Date_`, `Fromdate_`, `Todate_`), which is labeled as "Follow Up Date" in the Web UI.
- **Backend API Status**: The endpoint `lead/Search_Customer` currently only receives the single date parameter set (`Is_Date_`, `Fromdate_`, `Todate_`). There are **no existing query parameters** in the frontend codebase for `AMC_From_Date`, `Work_Completion_From_Date`, or a `Date_Type_` switch for `lead/Search_Customer`. Supporting independent or switchable date filtering requires aligning the API parameter contract with backend capabilities.
- **Scope & Integrity**: **No source code was modified, created, or deleted during this analysis**.

---

## 2. Customer Page Architecture

The VidyaNexis Customer module is structured using Provider-based state management with responsive Web and Mobile presentations.

### Architecture Overview:
```text
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
│  Web Page: lib/presentation/pages/home/customer_page.dart               │
│  Mobile Page: lib/presentation/pages/home/customer_page_phone.dart      │
│  Widgets: TableWidget, CustomFilterButton, _StatusMultiSelectDialog,    │
│           LeadCard, CustomAppBar, MeAllToggleSwitch                     │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ (Provider / Consumer)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            CONTROLLER LAYER                             │
│  Provider: lib/controller/customer_provider.dart (CustomerProvider)     │
│  Supporting: DropDownProvider, SettingsProvider, SidebarProvider        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ (HTTP GET Requests)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            NETWORKING LAYER                             │
│  Helper: lib/http/http_requests.dart (HttpRequest.httpGetRequest)       │
│  Endpoints: lib/http/http_urls.dart (HttpUrls.searchCustomer)           │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ (JSON List Response)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                               MODEL LAYER                               │
│  Model: lib/controller/models/search_leads_model.dart (SearchLeadModel) │
│  Parsing: item.tp == 1 (Records), item.tp == 2 (Total Count Metadata)   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Component Details:
1. **Web Presentation**: `CustomerPage` (`lib/presentation/pages/home/customer_page.dart`)
   - Header with ME/ALL toggle, search field, sort menu, filter toggle button (`CustomFilterButton`), refresh button, and Excel export.
   - Expandable filter toolbar (`isFilter == true`) containing status multi-select dialog, date picker button (`onClickTopButton`), assigned staff dropdown, enquiry for dropdown, enquiry source dropdown, branch dropdown, and reset button.
   - Dual-scroll table: Fixed left columns (`_fixedVerticalController`) + horizontally scrollable right columns (`_scrollableVerticalController`, `_horizontalScrollController`).
   - Bottom pagination bar (`_buildPaginationControls`) with Previous/Next controls.
2. **Mobile Presentation**: `CustomerPagePhone` (`lib/presentation/pages/home/customer_page_phone.dart`)
   - `CustomAppBar` with search, sort, ME/ALL toggle switch, Excel export, and refresh.
   - Filter drawer/view with status chips, date filter picker button (`onClickTopButton`), reset button, and floating "APPLY" action button.
   - Infinite scroll list with `ListView.builder` rendering `LeadCard` widgets.
3. **State Management**: `CustomerProvider` (`lib/controller/customer_provider.dart`)
   - Extends `ChangeNotifier`.
   - Holds search query, filter IDs, date objects, pagination indices (`_startLimit`, `_endLimit`), sort state, and record list `_customerData`.
4. **Networking**: `HttpRequest` (`lib/http/http_requests.dart`)
   - Uses `Dio` to execute HTTP requests with bearer token authorization and error logging.
5. **No Repository Layer**:
   - The application does not use repository abstractions (`lib/domain/repositories` is empty). Providers make direct HTTP calls via `HttpRequest`.

---

## 3. Customer Data Flow

The complete end-to-end data flow for the Customer Page is traced below:

```text
1. User Action
   ├── User modifies filter (Date / Status / Staff / Search / ME-ALL)
   └── User clicks "Apply" or triggers debounced search (500ms)
            ↓
2. UI Event Handler
   ├── customer_page.dart (Web): onClickTopButton() / _onSearchChanged()
   └── customer_page_phone.dart (Mobile): onClickTopButton() / FAB "APPLY"
            ↓
3. Provider State Update
   ├── CustomerProvider.setSearchCriteria(search, fromDateS, toDateS)
   ├── CustomerProvider.setFromDate(date) / setToDate(date) / formatDate()
   ├── Resets pagination: _startLimit = 1, _endLimit = 20, currentPage = 1
   └── Clears previous results: _customerData.clear()
            ↓
4. Provider API Invocation
   └── CustomerProvider.getSearchCustomers(context, isSilent: false/true)
            ↓
5. HTTP Request Construction
   ├── URL: HttpUrls.baseUrl + HttpUrls.searchCustomer (lead/Search_Customer)
   ├── Query String:
   │     Customer_Name_=$_search
   │     &Is_Date_=$isDate
   │     &Fromdate_=$_fromDateS
   │     &Todate_=$_toDateS
   │     &To_User_Id_=$toUserId
   │     &Login_User_Id_=$loginUserId
   │     &Status_Id_=$_status
   │     &Page_Index1_=$_startLimit
   │     &Page_Index2_=$_endLimit
   │     &Enquiry_For_Id_=$enquiryForId
   │     &Enquiry_Source_Id_=$enquirySourceId
   │     &Branch_Id_=$branchIds
   │     &User_Details_Id_=$loginUserId
   │     &Order_By_=$apiSortOption
   │     &Order_Type_=$_sortOrder
   │     &Entry_Type_=$_entryType
   └── Method: GET
            ↓
6. Backend Execution & Response
   └── Returns List<dynamic> containing JSON objects
            ↓
7. Deserialization & Metadata Extraction
   ├── CustomerProvider parses each item via SearchLeadModel.fromJson(item)
   ├── Filters data records: allItems.where((item) => item.tp == 1) -> _customerData
   ├── Extracts metadata: allItems.firstWhere((item) => item.tp == 2) -> _totalCount = item.customerId
   └── Applies client-side sort if alphabetical (Option 4) or creation date (Option 2)
            ↓
8. UI Rebuild & Render
   ├── notifyListeners() triggers UI update
   ├── Web: _buildWebTable renders TableWidget rows (including AMC Date & Work Completion Date)
   └── Mobile: _buildMobileList renders LeadCard items + scrollListener handles infinite loading
```

---

## 4. Customer Model

### Model Location:
- **File**: `lib/controller/models/search_leads_model.dart`
- **Class**: `SearchLeadModel`

### Relevant Date Fields:

```text
Field name:           amcDate
Model field:          final String amcDate; (line 58)
API field:            AMC_To_Date / AMC_Date / AMC_End_Date / AMC_Validity_Date / To_Date / to_date / amc_to_date / amc_date / amc_end_date / amc_validity_date / amcToDate / amcDate
Data type:            String (defaults to '' in constructor, line 270)
Getter / Formatter:   String get amcDateDisplay (lines 61-71)
Where it is populated:SearchLeadModel.fromJson (lines 391-402)
Where it is displayed:1. Web table scrollable row cell (customer_page.dart:1388)
                      2. Web Excel export (customer_page.dart:496)
                      3. Mobile Excel export (customer_page_phone.dart:187)
Where it is used:     Display and data export. Not currently bound to any filter input.

--------------------------------------------------------------------------------

Field name:           workCompletionDate
Model field:          final String workCompletionDate; (line 59)
API field:            Work_Completion_Date / Work_Completion_date / Work Completion Date / Completion_Date / Completion_date / Completion Date / Completed_Date / completed_date / Work_Completed_Date / work_completion_date / workCompletionDate / completionDate
Data type:            String (defaults to '' in constructor, line 271)
Getter / Formatter:   String get workCompletionDateDisplay (lines 73-83)
Where it is populated:SearchLeadModel.fromJson (lines 403-414)
Where it is displayed:1. Web table scrollable row cell (customer_page.dart:1413)
                      2. Web Excel export (customer_page.dart:500)
                      3. Mobile Excel export (customer_page_phone.dart:189)
Where it is used:     Display and data export. Not currently bound to any filter input.

--------------------------------------------------------------------------------

Field name:           nextFollowUpDate
Model field:          final String nextFollowUpDate; (line 15)
API field:            Next_FollowUp_date (line 297)
Data type:            String
Getter / Formatter:   lead.nextFollowUpDate.toDayMonthYearFormat() (customer_page.dart:1401)
Where it is populated:SearchLeadModel.fromJson (line 297)
Where it is displayed:1. Web table scrollable row cell (customer_page.dart:1398-1402)
                      2. Web Excel export (customer_page.dart:497-498)
                      3. Mobile list item header (customer_page_phone.dart:1567)
                      4. Mobile Excel export (customer_page_phone.dart:188)
Where it is used:     Display, follow-up scheduling, and current target of Fromdate_/Todate_ API filter.

--------------------------------------------------------------------------------

Field name:           entryDate (Creation Date)
Model field:          final String entryDate; (line 24)
API field:            Entry_Date / created_at / createdAt / created_date / createdDate / lead_created_date / Entry_date (lines 306-312)
Data type:            String
Getter / Formatter:   DateTime? get parsedCreationDate (lines 146-173)
Where it is populated:SearchLeadModel.fromJson (lines 306-312)
Where it is displayed:Used for client-side sorting in customer_provider.dart (lines 244-253)
Where it is used:     Record creation timestamp and sorting.
```

---

## 5. AMC Date — Current Implementation

AMC Date is already integrated into the Customer table and models as follows:

### Code Locations:
- **Model Definition**: `lib/controller/models/search_leads_model.dart:58`
  ```dart
  final String amcDate;
  ```
- **Display Getter**: `lib/controller/models/search_leads_model.dart:61-71`
  ```dart
  String get amcDateDisplay {
    final trimmed = amcDate.trim();
    if (trimmed.isEmpty || trimmed == '-' || trimmed.toLowerCase() == 'null') {
      return '-';
    }
    final formatted = trimmed.toDayMonthYearFormat();
    if (formatted.isEmpty || formatted == '-' || formatted.toLowerCase() == 'null') {
      return '-';
    }
    return formatted;
  }
  ```
- **JSON Parsing**: `lib/controller/models/search_leads_model.dart:391-402`
  ```dart
  amcDate: parseString(json['AMC_To_Date'] ??
      json['AMC_Date'] ??
      json['AMC_End_Date'] ??
      json['AMC_Validity_Date'] ??
      json['To_Date'] ??
      json['to_date'] ??
      json['amc_to_date'] ??
      json['amc_date'] ??
      json['amc_end_date'] ??
      json['amc_validity_date'] ??
      json['amcToDate'] ??
      json['amcDate']),
  ```
- **Web Table Header**: `lib/presentation/pages/home/customer_page.dart:1266-1273`
  ```dart
  const TableWidget(
    width: 140,
    title: 'AMC Date',
    fontWeight: FontWeight.bold,
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    color: Color(0xFFFFFFFF),
  ),
  ```
- **Web Table Cell**: `lib/presentation/pages/home/customer_page.dart:1380-1389`
  ```dart
  TableWidget(
    width: 140,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
    title: lead.amcDateDisplay,
  ),
  ```

### Analysis of Current AMC Date Flow:
1. **Conversion/Parsing**: Raw strings from the backend are cleaned and formatted via `toDayMonthYearFormat()` in `lib/utils/extensions.dart:238-288`.
2. **Date Format**: Displays in UI as `dd MMM yyyy` (e.g., `21 Aug 2026`).
3. **Null/Empty Handling**: Handled gracefully. If empty, whitespace, `'-'`, or `'null'`, `amcDateDisplay` returns `'-'`.
4. **Availability**: Already confirmed available in `lead/Search_Customer` response payload.

---

## 6. Work Completion Date — Current Implementation

Work Completion Date is already integrated into the Customer table and models as follows:

### Code Locations:
- **Model Definition**: `lib/controller/models/search_leads_model.dart:59`
  ```dart
  final String workCompletionDate;
  ```
- **Display Getter**: `lib/controller/models/search_leads_model.dart:73-83`
  ```dart
  String get workCompletionDateDisplay {
    final trimmed = workCompletionDate.trim();
    if (trimmed.isEmpty || trimmed == '-' || trimmed.toLowerCase() == 'null') {
      return '-';
    }
    final formatted = trimmed.toDayMonthYearFormat();
    if (formatted.isEmpty || formatted == '-' || formatted.toLowerCase() == 'null') {
      return '-';
    }
    return formatted;
  }
  ```
- **JSON Parsing**: `lib/controller/models/search_leads_model.dart:403-414`
  ```dart
  workCompletionDate: parseString(json['Work_Completion_Date'] ??
      json['Work_Completion_date'] ??
      json['Work Completion Date'] ??
      json['Completion_Date'] ??
      json['Completion_date'] ??
      json['Completion Date'] ??
      json['Completed_Date'] ??
      json['completed_date'] ??
      json['Work_Completed_Date'] ??
      json['work_completion_date'] ??
      json['workCompletionDate'] ??
      json['completionDate']),
  ```
- **Web Table Header**: `lib/presentation/pages/home/customer_page.dart:1282-1289`
  ```dart
  const TableWidget(
    width: 160,
    title: 'Work Completion Date',
    fontWeight: FontWeight.bold,
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    color: Color(0xFFFFFFFF),
  ),
  ```
- **Web Table Cell**: `lib/presentation/pages/home/customer_page.dart:1404-1414`
  ```dart
  TableWidget(
    width: 160,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    title: lead.workCompletionDateDisplay,
  ),
  ```

### Analysis of Other Work Completion Dates in Codebase:
1. **Customer Page**: `SearchLeadModel.workCompletionDate` (represents the overall project installation/work completion date for the customer).
2. **Task Details**: `TaskDetailsModel.completionDate` (`lib/controller/models/task_details_model.dart:18`) represents the completion date of a specific sub-task or service ticket.
3. **Work Completion Report**: `WorkCompletionReportModel` (`lib/controller/models/work_completion_report_model.dart`) holds raw map data from endpoint `lead/Work_Completion_Report`.
4. **Distinction**: For the Customer Page, the relevant field is **`SearchLeadModel.workCompletionDate`**.

---

## 7. Existing Customer Filters

### 1. Filter UI Components:
- **Location**: `lib/presentation/pages/home/customer_page.dart` (lines 663-764)
- **Toggle Button**: `CustomFilterButton` toggles `customerProvider.isFilter`.
- **Existing Filter Controls**:
  - `_buildStatusFilter`: Multi-select dialog (`_StatusMultiSelectDialog`) displaying checkboxes for statuses from `DropDownProvider.followUpData`.
  - Date Filter Button: `GestureDetector` invoking `onClickTopButton(context)` (lines 684-720). Shows `Follow Up Date: All` or `Date : YYYY-MM-DD - YYYY-MM-DD`.
  - `_buildAssignedStaffFilter`: Single-select dropdown filtered for admin vs staff (`searchUserDetails`).
  - `_buildEnquiryForFilter`: Dropdown populated with `DropDownProvider.enquiryForList`.
  - `_buildEnquirySourceFilter`: Dropdown populated with `DropDownProvider.enquiryData`.
  - `_buildBranchFilter`: Dropdown populated with `SettingsProvider.branchModel`.
  - Reset Button: Resets all filter values and re-fetches list (`customer_page.dart:739-761`).

### 2. Date Picker Implementation (`onClickTopButton`):
- **Dialog Type**: `AlertDialog` with `SingleChildScrollView`.
- **Quick Selection Chips**: List generated from `dateButtonTitles`: `['Yesterday', 'Today', 'Tomorrow', 'This Week', 'This Month']`.
- **Custom Range Pickers**: Two read-only `TextField` widgets with calendar icons invoking `customerProvider.selectDate(context, true)` (From) and `customerProvider.selectDate(context, false)` (To).
- **Apply Action**:
  ```dart
  customerProvider.formatDate();
  customerProvider.setSearchCriteria(
    customerProvider.search,
    customerProvider.formattedFromDate,
    customerProvider.formattedToDate,
  );
  customerProvider.getSearchCustomers(context, isSilent: true);
  ```
- **Clear Action**:
  ```dart
  customerProvider.selectDateFilterOption(null);
  customerProvider.setSearchCriteria(customerProvider.search, '', '');
  customerProvider.getSearchCustomers(context, isSilent: true);
  ```

### 3. Filter State Storage (`CustomerProvider`):
- `_fromDate` (`DateTime?`), `_toDate` (`DateTime?`)
- `_formattedFromDate` (`String`), `_formattedToDate` (`String`)
- `_fromDateS` (`String`), `_toDateS` (`String`)
- `_selectedDateFilterIndex` (`int?`)
- `_selectedStatusIds` (`List<int> = [0]`), `_selectedStatus` (`int?`)
- `_selectedUser` (`int?`), `_selectedUserIds` (`List<int> = [0]`)
- `_selectedEnquiryFor` (`int?`), `_selectedEnquiryForIds` (`List<int> = [0]`)
- `_selectedEnquirySource` (`int?`), `_selectedEnquirySourceIds` (`List<int> = [0]`)
- `_selectedBranch` (`int?`), `_selectedBranchIds` (`List<int> = [0]`)
- `_search` (`String`)
- `_entryType` (`String = 'myown'`)
- `_isFilter` (`bool`)

---

## 8. Existing Date Filter Architecture

### Reusable Mechanisms in Codebase:
1. **Provider Date Calculation Pattern**:
   Methods `setDateFilter(String title)` in `CustomerProvider`, `LeadsProvider`, `AMCReportProvider`, and `WorkCompletionReportProvider` use identical switch-case calculations for `Yesterday`, `Today`, `Tomorrow`, `This Week`, and `This Month`.
2. **Formatting Helper**:
   `DateStringFormatter` extension in `lib/utils/extensions.dart` provides `toDayMonthYearFormat()`, `toFormattedDate()`, `toUniversalYyyyMmDd()`, and `toyyyymmdd()`.
3. **Common Widgets**:
   `lib/presentation/widgets/reports/common_report_widgets.dart` contains `CommonReportDateFilter` used across report screens.

### Critical Architecture Evaluation:
1. **Can AMC Date use the existing mechanism?**
   - **Frontend UI/State**: Yes, the date picker UI dialog, date calculation logic, and state management pattern can be cloned or generalized for AMC Date.
   - **API Layer**: No, because `Fromdate_` and `Todate_` are already occupied by the generic/Follow-up date filter. AMC Date requires either separate API parameters or a DateType switch parameter.
2. **Can Work Completion Date use the existing mechanism?**
   - **Frontend UI/State**: Yes, using the same pattern.
   - **API Layer**: No, for the same reason.
3. **Would adding two new date filters require a new filter type or multi-date model?**
   - Yes. There are two primary architectural patterns:
     - **Pattern A (Multi-Date Selector / Switch)**: One date range picker paired with a `Date Type` dropdown (Follow-up Date, AMC Date, Work Completion Date).
     - **Pattern B (Independent Filters)**: Three separate date filter buttons on the filter bar (Follow Up Date, AMC Date, Work Completion Date), allowing simultaneous filtering.
4. **Is there an existing `DateType` enum/string/value for Customer Search?**
   - **NO**. In `DashboardProvider` (lines 1165-1166), a `Date_Type` string (`"Task_Date"` vs `"Estimated_Completion_Date"`) is used for user activity reports, but `CustomerProvider` has no `DateType` enum or parameter.
5. **Does the Customer API switch between date types?**
   - Not in the current frontend code. `lead/Search_Customer` only takes `Fromdate_` and `Todate_`.

---

## 9. Customer API

### Endpoint Specification:
```text
HTTP Method:          GET
Base URL:             HttpUrls.baseUrl ('https://vidyanexisapi.trackbox.net.in/')
Endpoint:             lead/Search_Customer (HttpUrls.searchCustomer)
Full Path:            https://vidyanexisapi.trackbox.net.in/lead/Search_Customer
Authentication:       Bearer Token via Authorization Header (handled in HttpRequest.httpGetRequest)
Request Format:       Query Parameters in URL
Response Format:      JSON Array (List<dynamic>)
```

### Complete Query String Structure (`CustomerProvider.dart:545`):
```text
${HttpUrls.searchCustomer}?
  Customer_Name_=$_search
  &Is_Date_=$isDate
  &Fromdate_=$_fromDateS
  &Todate_=$_toDateS
  &To_User_Id_=$toUserId
  &Login_User_Id_=$loginUserId
  &Status_Id_=$_status
  &Page_Index1_=$_startLimit
  &Page_Index2_=$_endLimit
  &Enquiry_For_Id_=$enquiryForId
  &Enquiry_Source_Id_=$enquirySourceId
  &Branch_Id_=$branchIds
  &User_Details_Id_=$loginUserId
  &Order_By_=$apiSortOption
  &Order_Type_=$_sortOrder
  &Entry_Type_=$_entryType
```

---

## 10. API Filter Parameters

| Parameter Name | Data Type | Purpose | Current Frontend Source |
| :--- | :--- | :--- | :--- |
| `Customer_Name_` | `String` | Free-text search query | `searchController.text` / `_search` |
| `Is_Date_` | `String` (`"0"` or `"1"`) | Date filter active flag | `(_fromDateS.isNotEmpty \|\| _toDateS.isNotEmpty) ? "1" : "0"` |
| `Fromdate_` | `String` (`"YYYY-MM-DD"`) | Date range start (Follow Up Date) | `_fromDateS` |
| `Todate_` | `String` (`"YYYY-MM-DD"`) | Date range end (Follow Up Date) | `_toDateS` |
| `To_User_Id_` | `String` (comma-separated) | Assigned staff user IDs | `_selectedUserIds.join(',')` |
| `Login_User_Id_`| `int` | ID of logged-in user | `SharedPreferences.getString('userId')` |
| `Status_Id_` | `String` (comma-separated) | Customer follow-up status IDs | `_selectedStatusIds.join(',')` |
| `Page_Index1_` | `int` | 1-based start row index | `_startLimit` (e.g. 1, 21, 41) |
| `Page_Index2_` | `int` | 1-based end row index | `_endLimit` (e.g. 20, 40, 60) |
| `Enquiry_For_Id_`| `String` (comma-separated)| Product / Enquiry For IDs | `_selectedEnquiryForIds.join(',')` |
| `Enquiry_Source_Id_`| `String` (comma-separated)| Enquiry Source IDs | `_selectedEnquirySourceIds.join(',')`|
| `Branch_Id_` | `String` (comma-separated) | Branch / Department IDs | `_selectedBranchIds.join(',')` |
| `User_Details_Id_`| `int` | Login user ID context | `loginUserId` |
| `Order_By_` | `int` (`0`..`4`) | Sort column index | `_selectedSortOption` |
| `Order_Type_` | `String` (`"ASC"`/`"DESC"`)| Sort direction | `_sortOrder` |
| `Entry_Type_` | `String` (`"myown"`/`"all"`)| Scope filter | `_entryType` |

---

## 11. Pagination

### Current Pagination Implementation:
- **Page Size**: `20` records per page (`_limit = 20`).
- **Indices**:
  - `_startLimit`: Start row offset (1-based, e.g. 1, 21, 41, 61).
  - `_endLimit`: End row offset (1-based, e.g. 20, 40, 60, 80).
- **Total Record Count**: Returned by backend in a separate metadata JSON item where `tp == 2` (parsed as `_totalCount = allItems[metadataIndex].customerId`).
- **Web Pagination Flow**:
  - Back Button: Decrements `_startLimit -= 20; _endLimit -= 20;` and calls `getSearchCustomers(context, isSilent: true)`.
  - Forward Button: Increments `_startLimit += 20; _endLimit += 20;` and calls `getSearchCustomers(context, isSilent: true)`.
- **Mobile Pagination Flow**:
  - `scrollListener` listens to `ScrollController` position. When `position.pixels >= maxScrollExtent - 200`, it triggers `loadMoreCustomers(context)`.
  - `loadMoreCustomers` increments limits, calls API, and appends `newItems` (`tp == 1`) to `_customerData`.

### Filter + Pagination Interaction:
When applying a new filter:
1. `setSearchCriteria` resets `_startLimit = 1`, `_endLimit = 20`, `currentPage = 1`, `hasMoreData = true`, and clears `_customerData`.
2. Provider fetches the first page of filtered results.
3. When user pages forward (Web) or scrolls down (Mobile), the stored filter parameters remain active in the provider and are passed in subsequent page requests.

### Identified Discrepancy / Risk in Existing Pagination:
- In `lib/controller/customer_provider.dart:217` (`loadMoreCustomers`), **`Branch_Id_` is omitted from the API query string**, whereas it is included in `getSearchCustomers` (line 545). This causes mobile infinite scroll to lose the branch filter on page 2+.

---

## 12. Search + Filter Interaction

1. **Simultaneous Usage**:
   - Yes, search text and filters are combined. All filter state is preserved in provider variables (`_search`, `_fromDateS`, `_toDateS`, `_status`, `_selectedUserIds`, `_selectedEnquiryForIds`, `_selectedEnquirySourceIds`, `_selectedBranchIds`, `_entryType`).
2. **Search Reset Behavior**:
   - Typing into `searchController` triggers debounced (500ms) call to `setSearchCriteria(query, customerProvider.fromDateS, customerProvider.toDateS)`.
   - This resets `_startLimit = 1`, `_endLimit = 20`, `currentPage = 1`, while preserving the currently active date filters.
3. **Filter Reset Behavior**:
   - Clicking the "Reset" button clears all dropdown selections, resets date ranges to null/empty, clears search text, and reloads page 1.

---

## 13. Refresh + Filter Interaction

1. **Web Refresh (`IconButton(icon: Icons.refresh)` on `customer_page.dart:447`)**:
   - Calls `customerProvider.setSearchCriteria('', '', '')`, which clears search and date strings, then calls `getSearchCustomers(isSilent: true)`.
   - **Effect**: Resets search text and date filter back to empty on refresh.
2. **Mobile Refresh (`RefreshIndicator` on `customer_page_phone.dart:396`)**:
   - Calls `_refreshData()`, which explicitly sets `setFilter(false)`, clears search criteria via `setSearchCriteria('', '', '')`, and reloads `getSearchCustomers(context)`.
   - **Effect**: Closes filter panel and resets filters to defaults on pull-to-refresh.

---

## 14. Existing Similar Implementations

### 1. Periodic Service (AMC) Report Screen (`lib/presentation/pages/reports/amc_report_screen.dart`):
- **Provider**: `AMCReportProvider` (`lib/controller/amc_report_provider.dart`)
- **Endpoint**: `HttpUrls.searchAmcReport` (`amc/Search_AMC_Report`)
- **Parameters**: `Customer_Name`, `AMC_Status_Id`, `Is_Date`, `Fromdate`, `Todate`, `To_User_Id`
- **UI Pattern**: `onClickTopButton` dialog with `dateButtonTitles` chips + `showDatePicker` from/to pickers.

### 2. Work Completion Report Screen (`lib/presentation/pages/reports/work_completion_report_screen.dart`):
- **Provider**: `WorkCompletionReportProvider` (`lib/controller/work_completion_report_provider.dart`)
- **Endpoint**: `HttpUrls.workCompletionReport` (`lead/Work_Completion_Report`)
- **Parameters**: `Customer_Name`, `Phone_Number`, `Fromdate`, `Todate`
- **UI Pattern**: `_showDateFilterDialog` with quick selection chips + `showDatePicker`.

### 3. Reusable Widgets (`lib/presentation/widgets/reports/common_report_widgets.dart`):
- `CommonReportDateFilter`: Clean container showing `$label : $formattedFromDate - $formattedToDate` with dropdown arrow icon.
- `CommonReportResetButton`: Standard red-bordered reset button.

---

## 15. Recommended Implementation Approach

Two distinct architectural options are available for implementing the AMC Date and Work Completion Date filters:

### Option A: Independent Dedicated Filter Buttons (Recommended for Web Table)
Provide 3 separate date filter buttons in the Customer filter bar:
1. **Follow Up Date**: From / To
2. **AMC Date**: From / To
3. **Work Completion Date**: From / To

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ Filter Bar:                                                                            │
│ [Status: All ▼] [Follow Up Date ▼] [AMC Date ▼] [Work Completion Date ▼] [Staff ▼] ... │
└────────────────────────────────────────────────────────────────────────────────────────┘
```
- **Pros**: Clear, direct, allows simultaneous filtering (e.g. "Customers with AMC ending this month AND Work completed last year").
- **Backend Requirement**: Requires separate API parameters:
  `Is_AMC_Date_`, `AMC_Fromdate_`, `AMC_Todate_`, `Is_Work_Completion_Date_`, `Work_Completion_Fromdate_`, `Work_Completion_Todate_`.

### Option B: Unified Date Filter with Date Type Switch (Recommended for Mobile / Compact UI)
Use a single date picker button with a "Date Type" selector:
- Dropdown / Tab: `Follow Up Date` | `AMC Date` | `Work Completion Date`
- Date Range: Quick chips + From / To date pickers

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ Filter Bar:                                                                            │
│ [Status: All ▼] [Date Filter: AMC Date (01 Aug 2026 - 31 Aug 2026) ▼] [Staff ▼] ...    │
└────────────────────────────────────────────────────────────────────────────────────────┘
```
- **Pros**: Compact, zero horizontal clutter, reusable dialog.
- **Backend Requirement**: Requires a date type selector parameter:
  `Date_Type_` (`1` = Follow Up, `2` = AMC Date, `3` = Work Completion Date) + existing `Is_Date_`, `Fromdate_`, `Todate_`.

---

## 16. Files That Must Be Modified

### 1. `lib/controller/customer_provider.dart`
- **Current Responsibility**: Manages state, API requests, sorting, pagination, and filter parameters for Customer Page.
- **Required Modification**:
  - Add state variables for AMC Date (`_amcFromDate`, `_amcToDate`, `_amcFromDateS`, `_amcToDateS`, `_selectedAmcDateFilterIndex`, `_formattedAmcFromDate`, `_formattedAmcToDate`).
  - Add state variables for Work Completion Date (`_wcFromDate`, `_wcToDate`, `_wcFromDateS`, `_wcToDateS`, `_selectedWcDateFilterIndex`, `_formattedWcFromDate`, `_formattedWcToDate`).
  - Add setter, picker, calculation, and format methods for both date filters.
  - Update `getSearchCustomers`, `loadMoreCustomers`, and `getSearchCustomersNoContext` to include the new date parameters in the query string.
  - Update `clearAllFilters` to reset all date variables.
  - Fix missing `Branch_Id_` in `loadMoreCustomers`.
- **Dependencies**: `intl`, `http_requests.dart`, `http_urls.dart`.
- **Potential Impact**: Core customer data fetching across Web and Mobile.

### 2. `lib/presentation/pages/home/customer_page.dart` (Web Customer Page)
- **Current Responsibility**: Builds the Web Customer Page layout, filter toolbar, dual-scroll table, and pagination controls.
- **Required Modification**:
  - Update `_CustomerPageState` filter bar (lines 663-764) to include UI filter triggers for AMC Date and Work Completion Date.
  - Add dialog builder methods for AMC Date and Work Completion Date (or a unified date picker with type switch).
  - Update reset button logic to reset all date filters.
- **Dependencies**: `CustomerProvider`, `DropDownProvider`, `SettingsProvider`.
- **Potential Impact**: Web customer UI layout and user interaction.

### 3. `lib/presentation/pages/home/customer_page_phone.dart` (Mobile Customer Page)
- **Current Responsibility**: Builds the Mobile Customer Page layout, filter drawer, and infinite scroll list.
- **Required Modification**:
  - Update mobile filter view (lines 271-393) to include AMC Date and Work Completion Date picker controls.
  - Update mobile dialog handler to call provider methods on `CustomerProvider` (fix the existing `leadProvider` local variable reference).
- **Dependencies**: `CustomerProvider`, `SidebarProvider`.
- **Potential Impact**: Mobile customer filtering flow.

---

## 17. Files That May Need Modification

### 1. `lib/http/http_urls.dart`
- **Current Responsibility**: Centralized repository of all API endpoint URL constants.
- **Required Modification**: Only needed if backend introduces a separate endpoint rather than enhancing `lead/Search_Customer` (unlikely, but listed for completeness).
- **Category**: MAY MODIFY

### 2. `lib/controller/models/search_leads_model.dart`
- **Current Responsibility**: Deserializes customer records from JSON.
- **Required Modification**: Already contains `amcDate` and `workCompletionDate` with complete null handling. May only need modification if backend returns new or renamed JSON keys for filtered metadata.
- **Category**: NO CHANGE REQUIRED (unless JSON contract changes)

---

## 18. API Changes Required

### Current API Contract:
```text
GET lead/Search_Customer?Customer_Name_=&Is_Date_=0&Fromdate_=&Todate_=&To_User_Id_=&Login_User_Id_=&Status_Id_=&Page_Index1_=1&Page_Index2_=20&Enquiry_For_Id_=&Enquiry_Source_Id_=&Branch_Id_=&User_Details_Id_=&Lead_Id_=0&Order_By_=0&Order_Type_=DESC&Entry_Type_=myown
```

### Required Backend API Support (One of the following contracts):

#### Contract Option 1 (Dedicated Parameters — For Option A):
```text
&Is_AMC_Date_=<0|1>
&AMC_Fromdate_=<YYYY-MM-DD>
&AMC_Todate_=<YYYY-MM-DD>
&Is_Work_Completion_Date_=<0|1>
&Work_Completion_Fromdate_=<YYYY-MM-DD>
&Work_Completion_Todate_=<YYYY-MM-DD>
```

#### Contract Option 2 (Date Type Switch — For Option B):
```text
&Date_Type_=<1|2|3>          (1 = Follow Up Date, 2 = AMC Date, 3 = Work Completion Date)
&Is_Date_=<0|1>
&Fromdate_=<YYYY-MM-DD>
&Todate_=<YYYY-MM-DD>
```

---

## 19. UI Changes Required

### Web UI (`customer_page.dart`):
1. **Filter Bar**:
   - Add AMC Date filter button: Shows `'AMC Date: All'` or `'AMC Date: YYYY-MM-DD - YYYY-MM-DD'`.
   - Add Work Completion Date filter button: Shows `'Work Completion Date: All'` or `'Work Completion Date: YYYY-MM-DD - YYYY-MM-DD'`.
   - Style with active border highlight (`AppColors.primaryBlue`) when active.
2. **Dialogs**:
   - Provide clean modal dialogs with quick selection chips (`Yesterday`, `Today`, `Tomorrow`, `This Week`, `This Month`) and From/To date pickers.
3. **Reset Button**:
   - Ensure Reset button condition checks `amcFromDate != null` and `wcFromDate != null` to reveal itself when any filter is active.

### Mobile UI (`customer_page_phone.dart`):
1. **Filter Drawer**:
   - Add distinct date picker chips / buttons for Follow Up Date, AMC Date, and Work Completion Date.
2. **Floating Action Button**:
   - Keep "APPLY" FAB behavior to apply all selected filters simultaneously.

---

## 20. State Management Changes Required

### State Variables to Add in `CustomerProvider`:
```dart
// AMC Date Filter State
DateTime? _amcFromDate;
DateTime? _amcToDate;
String _formattedAmcFromDate = '';
String _formattedAmcToDate = '';
String _amcFromDateS = '';
String _amcToDateS = '';
int? _selectedAmcDateFilterIndex;

// Work Completion Date Filter State
DateTime? _wcFromDate;
DateTime? _wcToDate;
String _formattedWcFromDate = '';
String _formattedWcToDate = '';
String _wcFromDateS = '';
String _wcToDateS = '';
int? _selectedWcDateFilterIndex;
```

### Methods to Add in `CustomerProvider`:
```dart
// Getters
DateTime? get amcFromDate => _amcFromDate;
DateTime? get amcToDate => _amcToDate;
String get formattedAmcFromDate => _formattedAmcFromDate;
String get formattedAmcToDate => _formattedAmcToDate;
int? get selectedAmcDateFilterIndex => _selectedAmcDateFilterIndex;

DateTime? get wcFromDate => _wcFromDate;
DateTime? get wcToDate => _wcToDate;
String get formattedWcFromDate => _formattedWcFromDate;
String get formattedWcToDate => _formattedWcToDate;
int? get selectedWcDateFilterIndex => _selectedWcDateFilterIndex;

// AMC Setters & Pickers
void setAmcDateFilter(String title);
void setAmcFromDate(DateTime date);
void setAmcToDate(DateTime date);
void selectAmcDateFilterOption(int? index);
Future<void> selectAmcDate(BuildContext context, bool isFromDate);

// Work Completion Setters & Pickers
void setWcDateFilter(String title);
void setWcFromDate(DateTime date);
void setWcToDate(DateTime date);
void selectWcDateFilterOption(int? index);
Future<void> selectWcDate(BuildContext context, bool isFromDate);
```

---

## 21. Pagination Changes Required

1. **Reset Limits on Filter Change**:
   - When AMC Date or Work Completion Date is applied, `_startLimit = 1` and `_endLimit = 20` must be set, and `_customerData.clear()` must be called.
2. **Preserve Parameters Across Pages**:
   - `fetchNextPage`, `fetchPreviousPage`, and `loadMoreCustomers` must retain AMC and Work Completion date parameters in their query string.
3. **Fix Load-More Parameter Integrity**:
   - Ensure `loadMoreCustomers` includes `Branch_Id_`, `Order_By_`, `Order_Type_`, and the new AMC/Work Completion parameters.

---

## 22. Edge Cases

1. **Null/Empty Dates in Database**:
   - Many customers have no AMC contract or incomplete work completion. The backend query must treat null/empty records correctly and not crash.
2. **Invalid Date Range Selection**:
   - If user selects a `From Date` greater than `To Date`, the UI should validate and swap or notify the user before making the API request.
3. **Different Date Formats**:
   - UI standard is `yyyy-MM-dd` for API submission, while table display expects `dd MMM yyyy`. Formatter functions in `lib/utils/extensions.dart` must be used consistently.
4. **Timezone Offsets**:
   - Avoid ISO UTC string conversion shifts (e.g. `2026-08-20T18:30:00.000Z` turning into previous date). Use local date formatting: `DateFormat('yyyy-MM-dd').format(date)`.
5. **Simultaneous Multiple Date Filters**:
   - If user sets Follow-up Date to "This Week" and AMC Date to "This Month", the backend query must apply an `AND` condition between both filter sets.

---

## 23. Risks

1. **Backend Parameter Mismatch**:
   - If the frontend sends parameter names that the backend stored procedure does not recognize (e.g., `AMC_Fromdate_` vs `AmcFromDate_`), the filter will either be ignored or return a 500 Server Error.
2. **Pagination Data Loss on Mobile**:
   - If `loadMoreCustomers` is not updated in lockstep with `getSearchCustomers`, scrolling down on mobile will load unfiltered customers on page 2.
3. **Web Horizontal Table Layout Overflow**:
   - Adding additional columns is not required (since columns already exist), but adding filter chips to the filter toolbar must use `Wrap` to prevent horizontal overflow on smaller desktop screens.

---

## 24. Confirmed Information

```text
[CONFIRMED FROM CODE]
1. SearchLeadModel already has `amcDate` and `workCompletionDate` properties with `.amcDateDisplay` and `.workCompletionDateDisplay` getters.
2. Web Customer table already displays both 'AMC Date' and 'Work Completion Date' columns.
3. Excel export already outputs 'AMC Date' and 'Work Completion Date' in both Web and Mobile.
4. Customer page uses Provider state management with `CustomerProvider`.
5. Existing date filter in CustomerProvider only handles Follow-up Date via `Is_Date_`, `Fromdate_`, `Todate_`.
6. API endpoint is `lead/Search_Customer` using HTTP GET and 1-based start/end row pagination.
7. Total count is parsed from metadata record with `item.tp == 2`.
8. Date format for API requests across the app is strictly 'yyyy-MM-dd'.
9. Display date format is 'dd MMM yyyy'.
```

---

## 25. Information Not Found / Requires Verification

```text
[NOT CONFIRMED — REQUIRES BACKEND VERIFICATION]
1. Exact parameter names supported by the backend `lead/Search_Customer` endpoint for AMC Date filtering (e.g. `AMC_Fromdate_`, `AMC_Todate_`, `Is_AMC_Date_`, or `Date_Type_`).
2. Exact parameter names supported by the backend for Work Completion Date filtering (e.g. `Work_Completion_Fromdate_`, `Work_Completion_Todate_`, `Is_Work_Completion_Date_`).
3. Whether backend stored procedure uses `AND` logic when multiple date filters (Follow-up + AMC + Work Completion) are passed simultaneously.
4. Whether backend already supports `Date_Type_` switch parameter or if new dedicated parameters must be deployed on the API server.
```

---

## 26. Proposed End-to-End Flow

```text
[User selects AMC Date / Work Completion Date Filter]
                        ↓
[Date Filter Modal Opens]
  ├── Quick chips: Yesterday, Today, Tomorrow, This Week, This Month
  └── Custom From & To date pickers
                        ↓
[User clicks "Apply"]
                        ↓
[CustomerProvider updates state]
  ├── Sets _amcFromDateS, _amcToDateS / _wcFromDateS, _wcToDateS
  ├── Resets _startLimit = 1, _endLimit = 20, currentPage = 1
  └── Clears _customerData
                        ↓
[API Call to lead/Search_Customer]
  └── Includes AMC and Work Completion query parameters
                        ↓
[Backend filters records]
  └── Returns matching customers (tp == 1) + updated total count (tp == 2)
                        ↓
[UI Re-renders]
  ├── Active filter buttons show selected date range in blue
  ├── Table displays matching filtered rows
  └── Pagination controls reflect new total count
                        ↓
[User Pages or Scrolls (Load More)]
  └── Next page API call preserves all active filter parameters
```

---

## 27. Implementation Checklist

- [ ] **Step 1: Backend Alignment**
  - [ ] Confirm exact query parameter names with backend team for AMC Date and Work Completion Date filtering.
- [ ] **Step 2: Update CustomerProvider (`lib/controller/customer_provider.dart`)**
  - [ ] Add state variables for AMC Date (`_amcFromDate`, `_amcToDate`, `_amcFromDateS`, `_amcToDateS`, etc.).
  - [ ] Add state variables for Work Completion Date (`_wcFromDate`, `_wcToDate`, `_wcFromDateS`, `_wcToDateS`, etc.).
  - [ ] Add setter, picker, and calculation methods for AMC Date.
  - [ ] Add setter, picker, and calculation methods for Work Completion Date.
  - [ ] Update `getSearchCustomers`, `loadMoreCustomers`, and `getSearchCustomersNoContext` query strings.
  - [ ] Fix missing `Branch_Id_` parameter in `loadMoreCustomers`.
  - [ ] Update `clearAllFilters` to reset new date state.
- [ ] **Step 3: Update Web Customer Page (`lib/presentation/pages/home/customer_page.dart`)**
  - [ ] Add AMC Date filter button and dialog trigger.
  - [ ] Add Work Completion Date filter button and dialog trigger.
  - [ ] Update filter reset button condition and click handler.
- [ ] **Step 4: Update Mobile Customer Page (`lib/presentation/pages/home/customer_page_phone.dart`)**
  - [ ] Add AMC Date and Work Completion Date filter triggers in mobile filter drawer.
  - [ ] Wire dialogs to `CustomerProvider`.
- [ ] **Step 5: Verification & Quality Assurance**
  - [ ] Verify Follow-up Date filter continues to work without regression.
  - [ ] Verify AMC Date filter correctly isolates customers with AMC in range.
  - [ ] Verify Work Completion Date filter correctly isolates completed projects.
  - [ ] Verify combined filtering (Search + Status + Staff + AMC + Work Completion).
  - [ ] Verify pagination on Web (Previous/Next) and Mobile (infinite scroll).
  - [ ] Verify Excel export contains accurate filtered datasets.
