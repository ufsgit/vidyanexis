import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/agency_payment_provider.dart';
import 'package:vidyanexis/presentation/widgets/agency_payment/add_agency_payment_widget.dart';
import 'package:vidyanexis/presentation/widgets/agency_payment/agency_payment_card.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class AgencyPaymentPage extends StatefulWidget {
  const AgencyPaymentPage({super.key});

  @override
  State<AgencyPaymentPage> createState() => _AgencyPaymentPageState();
}

class _AgencyPaymentPageState extends State<AgencyPaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<AgencyPaymentProvider>(context, listen: false);
      provider.getAgencyPayments(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final agencyPaymentProvider =
        Provider.of<AgencyPaymentProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final payments = agencyPaymentProvider.filteredAgencyPaymentList;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context, isMobile, agencyPaymentProvider),
          Expanded(
            child: agencyPaymentProvider.isListLoading
                ? const Center(child: CircularProgressIndicator())
                : payments.isEmpty
                    ? const CommonEmptyState(
                        message: 'No agency payments found')
                    : isMobile
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              return AgencyPaymentCard(
                                payment: payments[index],
                                onDelete: () =>
                                    _confirmDelete(context, payments[index]),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: payments.map((payment) {
                                  return SizedBox(
                                    width: 350,
                                    child: AgencyPaymentCard(
                                      payment: payment,
                                      onDelete: () =>
                                          _confirmDelete(context, payment),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isMobile, AgencyPaymentProvider agencyPaymentProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (!isMobile) const Spacer(),
          if (isMobile)
            Expanded(child: _buildSearchField(agencyPaymentProvider))
          else
            _buildSearchField(agencyPaymentProvider),
          const SizedBox(width: 16),
          _buildAddButton(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchField(AgencyPaymentProvider agencyPaymentProvider) {
    return Container(
      width: 280,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: agencyPaymentProvider.searchController,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search here....',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 13,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          suffixIcon: const Icon(
            Icons.search,
            color: Color(0xFF64748B),
            size: 18,
          ),
        ),
      ),
    );
  }

  void _openAddDialog() async {
    bool? result;
    if (!AppStyles.isWebScreen(context)) {
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AddAgencyPaymentWidget(),
        ),
      );
    } else {
      result = await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) => const AddAgencyPaymentWidget(),
      );
    }

    if (result == true && mounted) {
      Provider.of<AgencyPaymentProvider>(context, listen: false)
          .getAgencyPayments(context);
    }
  }

  Widget _buildAddButton(bool isMobile) {
    return CustomOutlinedSvgButton(
      onPressed: _openAddDialog,
      svgPath: 'assets/images/Plus.svg',
      label: isMobile ? 'New' : 'New Agency',
      breakpoint: 600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      foregroundColor: Colors.white,
      backgroundColor: AppColors.secondaryBlue,
      borderSide: const BorderSide(color: AppColors.secondaryBlue),
    );
  }

  void _confirmDelete(BuildContext context, dynamic payment) {
    showConfirmationDialog(
      context: context,
      title: 'Delete Agency Payment',
      content: 'Are you sure you want to delete this agency payment?',
      confirmButtonText: 'Delete',
      confirmButtonColor: Colors.red,
      onCancel: () {
        Navigator.of(context).pop();
      },
      onConfirm: () async {
        final provider =
            Provider.of<AgencyPaymentProvider>(context, listen: false);
        await provider.deleteAgencyPayment(context, payment.agencyPaymentId);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
