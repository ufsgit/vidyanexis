import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_checklist_management_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:provider/provider.dart';

class CheckListManagementWidget extends StatefulWidget {
  final String customerId;

  const CheckListManagementWidget({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CheckListManagementWidget> createState() =>
      _CheckListManagementWidgetState();
}

class _CheckListManagementWidgetState extends State<CheckListManagementWidget> {
  SettingsProvider settingsProvider =
      Provider.of<SettingsProvider>(navigatorKey.currentState!.context);
  Future<List<DocumentChecklistModel>>? checkListListFuture;

  List<DocumentChecklistModel> documentList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkListListFuture = settingsProvider.getDocumentCheckList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Spacer(),
            if (settingsProvider.menuIsSaveMap[37] == 1)
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddCheckListManagementWidget(
                        documentChecklistModel: DocumentChecklistModel(),
                      );
                    },
                  ).then((value) {
                    if (null != value && value) {
                      checkListListFuture =
                          settingsProvider.getDocumentCheckList(context);
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Checklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: AppStyles.isWebScreen(context)
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // You can uncomment and customize the list when needed:
        Expanded(
          child: FutureBuilder<List<DocumentChecklistModel>>(
              future: checkListListFuture,
              builder: (contextBuilder, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.appViolet),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading checklist data...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey1,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                documentList = snapshot.data ?? [];

                if (documentList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        Icon(Icons.category_outlined,
                            size: 60,
                            color: AppColors.textGrey1.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No checklist found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try refreshing or adding new checklist',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey1.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documentList.length,
                  itemBuilder: (context, index) {
                    DocumentChecklistModel checklistModel = documentList[index];

                    // Format the date if available
                    String formattedDate = '';
                    if (checklistModel.entryDate != null) {
                      try {
                        final date = DateTime.parse(checklistModel.entryDate!);
                        formattedDate = DateFormat('dd MMM yyyy').format(date);
                      } catch (e) {
                        formattedDate = checklistModel.entryDate ?? '';
                      }
                    }

                    return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddCheckListManagementWidget(
                                    documentChecklistModel: checklistModel,
                                  );
                                },
                              ).then((value) {
                                if (null != value && value) {
                                  checkListListFuture = settingsProvider
                                      .getDocumentCheckList(context);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5499D9)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_outlined,
                                      color: Color(0xFF5499D9),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Checklist #${(checklistModel.documentCheckListMasterId)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Created by: ${checklistModel.usrName ?? 'Unknown'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            showConfirmationDialog(
                                              isLoading: false,
                                              context: context,
                                              title: 'Confirm Deletion',
                                              content:
                                                  'Are you sure you want to delete this checklist?',
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                              onConfirm: () async {
                                                await settingsProvider
                                                    .deleteChecklist(
                                                        context,
                                                        checklistModel
                                                            .documentCheckListMasterId!);
                                                Navigator.of(context).pop();
                                              },
                                              confirmButtonText: 'Delete',
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            )));
                  },
                );
              }),
        ),
      ],
    );
  }
}
