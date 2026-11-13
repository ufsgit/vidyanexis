import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class AgencyPaymentPage extends StatefulWidget {
  const AgencyPaymentPage({super.key});

  @override
  State<AgencyPaymentPage> createState() => _AgencyPaymentPageState();
}

class _AgencyPaymentPageState extends State<AgencyPaymentPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context, isMobile),
          const Expanded(
            child: CommonEmptyState(message: 'No agency payments found'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (!isMobile) const Spacer(),
          if (isMobile)
            Expanded(child: _buildSearchField())
          else
            _buildSearchField(),
          const SizedBox(width: 16),
          _buildAddButton(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
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
        controller: _searchController,
        textAlignVertical: TextAlignVertical.center,
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

  Widget _buildAddButton(bool isMobile) {
    return CustomOutlinedSvgButton(
      onPressed: () {},
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
}
