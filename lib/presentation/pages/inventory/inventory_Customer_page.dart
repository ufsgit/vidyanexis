import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_customer_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchInventoryCustomerApi('', context);
      settingsProvider.searchInventoryCustomerController.clear();
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
                      'Customer',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlue800),
                    ),
                    const Spacer(),
                    const SizedBox(width: 16),
                    CustomOutlinedSvgButton(
                      onPressed: () async {
                        await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return const AddCustomer(
                              editId: '0',
                              isEdit: false,
                            );
                          },
                        );
                        // Refresh the list after dialog closes
                        if (mounted) {
                          final settingsProvider =
                              Provider.of<SettingsProvider>(context, listen: false);
                          settingsProvider.searchInventoryCustomerApi('', context);
                        }
                      },
                      svgPath: 'assets/images/Plus.svg',
                      label: 'New Customer',
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
                      itemCount: settingsProvider.searchInventoryCustomer.length,
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
                                            .searchInventoryCustomer[index].customerName,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                    onPressed: () async {
                                      await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddCustomer(
                                            editId: settingsProvider
                                                .searchInventoryCustomer[index]
                                                .customerId
                                                .toString(),
                                            isEdit: true,
                                            data: settingsProvider
                                                .searchInventoryCustomer[index],
                                          );
                                        },
                                      );
                                      // Refresh the list after dialog closes
                                      if (mounted) {
                                        final settingsProvider =
                                            Provider.of<SettingsProvider>(context, listen: false);
                                        settingsProvider.searchInventoryCustomerApi('', context);
                                      }
                                    },
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryBlue),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete'),
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
                                                      .deleteInventoryCustomer(
                                                          context,
                                                          settingsProvider
                                                              .searchInventoryCustomer[
                                                                  index]
                                                              .customerId);
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


