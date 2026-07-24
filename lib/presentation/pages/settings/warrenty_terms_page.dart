import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class TermsWarrantyContent extends StatefulWidget {
  const TermsWarrantyContent({super.key});

  @override
  State<TermsWarrantyContent> createState() => _TermsWarrantyContentState();
}

class _TermsWarrantyContentState extends State<TermsWarrantyContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsProvider.clearTermsFields();
      settingsProvider.getTermsAndWarranty(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    const double minContentWidth = 800.0;
    final isWeb = AppStyles.isWebScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: isWeb
                ? (constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth)
                : constraints.maxWidth,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Terms & Warranty',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const Spacer(),
                      CustomElevatedButton(
                        onPressed: () {
                          provider.saveTermsAndWarranty(context);
                        },
                        buttonText: 'Save',
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Warranty'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.warrantyController,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter detailed warranty information...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Terms & Conditions Section
                  _buildSectionHeader('Terms and Conditions'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.termsController,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter terms and conditions...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('Description 1'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.description1Controller,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('Description 2'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.description2Controller,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('Description 3'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.description3Controller,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('Advance Percentage'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.advancePercentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter advance percentage...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('On Material Delivery Percentage'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.onMaterialDeliveryPercentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter material delivery percentage...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader('On Work Completion Percentage'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.onWorkCompletionPercentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter work completion percentage...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.secondaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}
