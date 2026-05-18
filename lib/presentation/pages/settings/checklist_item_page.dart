import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/models/checklist_item_model.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_checklist_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class CheckListItemPage extends StatefulWidget {
  final String searchQuery;
  const CheckListItemPage({super.key, this.searchQuery = ''});

  @override
  State<CheckListItemPage> createState() => _CheckListItemPageState();
}

class _CheckListItemPageState extends State<CheckListItemPage> {
  final searchController = TextEditingController();
  Future<List<CheckListItemModel>>? checkListItemFuture;
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      searchController.text = widget.searchQuery;
      getData();
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CheckListItemPage oldWidget) {
    if (widget.searchQuery != oldWidget.searchQuery) {
      searchController.text = widget.searchQuery;
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    searchController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddCheckListItemPage(
            checkListItemModel: CheckListItemModel());
      },
    ).then((value) {
      if (null != value && value) {
        getData();
      }
    });
  }

  void getData() {
    checkListItemFuture =
        settingsProvider.getCheckListItem(searchController.text, context);
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb) ...[
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        'CheckList Items',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue800),
                      ),
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
                          controller: searchController,
                          onChanged: (query) {
                            print(query);
                            setState(() {
                              getData();
                            });
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
                      if (settingsProvider.menuIsSaveMap[6] == 1)
                        CustomOutlinedSvgButton(
                          onPressed: _openAddDialog,
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New Checklist Item',
                          breakpoint: 860,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.secondaryBlue,
                          borderSide: BorderSide(color: AppColors.secondaryBlue),
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    FutureBuilder<List<CheckListItemModel>>(
                        future: checkListItemFuture,
                        builder: (contextBuilder, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Loading state
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          List<CheckListItemModel> modelList =
                              snapshot.data ?? [];
                          return ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 12,
                              );
                            },
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: modelList.length,
                            itemBuilder: (context, index) {
                              CheckListItemModel itemModel = modelList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: AppColors.surfaceGrey,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(
                                            itemModel.checkListItemName ?? "",
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (settingsProvider.menuIsEditMap[38] == 1)
                                      TextButton(
                                          onPressed: () {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AddCheckListItemPage(
                                                    checkListItemModel:
                                                        itemModel);
                                              },
                                            ).then((value) {
                                              if (null != value && value) {
                                                getData();
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Edit',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryBlue),
                                          )),
                                    if (settingsProvider.menuIsDeleteMap[38] == 1)
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
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        settingsProvider
                                                            .deleteCheckListItem(
                                                                context,
                                                                itemModel
                                                                    .checkListItemId
                                                                    .toString())
                                                            .then((value) {
                                                          if (null != value &&
                                                              value) {
                                                            getData();
                                                          }
                                                        });
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
                              );
                            },
                          );
                        })
                  ],
                ),
              ),
            ],
          ),
        );

        if (isWeb) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: content,
          );
        } else {
          return content;
        }
      },
    );
  }
}
