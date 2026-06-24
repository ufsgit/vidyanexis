import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

import '../../../controller/models/form_model.dart';
import '../../widgets/settings/add_form_settings_widget.dart';

class FormContent extends StatefulWidget {
  const FormContent({super.key});

  @override
  State<FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FormProvider>(context, listen: false).fetchForms(context);
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return const AddFormSettingsWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final formProvider = Provider.of<FormProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final filteredForms = formProvider.filteredForms;
    final isMobile = !AppStyles.isWebScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget contentBody = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form List
            Container(
              decoration: BoxDecoration(
                color: isMobile ? Colors.transparent : AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  if (formProvider.isLoadingForms)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredForms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No forms found.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: filteredForms.length,
                      itemBuilder: (context, index) {
                        FormModel formModel = filteredForms[index];
                        if (isMobile) {
                          return _buildMobileRow(context, formModel,
                              formProvider, settingsProvider);
                        }
                        return _buildDesktopRow(
                            context, formModel, formProvider, settingsProvider);
                      },
                    )
                ],
              ),
            ),
          ],
        );

        if (isMobile) {
          return SizedBox(
            width: constraints.maxWidth,
            child: contentBody,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < minContentWidth
                ? minContentWidth
                : constraints.maxWidth,
            child: contentBody,
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, FormProvider formProvider,
      {required bool isMobile}) {
    return Container(
      width:
          isMobile ? double.infinity : MediaQuery.of(context).size.width / 3.5,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (query) {
          formProvider.setSearchQuery(query);
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
    );
  }

  Widget _buildNewFormButton(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextButton.icon(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Form",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRow(BuildContext context, FormModel formModel,
      FormProvider formProvider, SettingsProvider settingsProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Form Name Chip
          SizedBox(
            width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  formModel.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
          ),

          // Department
          Expanded(
            child: Text(
              formModel.department,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),

          // Task Type
          Expanded(
            child: Text(
              formModel.taskType,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),

          // Action Buttons
          if (settingsProvider.menuIsEditMap[85].toString() == '1')
            TextButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AddFormSettingsWidget(
                        existingForm: formModel,
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
          if (settingsProvider.menuIsDeleteMap[85].toString() == '1')
            TextButton(
                onPressed: () {
                  _showDeleteDialog(context, formModel, formProvider);
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
  }

  Widget _buildMobileRow(BuildContext context, FormModel formModel,
      FormProvider formProvider, SettingsProvider settingsProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      formModel.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (settingsProvider.menuIsEditMap[85].toString() == '1')
                IconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AddFormSettingsWidget(
                          existingForm: formModel,
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.primaryBlue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (settingsProvider.menuIsDeleteMap[85].toString() == '1')
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: IconButton(
                    onPressed: () {
                      _showDeleteDialog(context, formModel, formProvider);
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: AppColors.textRed),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.business_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formModel.department,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800),
                ),
              ),
              Icon(Icons.assignment_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formModel.taskType,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, FormModel formModel, FormProvider formProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                formProvider.deleteForm(formModel.id);
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
  }
}
