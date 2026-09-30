import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_creation_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/full_screen_image_view.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class AmcTabWidget extends StatefulWidget {
  final String customerId;

  const AmcTabWidget({
    super.key,
    required this.customerId,
  });

  @override
  State<AmcTabWidget> createState() => _AmcTabWidgetState();
}

class _AmcTabWidgetState extends State<AmcTabWidget> {
  static const Color borderColor = Color(0xFFE9EDF1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      provider.getAmc(widget.customerId, '0', context);
    });
  }

  String _formatDate(String? date, {String pattern = 'dd MMM yyyy'}) {
    if (date == null || date.isEmpty) return '-';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return DateFormat(pattern).format(parsed);
  }

  String _completedLabel(int status) => status == 1 ? 'Completed' : 'Pending';

  Color _statusColor(int status) => status == 1 ? Colors.green : Colors.orange;

  void _openAmcDetails(AmcReportModeld amc) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    try {
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadProvider.setCutomerId(int.parse(widget.customerId));
    } catch (_) {}

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AmcWidget(
          customerName: amc.customerName,
          customerStatus: amc.displayStatus,
          entryDate: amc.date?.toIso8601String() ?? '',
          productName: amc.productName,
          service: amc.serviceName,
          amount: '₹${amc.amount}',
          description: amc.description,
          onPressed: () {
            customerDetailsProvider.customerId = widget.customerId;
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AmcCreationWidget(
                  amcId: amc.amcId.toString(),
                  amcAmountController: amc.amount,
                  amcDescriptionController: amc.description,
                  amcProductNameController: amc.productName,
                  amcServiceController: amc.serviceName,
                  fromDateController:
                      _formatDate(amc.fromDate, pattern: 'dd-MM-yyyy'),
                  toDateController:
                      _formatDate(amc.toDate, pattern: 'dd-MM-yyyy'),
                  customerId: widget.customerId,
                  amc: amc,
                  isEdit: true,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCell(String text,
      {int flex = 1, bool isAction = false, double? width}) {
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: isAction
          ? const Center(child: Icon(Icons.add, color: Colors.grey, size: 20))
          : Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7D8B9B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildDataCell(String text,
      {int flex = 1, bool isBold = false, double? width}) {
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _buildIntervalThumb(String? imagePath) {
    const size = 56.0;

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 24),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImageView(imagePath: imagePath),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(imagePath);
                if (uri != null) {
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                }
              },
              child: Container(
                color: Colors.grey[200],
                child: const Icon(Icons.picture_as_pdf,
                    color: Colors.red, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    if (provider.isAmcListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Normal list — no filter
    final amcList = provider.amcList;

    if (amcList.isEmpty) {
      return Center(
        child: Text(
          'No Periodic Service found.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey3,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor),
          left: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        children: [
          // Header
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCell('#', width: 50.0),
                _buildHeaderCell('Service Name', flex: 2),
                _buildHeaderCell('Product Name', flex: 2),
                _buildHeaderCell('Category', flex: 2),
                _buildHeaderCell('Amount', flex: 2),
                _buildHeaderCell('Work Completion Date', flex: 2),
                _buildHeaderCell('To Date', flex: 2),
                _buildHeaderCell('Options', flex: 2),
              ],
            ),
          ),

          // Scrollable list
          Expanded(
            child: ListView.builder(
              itemCount: amcList.length,
              itemBuilder: (context, index) {
                final amc = amcList[index];
                final intervals = amc.maintenanceDate;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main AMC row
                    GestureDetector(
                      onTap: () => _openAmcDetails(amc),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDataCell((index + 1).toString(), width: 50.0),
                            _buildDataCell(amc.serviceName,
                                flex: 2, isBold: true),
                            _buildDataCell(amc.productName, flex: 2),
                            _buildDataCell(
                              amc.categoryName,
                              flex: 2,
                            ),
                            _buildDataCell(
                              '₹${double.tryParse(amc.amount) ?? amc.amount}',
                              flex: 2,
                            ),
                            _buildDataCell(_formatDate(amc.fromDate), flex: 2),
                            _buildDataCell(_formatDate(amc.toDate), flex: 2),
                            _buildWidgetCell(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (settingsprovider.menuIsEditMap[15] == 1)
                                    IconButton(
                                      tooltip: 'Edit',
                                      icon: const Icon(Icons.edit,
                                          size: 20, color: Colors.blue),
                                      onPressed: () {
                                        provider.customerId = widget.customerId;
                                        provider.setAmcDropDown(
                                            amc.amcStatusId, amc.amcStatusName);
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AmcCreationWidget(
                                              amcId: amc.amcId.toString(),
                                              amcAmountController: amc.amount,
                                              amcDescriptionController:
                                                  amc.description,
                                              amcProductNameController:
                                                  amc.productName,
                                              amcServiceController:
                                                  amc.serviceName,
                                              fromDateController: _formatDate(
                                                  amc.fromDate,
                                                  pattern: 'dd-MM-yyyy'),
                                              toDateController: _formatDate(
                                                  amc.toDate,
                                                  pattern: 'dd-MM-yyyy'),
                                              customerId: widget.customerId,
                                              amc: amc,
                                              isEdit: true,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  if (settingsprovider.menuIsDeleteMap[15] == 1)
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete,
                                          size: 20, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(
                                              title: 'Delete Periodic Service',
                                              content:
                                                  'Are you sure you want to delete this service?',
                                              onCancel: () =>
                                                  Navigator.of(context).pop(),
                                              onConfirm: () {
                                                Navigator.of(context).pop();
                                                provider.deleteAMC(
                                                  amc.amcId.toString(),
                                                  widget.customerId,
                                                  context,
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Interval details — default expanded, as table rows
                    ExpansionTile(
                      key: PageStorageKey('amc_intervals_${amc.amcId}'),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      childrenPadding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      title: Text(
                        'Interval Details (${intervals.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey3,
                        ),
                      ),
                      children: [
                        if (intervals.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Text(
                              'No interval details',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textGrey3,
                              ),
                            ),
                          )
                        else ...[
                          // Interval header row
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeaderCell('Date', flex: 2),
                                _buildHeaderCell('Status', flex: 2),
                                _buildHeaderCell('Image', flex: 2),
                              ],
                            ),
                          ),
                          // Interval data rows
                          ...intervals.map((interval) {
                            final dateStr = interval.date;
                            final status = interval.completed;
                            final imagePath = interval.imagePath;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDataCell(_formatDate(dateStr), flex: 2),
                                  _buildWidgetCell(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _completedLabel(status),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(status),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildWidgetCell(
                                    flex: 2,
                                    child: imagePath != ''
                                        ? _buildIntervalThumb(imagePath)
                                        : SizedBox(
                                            width: 56.0,
                                            height: 56.0,
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),

                    // Spacing between each expanded AMC block
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
