import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_supplier_page.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchSupplierApi('', context);
      settingsProvider.searchSupplierController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
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
                    Text(
                      'Supplier',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlue800),
                    ),
                    const Spacer(),
                    const SizedBox(width: 16),
                    if (settingsProvider.menuIsSaveMap[45] == 1)
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const AddSupplier(
                                editId: '0',
                                isEdit: false,
                              );
                            },
                          );
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'New Supplier',
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
                      itemCount: settingsProvider.searchSupplier.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceGrey,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Text(
                                        settingsProvider
                                            .searchSupplier[index].supplierName,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (settingsProvider.menuIsEditMap[45] == 1)
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AddSupplier(
                                              editId: settingsProvider
                                                  .searchSupplier[index]
                                                  .supplierId
                                                  .toString(),
                                              isEdit: true,
                                              data: settingsProvider
                                                  .searchSupplier[index],
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
                                if (settingsProvider.menuIsDeleteMap[45] == 1)
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
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
                                                        .deleteSupplier(
                                                            context,
                                                            settingsProvider
                                                                .searchSupplier[
                                                                    index]
                                                                .supplierId);
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
        );
      },
    );
  }
}
