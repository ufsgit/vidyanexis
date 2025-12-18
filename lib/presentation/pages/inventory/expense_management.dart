import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_expense_management.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_document_type.dart';

class ExpenseManagement extends StatefulWidget {
  const ExpenseManagement({super.key});

  @override
  State<ExpenseManagement> createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // final expenseProvider =
      //     Provider.of<ExpenseProvider>(context, listen: false);

      // settingsProvider.searchDocumentType('', context);
      // settingsProvider.searchDocumentTypeController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Management',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textBlack,
            // fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        const Spacer(),
                        Container(
                          width: MediaQuery.of(context).size.width / 3.5,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller:
                                settingsProvider.searchDocumentTypeController,
                            onChanged: (query) {
                              if (kDebugMode) {
                                print(query);
                              }
                              settingsProvider.searchDocumentType(
                                  query, context);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search here....',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // if (settingsProvider.menuIsSaveMap[23] == 1)
                        CustomOutlinedSvgButton(
                          onPressed: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return const AddExpenseManagement(
                                  editId: '0',
                                  isEdit: false,
                                );
                              },
                            );
                          },
                          svgPath: 'assets/images/Plus.svg',
                          label: 'Add Expense Management',
                          breakpoint: 860,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryBlue,
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 12,
                            );
                          },
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: settingsProvider.documentType.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 22,
                                      decoration: BoxDecoration(
                                          color: AppColors.surfaceGrey,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Text(
                                            settingsProvider.documentType[index]
                                                .documentTypeName,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // if (settingsProvider.menuIsEditMap[23] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AddDocumentType(
                                                editId: settingsProvider
                                                    .documentType[index]
                                                    .documentTypeId
                                                    .toString(),
                                                status: settingsProvider
                                                    .documentType[index]
                                                    .documentTypeName,
                                                isEdit: true,
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Edit',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryBlue),
                                        )),
                                    // if (settingsProvider.menuIsDeleteMap[23] ==
                                    //     1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      settingsProvider
                                                          .deleteDocumentType(
                                                              context,
                                                              settingsProvider
                                                                  .documentType[
                                                                      index]
                                                                  .documentTypeId);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Delete',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textRed),
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
