import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/task_document_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:provider/provider.dart';

class TaskDocumentsPage extends StatefulWidget {
  final String customerId;
  const TaskDocumentsPage({
    super.key,
    required this.customerId,
  });

  @override
  State<TaskDocumentsPage> createState() => _TaskDocumentsPageState();
}

class _TaskDocumentsPageState extends State<TaskDocumentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getTaskDocument(widget.customerId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: customerDetailsProvider.taskDocuments.length,
              itemBuilder: (context, index) {
                var userData = customerDetailsProvider.taskDocuments[index];
                List<DocumentList> images = userData.documents;

                return ExpansionTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  initiallyExpanded: true,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 10,
                    children: [
                      const Icon(Icons.person),
                      Text(
                        '  Uploaded By ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textGrey4,
                        ),
                      ),
                      Text(
                        userData.toUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        userData.taskTypeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        userData.taskDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        height: 140,
                        child: Scrollbar(
                          controller:
                              customerDetailsProvider.taskScrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller:
                                customerDetailsProvider.taskScrollController,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            physics: const ClampingScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final image = images[index];
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            _showFullScreenImage(
                                                context, index, images, false);
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              HttpUrls.imgBaseUrl +
                                                  image.filePath,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.fill,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return SizedBox(
                                                  height: 100,
                                                  width: 100,
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
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFEFF2F5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  width: 100,
                                                  height: 100,
                                                  child: const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex,
      List<dynamic> items, bool baseImgUrl) {
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
                    if (pageController.page! < items.length - 1) {
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
                    itemCount: items.length, // Total number of images
                    controller:
                        pageController, // Set the controller for the PageView
                    itemBuilder: (context, index) {
                      String imagePath = items[index].filePath;
                      return Center(
                        child: Image.network(
                          baseImgUrl
                              ? imagePath
                              : HttpUrls.imgBaseUrl + imagePath,
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
                        if (pageController.page! < items.length - 1) {
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
