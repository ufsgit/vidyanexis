import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
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
                        settingsProvider.saveIamgePath(
                            settingsProvider.companyDetails[0].logo.toString());
                        settingsProvider.setToggleValue(
                            settingsProvider.companyDetails[0].isLocation);
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
                        borderRadius: BorderRadius.circular(20)),
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
                          backgroundImage: NetworkImage(HttpUrls.imgBaseUrl +
                              settingsProvider.companyDetails[0].logo),
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
                      // Website
                      _buildInfoTile(
                        Icons.location_on_sharp,
                        "Location",
                        settingsProvider.companyDetails[0].isLocation == 1
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: SelectableText(
          value,
          style: TextStyle(
            color: isLink ? Colors.blue : Colors.black,
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
