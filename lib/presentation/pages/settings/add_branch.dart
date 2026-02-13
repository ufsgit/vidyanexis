import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/http/http_urls.dart';

class AddBranch extends StatefulWidget {
  final bool isEdit;
  final BranchModel? branch;
  final String editId;
  final TaskTypeModel? taskType;

  const AddBranch({
    super.key,
    required this.isEdit,
    this.branch,
    required this.editId,
    this.taskType,
  });

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.branchController.text.trim().isEmpty) {
      return 'Please enter branch';
    }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadLogo(SettingsProvider settingsProvider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          Loader.showLoader(context);

          String uploadedPath = await CloudflareUpload.uploadToCloudflare(
                  file.bytes!,
                  file.extension ?? 'png',
                  "branch_logos",
                  context) ??
              "";

          Loader.stopLoader(context);

          if (uploadedPath.isNotEmpty) {
            setState(() {
              settingsProvider.logoController.text = uploadedPath;
            });
          }
        }
      }
    } catch (e) {
      print(e);
      Loader.stopLoader(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.branchController.text =
            widget.branch!.branchName ?? "";
        settingsProvider.addressController.text = widget.branch!.address ?? "";
        settingsProvider.pinCodeController.text = widget.branch!.pincode ?? "";
        settingsProvider.contactPersonController.text =
            widget.branch!.contactPerson ?? "";
        settingsProvider.emailBranchController.text =
            widget.branch!.email ?? "";
        settingsProvider.phoneController.text = widget.branch!.phone ?? "";
        settingsProvider.gstNoController.text = widget.branch!.gstNo ?? "";
        settingsProvider.panCardNoController.text =
            widget.branch!.panCardNo ?? "";
        settingsProvider.bankNameController.text =
            widget.branch!.bankName ?? "";
        settingsProvider.bankHolderNameController.text =
            widget.branch!.bankHolderName ?? "";
        settingsProvider.bankAccountNoController.text =
            widget.branch!.bankAccountNo ?? "";
        settingsProvider.ifscCodeController.text =
            widget.branch!.ifscCode ?? "";
        settingsProvider.logoController.text = widget.branch!.logo ?? "";
      });
    } else {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.clearBranchFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Branch' : 'Add Branch',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.branchController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 2.2,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomElevatedButton(
              buttonText: 'Upload Logo',
              onPressed: () async {
                await _pickAndUploadLogo(settingsProvider);
              },
              backgroundColor: AppColors.whiteColor,
              borderColor: AppColors.appViolet,
              textColor: AppColors.appViolet,
            ),
            const SizedBox(height: 10),
            if (settingsProvider.logoController.text.isNotEmpty)
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(
                              '${HttpUrls.imgBaseUrl}${settingsProvider.logoController.text}',
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${HttpUrls.imgBaseUrl}${settingsProvider.logoController.text}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          settingsProvider.logoController.clear();
                        });
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.delete,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Task Type Text Field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.branchController,
              hintText: 'Branch name*',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.addressController,
              hintText: 'Address',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.phoneController,
              hintText: 'Phone',
              labelText: '',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.pinCodeController,
              hintText: 'Pin code',
              labelText: '',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.emailBranchController,
              hintText: 'Email',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.contactPersonController,
              hintText: 'Contact Person',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.gstNoController,
              hintText: 'GST No',
              labelText: '',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.panCardNoController,
              hintText: 'PAN Card No',
              labelText: '',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.bankNameController,
              hintText: 'Bank Name',
              labelText: '',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.bankHolderNameController,
              hintText: 'Bank Holder Name',
              labelText: '',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.bankAccountNoController,
              hintText: 'Bank Account No',
              labelText: '',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.ifscCodeController,
              hintText: 'IFSC Code',
              labelText: '',
            ),

            const SizedBox(height: 20),
          ],
        )),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.branchController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }
            settingsProvider.saveBranch(
                context: context, branchId: widget.editId);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
