import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class DocumentCategoryDownloadDialog extends StatefulWidget {
  final String customerId;

  const DocumentCategoryDownloadDialog({
    super.key,
    required this.customerId,
  });

  @override
  State<DocumentCategoryDownloadDialog> createState() =>
      _DocumentCategoryDownloadDialogState();
}

class _DocumentCategoryDownloadDialogState
    extends State<DocumentCategoryDownloadDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getItemDocumentCategories(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = AppStyles.isWebScreen(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 120 : 24,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 420 : double.infinity, // reduced width on web
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Consumer<CustomerDetailsProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Document Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Flexible(
                  child: provider.isDocumentCategoriesLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.documentCategoriesError != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 32, horizontal: 20),
                              child: Text(
                                provider.documentCategoriesError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : provider.documentCategories.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      'No categories found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: provider.documentCategories.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final category =
                                        provider.documentCategories[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              category.documentCategoryName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            height: 36,
                                            child: CustomElevatedButton(
                                              radius: 6,
                                              backgroundColor:
                                                  AppColors.whiteColor,
                                              borderColor: AppColors.darkGreen,
                                              textColor: AppColors.darkGreen,
                                              buttonText: 'Download',
                                              textSize: 13,
                                              horizontalPadding: 14,
                                              verticalPadding: 0,
                                              onPressed: () async {
                                                await provider.downloadCategoryDocuments(
                                                  customerId: widget.customerId,
                                                  categoryId: category.documentCategoryId,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                ),

                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
