import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.getVersion();
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
                // Header section
                Text(
                  'Version',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlue800),
                ),
                const SizedBox(
                  height: 30,
                ),
                // if (settingsProvider.menuIsSaveMap[23] == 1)
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: settingsProvider.versionController,
                          hintText: 'Version Code',
                          labelText: '',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ),
                    if (settingsProvider.menuIsSaveMap[28] == 1)
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          if (settingsProvider
                              .versionController.text.isNotEmpty) {
                            settingsProvider.saveVersion(context);
                          }
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'Save',
                        breakpoint: 860,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
