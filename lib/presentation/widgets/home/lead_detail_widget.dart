import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/follow_up_history_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/pages/home/expense_screen.dart';

class LeadDetailsWidget extends StatefulWidget {
  final String customerId;
  final VoidCallback onFollowUpPressed;
  final VoidCallback onEditPressed;

  const LeadDetailsWidget(
      {super.key,
      required this.customerId,
      required this.onFollowUpPressed,
      required this.onEditPressed});

  @override
  LeadDetailsWidgetState createState() => LeadDetailsWidgetState();
}

class LeadDetailsWidgetState extends State<LeadDetailsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);
      leadDetailsProvider.fetchLeadDetails(widget.customerId, context);
      leadDetailsProvider.fetchFollowUpHistory(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sideprovider = Provider.of<SidebarProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Consumer<LeadDetailsProvider>(
      builder: (context, leadDetailsProvider, child) {
        if (leadDetailsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (leadDetailsProvider.leadDetails == null ||
            leadDetailsProvider.leadDetails!.isEmpty) {
          return const Center(child: Text(''));
        }

        final leadDetails = leadDetailsProvider.leadDetails![0];

        return Container(
          width: AppStyles.isWebScreen(context)
              ? MediaQuery.of(context).size.width / 3
              : MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lead Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                      ],
                    ),
                    if (settingsProvider.menuIsEditMap[3] == 1)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 22, color: Colors.blue),
                        tooltip: 'Edit',
                        onPressed: () async {
                          await leadDetailsProvider.fetchLeadDetails(
                              widget.customerId, context);
                          final leadsProvider = Provider.of<LeadsProvider>(
                              context,
                              listen: false);
                          final dropDownProvider =
                              Provider.of<DropDownProvider>(context,
                                  listen: false);
                          leadsProvider.enquirySourceController.text =
                              leadDetails.enquirySourceName.toString();
                          dropDownProvider.selectedEnquirySourceId =
                              leadDetails.enquirySourceId;
                          await leadsProvider.getLeadDropdowns(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const NewLeadDrawerWidget(
                                isEdit: true,
                              );
                            },
                          );
                        },
                      ),
                    if (settingsProvider.menuIsDeleteMap[3] == 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 22, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this lead?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final leadsProvider =
                                          Provider.of<LeadsProvider>(context,
                                              listen: false);
                                      await leadsProvider.deleteLead(
                                          context, widget.customerId);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        sideprovider.replaceWidget(
                            false, widget.customerId.toString());
                        CustomerDetailsScreen(
                          customerId: widget.customerId.toString(),
                          report: 'false',
                        );
                        // context.push(
                        //     '${CustomerDetailsScreen.route}${widget.customerId.toString()}');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white, // Text color
                        side: BorderSide(
                            color: AppColors.primaryBlue), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 0.0), // Reduced horizontal padding
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.primaryBlue,
                          ),
                          if (AppStyles.isWebScreen(context))
                            const Text(
                              'View Details',
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: widget.onFollowUpPressed,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white, // Text color
                        side: BorderSide(
                            color: AppColors.primaryBlue), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 0.0), // Reduced horizontal padding
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.primaryBlue,
                          ),
                          if (AppStyles.isWebScreen(context))
                            const Text(
                              'Follow-Up',
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: _showConvertDialog,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: Colors.white, // Text color
                        side: const BorderSide(
                            color: Colors.green), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 0.0), // Reduced horizontal padding
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.change_circle_outlined,
                            color: Colors.green,
                          ),
                          if (AppStyles.isWebScreen(context))
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text(
                                'Convert Lead',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFA2C6EB),
                      child: Icon(Icons.person_rounded,
                          size: 40, color: Color(0xFFE5F0FF)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  leadDetails.customerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                leadDetails.contactNumber.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      // width: 150,
                      child: const Text(
                        'Status : ',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: leadDetails.statusName.isNotEmpty
                          ? const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2)
                          : const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        // color: StatusUtils.getStatusColor(leadDetails.statusId),
                        color: parseColor(leadDetails.colorCode)
                            .withOpacity(0.1)
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black45, width: 0.1),
                      ),
                      child: Text(
                        leadDetails.statusName,
                        style: TextStyle(
                          // color: StatusUtils.getStatusTextColor(
                          //     leadDetails.statusId),
                          color: parseColor(leadDetails.colorCode),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: AppColors.primaryBlue,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        dividerColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: 'Personal details'),
                          Tab(text: 'Follow-Up history'),
                          Tab(text: 'Expense'),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: TabBarView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Address',
                                      leadDetails.address.toString()),
                                  _buildDetailRow('Phone Number',
                                      leadDetails.phoneNumber.toString()),
                                  _buildDetailRow('Total Project Cost',
                                      leadDetails.totalProjectCost.toString()),
                                ],
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F7F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: leadDetailsProvider
                                        .followUpHistory!.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: leadDetailsProvider
                                            .followUpHistory!.length,
                                        itemBuilder: (context, index) {
                                          return FollowUpCard(
                                              entry: leadDetailsProvider
                                                  .followUpHistory![index]);
                                        },
                                      )
                                    : const Center(
                                        child: Text(
                                        'No Data Found',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ))),
                            ExpenseScreen(widget.customerId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align all items to the start
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align to the top of the row
          children: [
            SizedBox(
              width: 150,
              child: Text(
                '$label : ',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
                // overflow: TextOverflow
                //     .ellipsis, // Optional: Truncate text if it's too long
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConvertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Convert'),
          content: const Text('Are you sure you want to convert this lead?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final leadsProvider =
                    Provider.of<LeadsProvider>(context, listen: false);
                await leadsProvider.convertLead(context, widget.customerId);
              },
              child: const Text(
                'Convert',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
