import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/task_details_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/presentation/widgets/customer/pdf_printer_widget.dart';

class UserInfoCard extends StatefulWidget {
  final String name;
  final String category;
  final List<Document> items; // List to hold items (e.g., images)
  final String notes;
  final String? avatarUrl;
  final int taskId; // Optional avatar image URL

  const UserInfoCard({
    super.key,
    required this.name,
    required this.category,
    required this.items,
    required this.notes,
    this.avatarUrl,
    required this.taskId,
  });

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: widget.avatarUrl != null
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: widget.avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 12,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.only(left: 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                widget.category,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              widget.items[0].filePath.isNotEmpty
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        height: 100,
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            physics: const RangeMaintainingScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemCount: widget.items.length,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        int currentIndex =
                                            index; // Assuming you are passing the index of the clicked image.
                                        _showFullScreenImage(
                                          context,
                                          currentIndex, // Pass the selected image index
                                        );
                                      },
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              8), // Adjust the radius as needed
                                          child: Image.network(
                                            HttpUrls.imgBaseUrl +
                                                widget.items[index].filePath,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.fill,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child; // The image is loaded, return the image widget.
                                              } else {
                                                return SizedBox(
                                                  height: 70,
                                                  width: 70,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              // Return a placeholder or error image in case of an error
                                              return Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.grey
                                                          .withOpacity(0.2)),
                                                  child: const Icon(Icons
                                                      .hide_image_outlined));
                                            },
                                          )),
                                    ),
                                    SizedBox(
                                        width: 70,
                                        child: Text(
                                          widget.items[index].entryDate ?? '',
                                          style: const TextStyle(fontSize: 10),
                                        ))
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Documents',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                'Notes :',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.notes,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textGrey3,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date Time :',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.items[0].startDateTime,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textGrey3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion Date Time :',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.items[0].completionDateTime,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textGrey3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (settingsprovider.menuIsViewMap[31] == 1)
                ElevatedButton(
                  onPressed: () async {
                    String taskId = widget.taskId.toString();
                    await customerDetailsProvider.getForm(context, taskId);
                    if (customerDetailsProvider.formDetails.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No Job Sheet Details')),
                      );
                    } else {
                      await PDFPrinter.buildPdf(
                          customerDetailsProvider.leadDetails,
                          customerDetailsProvider.formDetails);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    textStyle: AppStyles.getHeadingTextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('View Job Sheet'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        // Create a PageController to control the PageView
        PageController pageController =
            PageController(initialPage: initialIndex);

        return Dialog(
          backgroundColor: Colors.black,
          child: FocusScope(
            autofocus: true, // Enable focus for keyboard events
            child: KeyboardListener(
              autofocus: true, // Automatically focus on the listener
              focusNode: FocusNode(), // Focus node to capture keyboard events
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    // Navigate to the previous image
                    if (pageController.page! > 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    // Navigate to the next image
                    if (pageController.page! < widget.items.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                    // Close the dialog on 'Escape' key
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Stack(
                children: [
                  // PageView.builder to swipe through images
                  PageView.builder(
                    itemCount: widget.items.length, // Total number of images
                    controller:
                        pageController, // Set the controller for the PageView
                    itemBuilder: (context, index) {
                      String imagePath = widget.items[index].filePath;
                      return Center(
                        child: Image.network(
                          HttpUrls.imgBaseUrl + imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            // Return a placeholder or error image in case of an error
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.withOpacity(0.2)),
                              child: const Icon(
                                Icons.hide_image_outlined,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // Positioned 'Previous' button on the left
                  Positioned(
                    top: 0,
                    left: 20,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Go to previous image
                        if (pageController.page! > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                  // Positioned 'Next' button on the right
                  Positioned(
                    top: 0,
                    right: 20,
                    bottom: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        // Go to next image
                        if (pageController.page! < widget.items.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
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
}
