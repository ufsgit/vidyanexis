import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/login_controller.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/presentation/widgets/login/login_page_widgets.dart';

class LoginPage extends StatefulWidget {
  static String route = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.getCompanyDetails();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginController>(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/On boarding.png'),
                    fit: BoxFit.cover)),
          ),
          Center(
            child: Container(
              width: 376,
              // height: 340,
              decoration: BoxDecoration(
                  color: AppColors.scaffoldColor,
                  borderRadius: BorderRadius.circular(16)),
              child: SignUpForm(
                passwordController: loginProvider.passWordController,
                userNameController: loginProvider.userNameController,
                onPressed: () {
                  loginProvider.login(
                      context: context,
                      passWord: loginProvider.passWordController.text,
                      userName: loginProvider.userNameController.text);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  FocusNode passwordNode = FocusNode();
  final void Function()? onPressed;

  SignUpForm({
    super.key,
    this.onPressed,
    required this.userNameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Center all children
          children: [
            // Logo with perfect centering
            Center(
              child: Image.network(
                HttpUrls.imgBaseUrl + settingsProvider.logo,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),
            ),
            const SizedBox(height: 16),
            // Title with perfect centering and text wrapping
            Center(
              child: Text(
                "Login to ${settingsProvider.title}",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack),
                textAlign: TextAlign.center, // Center align the text
                maxLines: 2, // Allow wrapping to 2 lines if title is very long
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            // Form fields with consistent alignment
            SizedBox(
              width: double.infinity, // Ensure full width
              child: textFieldWidget(
                  context: context,
                  controller: userNameController,
                  labelText: 'User name',
                  onSubmitted: (v) {
                    passwordNode.requestFocus();
                  },
                  height: 54),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, // Ensure full width
              child: Consumer<LoginController>(
                builder: (context, loginProvider, child) {
                  return textFieldWidget(
                    context: context,
                    focusNode: passwordNode,
                    onSubmitted: (value) {
                      loginProvider.login(
                        context: context,
                        passWord: loginProvider.passWordController.text,
                        userName: loginProvider.userNameController.text,
                      );
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginProvider.passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textGrey3,
                      ),
                      onPressed: () => loginProvider.togglePasswordVisibility(),
                    ),
                    controller: passwordController,
                    labelText: 'Password',
                    height: 54,
                    obscureText: !loginProvider.passwordVisible,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Button with full width for better visual balance
            SizedBox(
              width: double.infinity,
              child: buttonWidget(
                context: context,
                text: 'Log in',
                backgroundColor: AppColors.appViolet,
                txtColor: AppColors.scaffoldColor,
                height: 40,
                fontSize: 14,
                onPressed: onPressed,
              ),
            )
          ],
        ),
      ),
    );
  }
}
