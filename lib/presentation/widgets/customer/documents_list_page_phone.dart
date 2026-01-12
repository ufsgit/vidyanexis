import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/document_list_model.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/customer/activity_tab_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/full_screen_image_view.dart';
import 'package:vidyanexis/presentation/widgets/customer/label_value_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
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

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(
      context,
    );

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
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var userData =
                                  customerDetailsProvider.documentList[index];
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
                                      userData.userName.isNotEmpty
                                          ? userData.userName
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '?',
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
                                    padding: const EdgeInsets.only(
                                        left: 44, right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 160,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(width: 8),
                                            itemCount: images.length,
                                            itemBuilder: (context, imgIndex) {
                                              final image = images[imgIndex];

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
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
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      progress) {
                                                                if (progress ==
                                                                    null) {
                                                                  return child;
                                                                }
                                                                return Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  color: Colors
                                                                          .grey[
                                                                      100],
                                                                  child:
                                                                      const Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child: CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stack) {
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
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    width: 80,
                                                                    height: 80,
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .picture_as_pdf,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 40,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            )),
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        top: 0,
                                                        child: InkWell(
                                                          onTap: () {
                                                            showConfirmationDialog(
                                                              context: context,
                                                              isLoading:
                                                                  customerDetailsProvider
                                                                      .isDeleteLoading,
                                                              title:
                                                                  'Confirm Deletion',
                                                              content:
                                                                  'Are you sure you want to delete this document?',
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
                                                            width: 24,
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        .8)),
                                                            child: const Icon(
                                                              Icons
                                                                  .delete_forever_outlined,
                                                              color: Colors.red,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 80,
                                                    child: Text(
                                                      image.documentTypeName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('dd/MM/yy')
                                                        .format(DateTime.parse(
                                                            image.entryDate)),
                                                    style: const TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            childCount:
                                customerDetailsProvider.documentList.length,
                          ),
                        ),
                      ),
                    ],
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
          },
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
