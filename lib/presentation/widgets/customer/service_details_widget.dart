import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_service.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';

class ServiceDetailsWidget extends StatelessWidget {
  final String customerId;
  final String serviceId;
  bool showEdit;
  ServiceDetailsWidget({
    super.key,
    required this.customerId,
    required this.serviceId,
    this.showEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Complaint Details',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (settingsprovider.menuIsEditMap[14] == 1)
                if (showEdit)
                  IconButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      customerDetailsProvider.customerId = customerId;
                      customerDetailsProvider.setServiceEditDropDown(
                          customerDetailsProvider
                              .serviceDetails[0].serviceTypeId,
                          customerDetailsProvider
                              .serviceDetails[0].serviceTypeName,
                          customerDetailsProvider
                              .serviceDetails[0].serviceStatusId,
                          customerDetailsProvider
                              .serviceDetails[0].serviceStatusName);
                      customerDetailsProvider.taskDescriptionController.text =
                          customerDetailsProvider.serviceDetails[0].description
                              .toString();
                      customerDetailsProvider.serviceController.text =
                          customerDetailsProvider.serviceDetails[0].serviceName
                              .toString();
                      customerDetailsProvider.serviceAmountController.text =
                          customerDetailsProvider.serviceDetails[0].amount
                              .toString();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ServiceCreationWidget(
                              taskId: serviceId,
                              isEdit: true,
                              customerId: customerId);
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 8),
          // if (customerDetailsProvider.serviceDetails.isNotEmpty)
          // Text(
          //   // 'Posted on : ',
          //   'Posted on : ${_formatDate(customerDetailsProvider.serviceDetails[0].createDate.toString())}',
          //   style: GoogleFonts.plusJakartaSans(
          //     color: AppColors.textGrey3,
          //     fontSize: 12,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customerDetailsProvider.serviceDetails.isNotEmpty
              ? Container(
                  color: Colors.white,
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionTile(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              title: Text(
                                'Complaint Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              tilePadding: EdgeInsets.zero,
                              initiallyExpanded: true,
                              children: [
                                // TaskLabelValue(
                                //   colorUser: AppColors.grey,
                                //   isAssignee: true,
                                //   label: 'Customer',
                                //   value: customerDetailsProvider
                                //       .serviceDetails[0].serviceDate
                                //       .toString(),
                                // ),
                                // const SizedBox(height: 16),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 120,
                                        child: Text(
                                          'Status',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textGrey4,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )),
                                    const SizedBox(width: 12),
                                    Text(
                                      customerDetailsProvider
                                          .serviceDetails[0].serviceStatusName,
                                      style: TextStyle(
                                          color: customerDetailsProvider
                                                      .serviceDetails[0]
                                                      .serviceStatusName
                                                      .toString() ==
                                                  "Completed"
                                              ? Colors.green
                                              : customerDetailsProvider
                                                          .serviceDetails[0]
                                                          .serviceStatusName
                                                          .toString() ==
                                                      "Pending"
                                                  ? Colors.orange
                                                  : Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  colorUser: AppColors.grey,
                                  label: 'Added Date',
                                  // value: customerDetailsProvider
                                  //     .serviceDetails[0].createDate
                                  //     .toString(),
                                  value: customerDetailsProvider
                                              .serviceDetails[0]
                                              .createDate
                                              .isNotEmpty &&
                                          customerDetailsProvider
                                                  .serviceDetails[0]
                                                  .createDate !=
                                              'null'
                                      ? DateFormat('MMM dd, yyyy').format(
                                          DateTime.parse(customerDetailsProvider
                                              .serviceDetails[0].createDate))
                                      : '',
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  colorUser: AppColors.grey,
                                  label: 'Service type',
                                  value: customerDetailsProvider
                                      .serviceDetails[0].serviceTypeName,
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  colorUser: AppColors.grey,
                                  label: 'Complaints',
                                  value: customerDetailsProvider
                                      .serviceDetails[0].serviceName,
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  colorUser: AppColors.grey,
                                  label: 'Amount',
                                  value: customerDetailsProvider
                                      .serviceDetails[0].amount,
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  colorUser: AppColors.grey,
                                  label: 'Description',
                                  value: customerDetailsProvider
                                      .serviceDetails[0].description,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                            // Divider(
                            //   thickness: 0.2,
                            // ),
                            // ExpansionTile(
                            //   shape: const RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.zero,
                            //   ),
                            //   title: Text(
                            //     'Task Details',
                            //     style: TextStyle(
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.textGrey3,
                            //     ),
                            //   ),
                            //   tilePadding: EdgeInsets.zero,
                            //   initiallyExpanded: true,
                            //   // childrenPadding: const EdgeInsets.all(
                            //   //     16.0), // Adds padding to the expanded content
                            //   children: [
                            //     TaskLabelValue(
                            //       colorUser: AppColors.grey,
                            //       isAssignee: true,
                            //       label: 'Assigned To',
                            //       value: customerDetailsProvider
                            //           .serviceDetails[0].serviceName,
                            //     ),
                            //     const SizedBox(height: 16),
                            //     Row(
                            //       children: [
                            //         SizedBox(
                            //           width: 120,
                            //           child: Text(
                            //             'Task type',
                            //             style: GoogleFonts.plusJakartaSans(
                            //               color: AppColors.textGrey4,
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w400,
                            //             ),
                            //           ),
                            //         ),
                            //         const SizedBox(width: 12),
                            //         Image.asset(
                            //           customerDetailsProvider.serviceDetails[0]
                            //                       .serviceTypeId
                            //                       .toString() ==
                            //                   "1"
                            //               ? 'assets/images/Task type=Site Visit.png'
                            //               : customerDetailsProvider
                            //                           .serviceDetails[0]
                            //                           .serviceTypeId
                            //                           .toString() ==
                            //                       "2"
                            //                   ? 'assets/images/Task type=Installation.png'
                            //                   : customerDetailsProvider
                            //                               .serviceDetails[0]
                            //                               .serviceTypeId
                            //                               .toString() ==
                            //                           "3"
                            //                       ? 'assets/images/Task type=Service.png'
                            //                       : 'assets/images/Task type=AMC.png',
                            //           height: 25,
                            //         ),
                            //       ],
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       label: 'Description',
                            //       value: customerDetailsProvider
                            //           .serviceDetails[0].description
                            //           .toString(),
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       label: 'Completion Date',
                            //       value: customerDetailsProvider
                            //           .serviceDetails[0].serviceDate
                            //           .toString(),
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       label: 'Completion Time',
                            //       value: customerDetailsProvider
                            //           .serviceDetails[0].serviceDate
                            //           .toString(),
                            //     ),
                            //     const SizedBox(height: 16),
                            //     const SizedBox(height: 5),
                            //     Align(
                            //       alignment: Alignment.topLeft,
                            //       child: Text(
                            //         'Task logs',
                            //         style: GoogleFonts.plusJakartaSans(
                            //           color: AppColors.textGrey3,
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(height: 16),
                            //     // customerDetailsProvider.serviceDetails[0]
                            //     //         .taskDocuments.isNotEmpty
                            //     //     ? ListView.separated(
                            //     //         separatorBuilder: (context, index) {
                            //     //           return const SizedBox(
                            //     //             height:
                            //     //                 16, // Space between list items
                            //     //           );
                            //     //         },
                            //     //         shrinkWrap:
                            //     //             true, // Makes the list only take as much space as it needs
                            //     //         physics:
                            //     //             const ClampingScrollPhysics(), // Prevents scrolling beyond content
                            //     //         itemCount: customerDetailsProvider
                            //     //             .serviceDetails[0]
                            //     //             .taskDocuments
                            //     //             .length, // Getting the number of documents
                            //     //         itemBuilder: (context, index) {
                            //     //           final taskDocument =
                            //     //               customerDetailsProvider
                            //     //                       .serviceDetails[0]
                            //     //                       .taskDocuments[
                            //     //                   index]; // Get each task document

                            //     //           return UserInfoCard(
                            //     //             name: taskDocument
                            //     //                 .userDetailsName, // Displaying the user's name who uploaded the document
                            //     //             category:
                            //     //                 'Document', // Static text for category (can be dynamic if needed)
                            //     //             items: [
                            //     //               taskDocument.filePath
                            //     //             ], // Showing the file path of the document
                            //     //             notes:
                            //     //                 '', // Notes: can include more info like user name
                            //     //           );
                            //     //         },
                            //     //       )
                            //     //     : Center(child: Text('No Task Logs')),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      // If the date is not empty and valid
      if (date.isNotEmpty) {
        DateTime parsedDate =
            DateTime.parse(date); // Parse the string into DateTime
        return DateFormat('dd MMM yyyy')
            .format(parsedDate); // Format into dd MMM yyyy format
      } else {
        return ''; // Return empty string if no date is provided
      }
    } catch (e) {
      return ''; // Return empty string in case of invalid date format
    }
  }
}
