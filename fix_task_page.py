import sys
content = open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'r', encoding='utf-8').read()

old_logic = '''  void _showCustomerBottomSheet(int customerId, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeadDetailsBottomSheet(
        leadId: customerId,
        initialIndex: initialIndex,
      ),
    );
  }

  void _handleCustomerAction(String action, int customerId) {
    final customerProvider = Provider.of<CustomerPageProvider>(context, listen: false);
    switch (action) {
      case 'quotation':
        _showCustomerBottomSheet(customerId, 2);
        break;
      case 'quotation_list_tab':
        _showCustomerBottomSheet(customerId, 0);
        break;
      case 'document':
        _showCustomerBottomSheet(customerId, 3);
        break;
      case 'documents_tab':
        _showCustomerBottomSheet(customerId, 4);
        break;
      case 'edit':
        customerProvider.addCustomerInit(context, customerId);
        break;
    }
  }'''

new_logic = '''  void _handleCustomerAction(String action, int customerId) async {
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    
    if (action == 'edit') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context, listen: false);
      await leadDetailsProvider.fetchLeadDetails(customerId.toString(), context);

      leadsProvider.setCutomerId(customerId);
      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);

      if (leadDetailsProvider.leadDetails != null && leadDetailsProvider.leadDetails!.isNotEmpty) {
        final leadDetails = leadDetailsProvider.leadDetails![0];
        leadsProvider.enquirySourceController.text = leadDetails.enquirySourceName.toString();
        dropDownProvider.selectedEnquirySourceId = leadDetails.enquirySourceId;
        await leadsProvider.getLeadDropdowns(context);
      }
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NewLeadDrawerWidget(
            isEdit: true,
          );
        },
      );
    } else if (action == 'quotation') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => QuotationCreationWidget(
          isEdit: false,
          customerId: customerId.toString(),
          quotationId: '0',
        ),
      );
    } else if (action == 'quotation_list_tab') {
      CustomerDetailsProvider customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.setCustomerId(customerId.toString());
      customerDetailsProvider.setInitialTabName("Quotations");
      final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
      sideProvider.name = 'Customers /';

      context.push('/customerDetails/\/false');
    } else if (action == 'document') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => ImageUploadAlert(
          customerId: customerId.toString(),
        ),
      );
    } else if (action == 'documents_tab') {
      CustomerDetailsProvider customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.setCustomerId(customerId.toString());
      customerDetailsProvider.setInitialTabName("Documents");
      final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
      sideProvider.name = 'Customers /';

      context.push('/customerDetails/\/false');
    }
  }'''

content = content.replace('\r\n', '\n')
old_logic = old_logic.replace('\r\n', '\n')

if old_logic in content:
    content = content.replace(old_logic, new_logic)
    open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'w', encoding='utf-8').write(content)
    print("Success")
else:
    print("Failed to find block")
