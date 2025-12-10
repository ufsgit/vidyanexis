import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_task.dart';
import 'package:techtify/presentation/widgets/customer/task_label_widget.dart';
import 'package:techtify/presentation/widgets/customer/user_info_card_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';

class TaskDetailsWidget extends StatefulWidget {
  String taskId;
  String customerId;
  bool showEdit;

  TaskDetailsWidget(
      {super.key,
      required this.taskId,
      required this.customerId,
      this.showEdit = true});

  @override
  State<TaskDetailsWidget> createState() => _TaskDetailsWidgetState();
}

class _TaskDetailsWidgetState extends State<TaskDetailsWidget> {
  @override
  void initState() {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(listen: false, context);
    customerDetailsProvider.taskDetails.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Task Details',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              if (settingsProvider.menuIsEditMap[13] == 1)
                if (widget.showEdit)
                  IconButton(
                      onPressed: () async {
                        // Navigator.pop(context);
                        print('asddddddddddddd');
                        customerDetailsProvider.customerId = widget.customerId;
                        await customerDetailsProvider.getTaskUsers(
                            customerDetailsProvider
                                .taskDetails[0].taskMasterId);

                        customerDetailsProvider.setTaskEditDropDown(
                            customerDetailsProvider.taskDetails[0].taskTypeId,
                            customerDetailsProvider.taskDetails[0].taskTypeName,
                            customerDetailsProvider.taskDetails[0].toUserId,
                            customerDetailsProvider.taskDetails[0].toUserName,
                            customerDetailsProvider.taskDetails[0].taskStatusId,
                            customerDetailsProvider
                                .taskDetails[0].taskStatusName);
                        customerDetailsProvider.taskDescriptionController.text =
                            customerDetailsProvider.taskDetails[0].description
                                .toString();
                        customerDetailsProvider.taskChoosedateController.text =
                            customerDetailsProvider.taskDetails[0].taskDate
                                            .toString() !=
                                        'null' &&
                                    customerDetailsProvider
                                        .taskDetails[0].taskDate
                                        .toString()
                                        .isNotEmpty
                                ? DateFormat('dd MMM yyyy').format(
                                    DateTime.parse(customerDetailsProvider
                                        .taskDetails[0].taskDate
                                        .toString()))
                                : '';
                        customerDetailsProvider.taskChoosetimeController.text =
                            customerDetailsProvider.taskDetails[0].taskTime
                                .toString();

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return TaskCreationWidget(
                                taskDetails:
                                    customerDetailsProvider.taskDetails[0],
                                isEdit: true,
                                taskId: customerDetailsProvider
                                    .taskDetails[0].taskMasterId
                                    .toString());
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_outlined)),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 2),
          if (customerDetailsProvider.taskDetails.isNotEmpty)
            Text(
              // 'Posted on : ',
              'Created on : ${_formatDate(customerDetailsProvider.taskDetails[0].entryDate)}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey3,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customerDetailsProvider.taskDetails.isNotEmpty
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
                            // ExpansionTile(
                            //   shape: const RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.zero,
                            //   ),
                            //   title: Text(
                            //     'Service Details',
                            //     style: TextStyle(
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.textGrey3,
                            //     ),
                            //   ),
                            //   tilePadding: EdgeInsets.zero,
                            //   initiallyExpanded: false,
                            //   children: [
                            //     TaskLabelValue(
                            //       colorUser: AppColors.grey,
                            //       isAssignee: true,
                            //       label: 'Customer',
                            //       value: customerDetailsProvider
                            //           .taskDetails[0].customerName,
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       colorUser: AppColors.grey,
                            //       label: 'Added Date',
                            //       value: customerDetailsProvider
                            //           .taskDetails[0].entryDate,
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       colorUser: AppColors.grey,
                            //       label: 'Service type',
                            //       value: customerDetailsProvider
                            //           .taskDetails[0].taskTypeName,
                            //     ),
                            //     const SizedBox(height: 16),
                            //     TaskLabelValue(
                            //       colorUser: AppColors.grey,
                            //       label: 'Description',
                            //       value: customerDetailsProvider
                            //           .taskDetails[0].description,
                            //     ),
                            //     const SizedBox(height: 16),
                            //   ],
                            // ),
                            // Divider(
                            //   thickness: 0.2,
                            // ),
                            ExpansionTile(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              title: Text(
                                'Task Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              tilePadding: EdgeInsets.zero,
                              initiallyExpanded: true,
                              // childrenPadding: const EdgeInsets.all(
                              //     16.0), // Adds padding to the expanded content
                              children: [
                                // TaskLabelValue(
                                //   colorUser: AppColors.grey,
                                //   isAssignee: true,
                                //   label: 'Assigned To',
                                //   value: customerDetailsProvider
                                //       .taskDetails[0].toUserName,
                                // ),
                                // const SizedBox(height: 16),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: AppStyles.isWebScreen(context)
                                          ? 120
                                          : null,
                                      child: Text(
                                        'Task type',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textGrey4,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color:
                                              AppColors.green.withOpacity(.3)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomText(
                                          customerDetailsProvider
                                              .taskDetails[0].taskTypeName,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Image.asset(
                                    //   customerDetailsProvider
                                    //               .taskDetails[0].taskTypeId
                                    //               .toString() ==
                                    //           "1"
                                    //       ? 'assets/images/Task type=Site Visit.png'
                                    //       : customerDetailsProvider
                                    //                   .taskDetails[0].taskTypeId
                                    //                   .toString() ==
                                    //               "2"
                                    //           ? 'assets/images/Task type=Installation.png'
                                    //           : customerDetailsProvider
                                    //                       .taskDetails[0]
                                    //                       .taskTypeId
                                    //                       .toString() ==
                                    //                   "3"
                                    //               ? 'assets/images/Task type=Service.png'
                                    //               : 'assets/images/Task type=AMC.png',
                                    //   height: 25,
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TaskLabelValue(
                                  label: 'Description',
                                  value: customerDetailsProvider
                                      .taskDetails[0].description
                                      .toString(),
                                ),
                                const SizedBox(height: 16),
                                // TaskLabelValue(
                                //   label: 'Start Date , Time',
                                //   value:
                                //       '${customerDetailsProvider.taskDetails[0].startDate},${customerDetailsProvider.taskDetails[0].startTime}',
                                // ),
                                // const SizedBox(height: 16),
                                // TaskLabelValue(
                                //   label: 'Start Time',
                                //   value: customerDetailsProvider
                                //       .taskDetails[0].startTime
                                //       .toString(),
                                // ),
                                // const SizedBox(height: 16),
                                // TaskLabelValue(
                                //   label: 'Completion Date , Time',
                                //   value:
                                //       '${customerDetailsProvider.taskDetails[0].completionDate},${customerDetailsProvider.taskDetails[0].completionTime}',
                                // ),
                                const SizedBox(height: 16),
                                // TaskLabelValue(
                                //   label: 'Completion Time',
                                //   value: customerDetailsProvider
                                //       .taskDetails[0].completionTime
                                //       .toString(),
                                // ),
                                const SizedBox(height: 16),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Task logs',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textGrey3,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                customerDetailsProvider.taskDetails[0]
                                            .taskDocuments.isNotEmpty ||
                                        customerDetailsProvider
                                            .taskDetails[0].taskNotes.isNotEmpty
                                    ? ListView.separated(
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height:
                                                16, // Space between list items
                                          );
                                        },
                                        shrinkWrap:
                                            true, // Makes the list only take as much space as it needs
                                        physics:
                                            const ClampingScrollPhysics(), // Prevents scrolling beyond content
                                        itemCount: customerDetailsProvider
                                            .taskDetails[0]
                                            .taskDocuments
                                            .length, // Getting the number of documents
                                        itemBuilder: (context, index) {
                                          final taskDocument =
                                              customerDetailsProvider
                                                      .taskDetails[0]
                                                      .taskDocuments[
                                                  index]; // Get each task document

                                          return UserInfoCard(
                                            name: taskDocument
                                                .userDetailsName, // Displaying the user's name who uploaded the document
                                            category:
                                                'Document', // Static text for category (can be dynamic if needed)
                                            items: taskDocument.documents,
                                            // Showing the file path of the document
                                            // notes: '',
                                            notes: taskDocument
                                                .documents[0].taskNote,
                                            // taskId: customerDetailsProvider
                                            //     .taskDetails[0].taskId[index],
                                            taskId: taskDocument
                                                .documents[0].taskId,
                                          );
                                        },
                                      )
                                    : const Center(child: Text('No Task Logs')),
                                // if (customerDetailsProvider.taskDetails[0]
                                //         .taskDocuments.isNotEmpty ||
                                //     customerDetailsProvider
                                //         .taskDetails[0].taskNotes.isNotEmpty)
                                //   Align(
                                //     alignment: Alignment.topLeft,
                                //     child: Padding(
                                //       padding: const EdgeInsets.only(left: 25),
                                //       child: Text(
                                //         'Notes',
                                //         style: GoogleFonts.plusJakartaSans(
                                //           color: AppColors.textGrey3,
                                //           fontSize: 12,
                                //           fontWeight: FontWeight.w500,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // const SizedBox(height: 8),
                                // Align(
                                //   alignment: Alignment.topLeft,
                                //   child: Padding(
                                //     padding: const EdgeInsets.only(left: 25),
                                //     child: Text(
                                //       customerDetailsProvider.taskDetails[0]
                                //                   .taskNotes.isNotEmpty &&
                                //               customerDetailsProvider
                                //                       .taskDetails[0]
                                //                       .taskNotes[0]
                                //                       .taskNote !=
                                //                   'null'
                                //           ? customerDetailsProvider
                                //               .taskDetails[0]
                                //               .taskNotes[0]
                                //               .taskNote
                                //           : '',
                                //       style: GoogleFonts.plusJakartaSans(
                                //         color: AppColors.textGrey3,
                                //         fontSize: 12,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
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
