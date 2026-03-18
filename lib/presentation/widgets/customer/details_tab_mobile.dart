import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/label_value_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsTabMobile extends StatefulWidget {
  final String customerId;

  const DetailsTabMobile({
    super.key,
    required this.customerId,
  });

  @override
  State<DetailsTabMobile> createState() => _DetailsTabMobileState();
}

class _DetailsTabMobileState extends State<DetailsTabMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(
      context,
    );
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: leadDetailsProvider.isFetchLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TileWidget(
                      initiallyExpanded: true,
                      title: 'Basic details',
                      iconAssetPath: 'assets/images/icon_profile_details.png',
                      children: [
                        LabelValueWidget(
                          label: 'Name',
                          value:
                              leadDetailsProvider.leadDetails![0].customerName,
                        ),
                        const SizedBox(height: 8),
                        LabelValueWidget(
                          label: 'Enquiry source',
                          value: leadDetailsProvider
                              .leadDetails![0].enquirySourceName,
                        ),
                        const SizedBox(height: 8),
                        LabelValueWidget(
                          label: 'Mobile no',
                          value: leadDetailsProvider
                              .leadDetails![0].contactNumber
                              .toString(),
                        ),
                        // const SizedBox(height: 8),
                        // LabelValueWidget(
                        //   label: 'Email id',
                        //   value: leadDetailsProvider.leadDetails![0].email,
                        // ),
                        const SizedBox(height: 8),
                        LabelValueWidget(
                          label: 'Enquiry for',
                          value: leadDetailsProvider
                              .leadDetails![0].enquiryForName,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                    // Address
                    TileWidget(
                      title: 'Address',
                      iconAssetPath: 'assets/images/icon_location_details.png',
                      children: [
                        LabelValueWidget(
                          label: 'Address',
                          value:
                              leadDetailsProvider.leadDetails![0].address ?? "",
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () => _openMaps(
                              leadDetailsProvider.leadDetails![0].location ??
                                  ""),
                          child: LabelValueWidget(
                            label: 'Location',
                            labelColor: AppColors.bluebutton,
                            value:
                                leadDetailsProvider.leadDetails![0].location ??
                                    "",
                          ),
                        ),
                        SizedBox(height: 8),
                        // LabelValueWidget(
                        //   label: 'City',
                        //   value: leadDetailsProvider.leadDetails![0].address2 ??
                        //       "",
                        // ),
                        // SizedBox(height: 8),
                        // LabelValueWidget(
                        //   label: 'District',
                        //   value: leadDetailsProvider.leadDetails![0].address3 ??
                        //       "",
                        // ),
                        // SizedBox(height: 8),
                        // LabelValueWidget(
                        //   label: 'Pin code',
                        //   value: leadDetailsProvider.leadDetails![0].pincode,
                        // ),
                        // SizedBox(height: 8),
                        // LabelValueWidget(
                        //   label: 'State',
                        //   value: leadDetailsProvider.leadDetails![0].address4 ??
                        //       "",
                        // ),
                        SizedBox(height: 8),
                      ],
                    ),

                    // Invertor and panel details
                    // TileWidget(
                    //   title: 'Inverter and panel details',
                    //   iconAssetPath: 'assets/images/icon_settings_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Inverter Brand',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].inverterTypeName,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Inverter Capacity',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].inverterCapacity
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Panel Brand',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].panelTypeName
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),

                    //     LabelValueWidget(
                    //       label: 'Panel Capacity',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].panelCapacity
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Panel Phase',
                    //       value: leadDetailsProvider.leadDetails![0].phaseName,
                    //     ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel Brand',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelBrand,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel Watts',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelWatts,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel SN',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelSn,
                    //     // ),
                    //   ],
                    // ),

                    // Consumer details
                    // TileWidget(
                    //   title: 'Cost details',
                    //   iconAssetPath: 'assets/images/icon_consumer_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Project Cost',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].projectCost,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Additional Cost',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].additionalCost,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Advance Paid By Customer',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].advanceAmount,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Cost Includes',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].costIncName,
                    //     ),
                    //     SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Connection load',
                    //     //   value: leadDetailsProvider
                    //     //       .leadDetails![0].connectedLoad
                    //     //       .toString(),
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Proposed KW',
                    //     //   value: leadDetailsProvider.leadDetails![0].proposedKw,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Roof type',
                    //     //   value: leadDetailsProvider.leadDetails![0].roofType,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Application number',
                    //     //   value: leadDetailsProvider
                    //     //       .leadDetails![0].applicationNumber,
                    //     // ),
                    //     SizedBox(height: 8),
                    //   ],
                    // ),
                    // TileWidget(
                    //   title: 'Additional Details',
                    //   iconAssetPath: 'assets/images/icon_consumer_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Consumer Number',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].consumerNumber ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Electrical Section',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].electricalSection ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Connection Load',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].connectedLoad
                    //               .toString() ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'REP',
                    //       value: leadDetailsProvider.leadDetails![0].rep ?? "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Lead By',
                    //       value: leadDetailsProvider.leadDetails![0].leadBy,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Work type',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].workTypeName ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Roof type',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].roofTypeName ??
                    //           "",
                    //     ),
                    //   ],
                    // ),
                    // Invoice details
                    // if (settingsProvider.menuIsViewMap[21] == 1)
                    //   TileWidget(
                    //     title: 'Invoice details',
                    //     iconAssetPath:
                    //         'assets/images/icon_bookmark_details.png',
                    //     children: [
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Number',
                    //       //   value:
                    //       //       leadDetailsProvider.leadDetails![0].invoiceNo,
                    //       // ),
                    //       // SizedBox(height: 8),
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Amount',
                    //       //   value: leadDetailsProvider
                    //       //       .leadDetails![0].invoiceAmount
                    //       //       .toString(),
                    //       // ),
                    //       // SizedBox(height: 8),
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Date',
                    //       //   value: leadDetailsProvider
                    //       //       .leadDetails![0].invoiceDate
                    //       //       .toFormattedDate(),
                    //       // ),
                    //       SizedBox(height: 8),
                    //     ],
                    //   ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _openMaps(String location) async {
    print('DEBUG: _openMaps called with: "$location"');

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location available')),
      );
      return;
    }

    String cleanLocation = location.trim();

    // Check if location is already a URL
    if (cleanLocation.startsWith('http://') ||
        cleanLocation.startsWith('https://')) {
      print('DEBUG: Location is already a URL');
      try {
        await launchUrl(Uri.parse(cleanLocation),
            mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        print('DEBUG: Error launching existing URL: $e');
        // If the existing URL fails, try to extract coordinates
        RegExp coordRegex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
        Match? match = coordRegex.firstMatch(cleanLocation);
        if (match != null) {
          String coords = '${match.group(1)},${match.group(2)}';
          String newUrl = 'https://www.google.com/maps/search/$coords';
          print('DEBUG: Trying extracted coordinates URL: $newUrl');
          await launchUrl(Uri.parse(newUrl),
              mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    // Check if location contains coordinates
    bool isCoordinates =
        RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$').hasMatch(cleanLocation);
    print('DEBUG: Is coordinates: $isCoordinates');

    String webUrl;

    if (isCoordinates) {
      webUrl = 'https://www.google.com/maps/search/$cleanLocation';
    } else {
      final encodedLocation = Uri.encodeComponent(cleanLocation);
      webUrl = 'https://www.google.com/maps/search/$encodedLocation';
    }

    print('DEBUG: Final URL: $webUrl');

    try {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('DEBUG: Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps: $e')),
      );
    }
  }
}
