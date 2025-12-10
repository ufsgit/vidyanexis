import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/lead_details_provider.dart';
import 'package:techtify/controller/models/document_list_model.dart';
import 'package:techtify/controller/models/search_leads_model.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/presentation/widgets/customer/activity_tab_page_mobile.dart';
import 'package:techtify/presentation/widgets/customer/add_document_phone.dart';
import 'package:techtify/presentation/widgets/customer/full_screen_image_view.dart';
import 'package:techtify/presentation/widgets/customer/label_value_widget.dart';
import 'package:techtify/presentation/widgets/customer/tile_widget.dart';
import 'package:techtify/presentation/widgets/customer/upload_image.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';
import 'package:techtify/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsListPagePhone extends StatefulWidget {
  final String customerId;

  const DocumentsListPagePhone({
    super.key,
    required this.customerId,
  });

  @override
  State<DocumentsListPagePhone> createState() => _DocumentsListPagePhoneState();
}

class _DocumentsListPagePhoneState extends State<DocumentsListPagePhone> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getDocument(
          widget.customerId.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(
      context,
    );
    final scrollController = ScrollController();

    Color getAvatarColor(String name) {
      final colors = [
        Colors.blue.withOpacity(.75),
        Colors.purple.withOpacity(.75),
        Colors.orange.withOpacity(.75),
        Colors.teal.withOpacity(.75),
        Colors.pink.withOpacity(.75),
        Colors.indigo.withOpacity(.75),
        Colors.green.withOpacity(.75),
        Colors.deepOrange.withOpacity(.75),
        Colors.cyan.withOpacity(.75),
        Colors.brown.withOpacity(.75),
      ];
      final nameHash = name.hashCode.abs();
      return colors[nameHash % colors.length];
    }

    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: customerDetailsProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : customerDetailsProvider.documentList.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Text(
                          'No documents found.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Start by uploading a new document',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListView.builder(
                            itemCount:
                                customerDetailsProvider.documentList.length,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              var userData =
                                  customerDetailsProvider.documentList[index];
                              userData.userName;
                              List<ImageDetail> images = userData.imageDetails;
                              return TileWidget(
                                initiallyExpanded: true,
                                contentPadding: const EdgeInsets.all(0),
                                title: userData.userName,
                                fontWeight: FontWeight.w500,
                                subtitle: 'Uploaded (${images.length})',
                                leading: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: getAvatarColor(userData.userName),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userData.userName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 60),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 140,
                                          child: Scrollbar(
                                            controller: scrollController,
                                            thumbVisibility: true,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController,
                                              physics:
                                                  const RangeMaintainingScrollPhysics(),
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const SizedBox(width: 8),
                                              itemCount: images.length,
                                              itemBuilder: (context, index) {
                                                final image = images[index];

                                                return Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        FullScreenImageView(
                                                                  imagePath: image
                                                                      .filePath,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              child:
                                                                  Image.network(
                                                                image.filePath,
                                                                width: 80,
                                                                height: 80,
                                                                fit:
                                                                    BoxFit.fill,
                                                                loadingBuilder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  } else {
                                                                    return SizedBox(
                                                                      height:
                                                                          70,
                                                                      width: 70,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          value: loadingProgress.expectedTotalBytes != null
                                                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                errorBuilder: (BuildContext
                                                                        context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                                  return GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      final Uri
                                                                          url =
                                                                          Uri.parse(
                                                                              image.filePath);
                                                                      try {
                                                                        await launchUrl(
                                                                            url,
                                                                            mode:
                                                                                LaunchMode.externalApplication);
                                                                      } catch (e) {
                                                                        print(
                                                                            'Could not launch $url: $e');
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      width: 70,
                                                                      height:
                                                                          70,
                                                                      child:
                                                                          const Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.picture_as_pdf,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                50,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              )),
                                                        ),
                                                        Positioned(
                                                          right: 4,
                                                          top: 4,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showConfirmationDialog(
                                                                context:
                                                                    context,
                                                                isLoading:
                                                                    customerDetailsProvider
                                                                        .isDeleteLoading,
                                                                title:
                                                                    'Confirm Deletion',
                                                                content:
                                                                    'Are you sure you want to delete this Lead?',
                                                                onCancel: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                onConfirm:
                                                                    () async {
                                                                  await customerDetailsProvider.deleteImage(
                                                                      context,
                                                                      image
                                                                          .imageId
                                                                          .toString(),
                                                                      widget
                                                                          .customerId
                                                                          .toString());
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                confirmButtonText:
                                                                    'Delete',
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  color: AppColors
                                                                      .whiteColor
                                                                      .withOpacity(
                                                                          .6)),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .delete_forever_outlined,
                                                                  color: AppColors
                                                                      .btnRed,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      image.documentTypeName,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .textBlack),
                                                    ),
                                                    Text(
                                                      DateFormat(
                                                              'dd/MM/yyyy h:mm a')
                                                          .format(DateTime
                                                              .parse(image
                                                                  .entryDate)),
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .textGrey4),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Upload document',
          onPressed: () {
            final customerDetailsProvider =
                Provider.of<CustomerDetailsProvider>(context, listen: false);
            customerDetailsProvider.customerId = widget.customerId.toString();
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddDocumentPhone(
                    customerId: widget.customerId.toString());
              },
            ));
            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   showDragHandle: false,
            //   isDismissible: false,
            //   backgroundColor: Colors.transparent,
            //   builder: (BuildContext context) {
            //     return Padding(
            //       padding: EdgeInsets.only(
            //           bottom: MediaQuery.of(context).viewInsets.bottom),
            //       child: Wrap(
            //         children: [
            //           // ImageUploadAlert(
            //           //     customerId: widget.customerId.toString())
            //           AddDocumentPhone(customerId: widget.customerId.toString())
            //         ],
            //       ),
            //     );
            //   },
            // );
          },
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
