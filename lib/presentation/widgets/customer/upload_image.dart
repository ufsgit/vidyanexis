import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class ImageUploadAlert extends StatefulWidget {
  final String customerId;
  const ImageUploadAlert({super.key, required this.customerId});
  @override
  _ImageUploadAlertState createState() => _ImageUploadAlertState();
}

class _ImageUploadAlertState extends State<ImageUploadAlert> {
  @override
  void initState() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    dropDownProvider.getDocumentType(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageUploadProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    return AlertDialog(
      scrollable: true,
      title: const Text("Add Documents"),
      content: SizedBox(
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 4
            : MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: provider.selectedDocumentType,
              items: dropDownProvider.documentType
                  .map((status) => DropdownMenuItem<int>(
                        value: status.documentTypeId,
                        child: Text(
                          status.documentTypeName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ))
                  .toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  final selectedTaskType = dropDownProvider.documentType
                      .firstWhere((task) => task.documentTypeId == newValue);
                  provider.updateDocumentType(
                      newValue, selectedTaskType.documentTypeName);
                }
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, // Custom font size
                fontWeight: FontWeight.w600, // Custom font weight
                color: AppColors.textBlack, // Custom color for selected item
              ),
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: 'Choose Document Type',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: ' *', // The asterisk part
                        style: TextStyle(
                            color: Colors.red), // Red color for asterisk
                      ),
                    ],
                  ),
                ),
                floatingLabelBehavior:
                    FloatingLabelBehavior.auto, // Always show the label
                floatingLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16, // Slightly smaller size for floating label
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1, // Color for floating label
                ),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
              isDense: true,
              iconSize: 18,
            ),
            // Button to trigger file upload
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () => provider.addMultipleFile(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withOpacity(0.05),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 50, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      'Upload Documents',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Display the total number of uploaded images and PDFs
            Text(
              'You have uploaded ${provider.images.length + provider.pdfs.length} documents',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display images if uploaded
            provider.images.isEmpty && provider.pdfs.isEmpty
                ? const Text(
                    'No documents uploaded yet.') // Common message for both
                : Column(
                    children: [
                      // Display images if uploaded
                      provider.images.isNotEmpty
                          ? MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: SizedBox(
                                height: 100,
                                child: Scrollbar(
                                  controller: provider.scrollController,
                                  thumbVisibility: true,
                                  child: ListView.separated(
                                    controller: provider.scrollController,
                                    scrollDirection: Axis.horizontal,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 8),
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: provider.images.length,
                                    itemBuilder: (context, index) {
                                      final image = provider.images[index];
                                      return Stack(
                                        children: [
                                          Center(
                                            child: InkWell(
                                              onTap: () {
                                                // Implement full-screen image view here
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.memory(
                                                  image,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  provider.removeImage(image),
                                              child: const CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Container(),

                      // Display PDFs if uploaded
                      provider.pdfs.isNotEmpty
                          ? MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: SizedBox(
                                height: 100,
                                child: Scrollbar(
                                  controller: provider.scrollController,
                                  thumbVisibility: true,
                                  child: ListView.separated(
                                    controller: provider.scrollController,
                                    scrollDirection: Axis.horizontal,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 8),
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: provider.pdfs.length,
                                    itemBuilder: (context, index) {
                                      final pdf = provider.pdfs[index];
                                      return Stack(
                                        children: [
                                          Center(
                                            child: InkWell(
                                              onTap: () {
                                                // Implement PDF view here (if needed)
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                child: const Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  provider.removePdf(pdf),
                                              child: const CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
          ],
        ),
      ),
      actions: [
        // Cancel button to clear the files and close the dialog
        CustomElevatedButton(
          onPressed: () {
            provider.clearFiles();
            Navigator.of(context).pop(); // Close the dialog
          },
          buttonText: 'Cancel',
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        // Upload button to upload selected files
        CustomElevatedButton(
          onPressed: () async {
            provider.setCutomerId(widget.customerId);
            if (provider.selectedDocumentType != null) {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              String userId = preferences.getString('userId') ?? "0";
              if (provider.images.isNotEmpty) {
                await provider.uploadImagesToAws(userId, context);
              } else if (provider.pdfs.isNotEmpty) {
                await provider.uploadPdfsToAws(userId, context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pick Documents')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Choose Document Type')),
              );
            }
          },
          buttonText: 'Upload Documents',
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
