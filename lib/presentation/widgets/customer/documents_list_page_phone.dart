import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/document_list_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/full_screen_image_view.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Documents',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
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
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: customerDetailsProvider.documentList.isEmpty
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
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: getAvatarColor(userData.userName),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              userData.userName.isNotEmpty
                                                  ? userData.userName.substring(0, 1).toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userData.userName,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textBlack,
                                              ),
                                            ),
                                            Text(
                                              'Uploaded (${images.length})',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textGrey3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Images Grid
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0), // Removed extra left padding for better grid layout
                                      child: Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: images.map((image) {
                                          return SizedBox(
                                            width: 90,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => FullScreenImageView(
                                                              imagePath: image.filePath,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.04),
                                                              blurRadius: 4,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(4),
                                                          child: Image.network(
                                                            image.filePath,
                                                            width: 90,
                                                            height: 90,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder: (context, child, progress) {
                                                              if (progress == null) {
                                                                return child;
                                                              }
                                                              return Container(
                                                                width: 90,
                                                                height: 90,
                                                                color: Colors.grey[100],
                                                                child: const Center(
                                                                  child: SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context, error, stack) {
                                                              return GestureDetector(
                                                                onTap: () async {
                                                                  final Uri url = Uri.parse(image.filePath);
                                                                  try {
                                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                                  } catch (e) {
                                                                    print('Could not launch $url: $e');
                                                                  }
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey[200],
                                                                    borderRadius: BorderRadius.circular(4),
                                                                  ),
                                                                  width: 90,
                                                                  height: 90,
                                                                  child: const Icon(
                                                                    Icons.picture_as_pdf,
                                                                    color: Colors.red,
                                                                    size: 40,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 4,
                                                      top: 4,
                                                      child: InkWell(
                                                        onTap: () {
                                                          showConfirmationDialog(
                                                            context: context,
                                                            isLoading: customerDetailsProvider.isDeleteLoading,
                                                            title: 'Confirm Deletion',
                                                            content: 'Are you sure you want to delete this document?',
                                                            onCancel: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            onConfirm: () async {
                                                              await customerDetailsProvider.deleteImage(
                                                                  context,
                                                                  image.imageId.toString(),
                                                                  widget.customerId.toString());
                                                              Navigator.of(context).pop();
                                                            },
                                                            confirmButtonText: 'Delete',
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.white.withOpacity(.9),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withOpacity(0.1),
                                                                  blurRadius: 4,
                                                                  offset: const Offset(0, 2),
                                                                )
                                                              ]),
                                                          child: const Icon(
                                                            Icons.delete_forever_outlined,
                                                            color: Colors.red,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  image.documentTypeName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      color: const Color(0xFF1E293B),
                                                      fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  DateFormat('dd/MM/yy').format(DateTime.parse(image.entryDate)),
                                                  style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 10, color: const Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: Color(0xFFE9EDF1), height: 1),
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount:
                                customerDetailsProvider.documentList.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        );
  }
}
