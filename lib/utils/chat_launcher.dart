import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class ChatLauncher {
  static Future<void> handleChat(BuildContext context, String phone) async {
    String formatted = formatIndianPhoneNumber(phone);

    if (formatted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Indian mobile number')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPref = prefs.getString('whatsapp_preference');

    if (savedPref != null) {
      bool success = await _launchSelectedApp(context, savedPref, formatted);
      if (!success) {
        // If it failed (e.g. app uninstalled), clear preference and ask again
        await prefs.remove('whatsapp_preference');
        if (context.mounted) _showChooserDialog(context, formatted);
      }
    } else {
      _showChooserDialog(context, formatted);
    }
  }

  static void _showChooserDialog(BuildContext context, String formatted) {
    String selectedApp = 'WhatsApp'; // Default selection

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Open with'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Normal WhatsApp'),
                    value: 'WhatsApp',
                    groupValue: selectedApp,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedApp = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('WhatsApp Business'),
                    value: 'WhatsApp Business',
                    groupValue: selectedApp,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedApp = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('SMS'),
                    value: 'SMS',
                    groupValue: selectedApp,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedApp = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _launchSelectedApp(context, selectedApp, formatted);
                  },
                  child: Text('Just once', style: TextStyle(color: AppColors.textGrey3)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('whatsapp_preference', selectedApp);
                    _launchSelectedApp(context, selectedApp, formatted);
                  },
                  child: Text('Always', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<bool> _launchSelectedApp(BuildContext context, String appType, String formatted) async {
    if (appType == 'WhatsApp') {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final Uri whatsappUriIos = Uri.parse('whatsapp://send?phone=$formatted');
        if (await canLaunchUrl(whatsappUriIos)) {
          await launchUrl(whatsappUriIos, mode: LaunchMode.externalApplication);
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed.')));
          return false;
        }
      } else {
        try {
          final intent = AndroidIntent(
            action: 'action_view',
            data: 'https://api.whatsapp.com/send?phone=$formatted',
            package: 'com.whatsapp',
          );
          final canResolve = await intent.canResolveActivity() ?? false;
          if (canResolve) {
            await intent.launch();
            return true;
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed.')));
            }
            return false;
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed.')));
          }
          return false;
        }
      }
    } else if (appType == 'WhatsApp Business') {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final Uri businessWhatsappUriIos = Uri.parse('whatsapp-business://send?phone=$formatted');
        if (await canLaunchUrl(businessWhatsappUriIos)) {
          await launchUrl(businessWhatsappUriIos, mode: LaunchMode.externalApplication);
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp Business is not installed.')));
          return false;
        }
      } else {
        try {
          final intent = AndroidIntent(
            action: 'action_view',
            data: 'https://api.whatsapp.com/send?phone=$formatted',
            package: 'com.whatsapp.w4b',
          );
          final canResolve = await intent.canResolveActivity() ?? false;
          if (canResolve) {
            await intent.launch();
            return true;
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp Business is not installed.')));
            }
            return false;
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp Business is not installed.')));
          }
          return false;
        }
      }
    } else if (appType == 'SMS') {
      final Uri smsUri = Uri(scheme: 'sms', path: formatted);
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    }
    return false;
  }
}
