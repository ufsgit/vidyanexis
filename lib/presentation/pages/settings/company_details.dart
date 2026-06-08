import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_company_details.dart';

class CompanyDetails extends StatefulWidget {
  const CompanyDetails({super.key});

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.getCompanyDetails();
      settingsProvider.clearCompanyControllers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: AppStyles.isWebScreen(context)
                ? constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth
                : MediaQuery.of(context).size.width - 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (settingsProvider.menuIsSaveMap[27] == 1)
                  CustomOutlinedSvgButton(
                    onPressed: () async {
                      if (settingsProvider.companyDetails.isEmpty) {
                        settingsProvider.clearCompanyControllers();
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return const AddCompanyDetails(
                              isEdit: false,
                              companyId: '0',
                            );
                          },
                        );
                      } else {
                        settingsProvider.cnameController.text = settingsProvider
                            .companyDetails[0].companyName
                            .toString();
                        settingsProvider.caddress1Controller.text =
                            settingsProvider.companyDetails[0].address1
                                .toString();
                        settingsProvider.caddress2Controller.text =
                            settingsProvider.companyDetails[0].address2
                                .toString();
                        settingsProvider.caddress3Controller.text =
                            settingsProvider.companyDetails[0].address3
                                .toString();
                        settingsProvider.caddress4Controller.text =
                            settingsProvider.companyDetails[0].address4
                                .toString();
                        settingsProvider.cphoneController.text =
                            settingsProvider.companyDetails[0].phoneNumber
                                .toString();
                        settingsProvider.cmobileController.text =
                            settingsProvider.companyDetails[0].mobileNumber
                                .toString();
                        settingsProvider.cemailController.text =
                            settingsProvider.companyDetails[0].email.toString();
                        settingsProvider.cgstNoController.text =
                            settingsProvider.companyDetails[0].gstNo.toString();
                        settingsProvider.cpanNoController.text =
                            settingsProvider.companyDetails[0].panNo.toString();
                        settingsProvider.ccinNoController.text =
                            settingsProvider.companyDetails[0].cinNo.toString();
                        settingsProvider.saveImagePath(
                            settingsProvider.companyDetails[0].logo.toString());
                        settingsProvider.setToggleValue(
                            settingsProvider.companyDetails[0].isLocation);
                        settingsProvider.setEnquiryForMandatory(settingsProvider
                            .companyDetails[0].enquiryForMandatory);
                        settingsProvider.setEnquirySourceMandatory(settingsProvider
                            .companyDetails[0].enquirySourceMandatory);
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddCompanyDetails(
                              isEdit: true,
                              companyId: settingsProvider
                                  .companyDetails[0].companyId
                                  .toString(),
                            );
                          },
                        );
                      }
                    },
                    svgPath: 'assets/images/Plus.svg',
                    label: settingsProvider.companyDetails.isNotEmpty
                        ? 'Modify Company Details'
                        : 'Add Company Details',
                    breakpoint: 860,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryBlue,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                // Company Logo
                if (settingsProvider.companyDetails.isNotEmpty)
                  Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              settingsProvider.displayLogo.startsWith('http')
                                  ? NetworkImage(settingsProvider.displayLogo)
                                  : AssetImage(settingsProvider.displayLogo)
                                      as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Company Name
                      Center(
                        child: Text(
                          settingsProvider.companyDetails[0].companyName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Address
                      _buildInfoTile(Icons.location_on, "Address",
                          '${settingsProvider.companyDetails[0].address1},${settingsProvider.companyDetails[0].address2},${settingsProvider.companyDetails[0].address3},${settingsProvider.companyDetails[0].address4}'),
                      // Phone
                      _buildInfoTile(Icons.phone, "Phone",
                          settingsProvider.companyDetails[0].phoneNumber),
                      // Mobile
                      _buildInfoTile(Icons.smartphone, "Mobile",
                          settingsProvider.companyDetails[0].mobileNumber),
                      // Email
                      _buildInfoTile(Icons.email, "Email",
                          settingsProvider.companyDetails[0].email),
                      // GST No
                      _buildInfoTile(Icons.receipt_long, "GST No",
                          settingsProvider.companyDetails[0].gstNo),
                      // PAN No
                      _buildInfoTile(Icons.credit_card, "PAN No",
                          settingsProvider.companyDetails[0].panNo),
                      // CIN No
                      _buildInfoTile(Icons.business, "CIN No",
                          settingsProvider.companyDetails[0].cinNo),
                      // Website
                      _buildInfoTile(
                        Icons.location_on_sharp,
                        "Location",
                        settingsProvider.companyDetails[0].isLocation == 1
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                      // Enquiry For Mandatory
                      _buildInfoTile(
                        Icons.check_box,
                        "Enquiry For Mandatory",
                        settingsProvider.companyDetails[0].enquiryForMandatory ==
                                1
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                      // Enquiry Source Mandatory
                      _buildInfoTile(
                        Icons.check_box,
                        "Enquiry Source Mandatory",
                        settingsProvider.companyDetails[0].enquirySourceMandatory ==
                                1
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value,
      {bool isLink = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE9EDF1), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: SelectableText(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isLink ? AppColors.primaryBlue : Colors.black87,
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
