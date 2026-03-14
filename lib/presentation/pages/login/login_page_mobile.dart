import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/login_controller.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/login/login_page_widgets.dart';

class LoginPageMobile extends StatefulWidget {
  static String route = '/login';
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final displayLogo = settingsProvider.displayLogo;

    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.textBlue800,
                    AppColors.secondaryBlue,
                    Colors.lightGreen,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    // Logo at the top
                    Center(
                      child: settingsProvider.isLogoLoading &&
                              settingsProvider.logo.isEmpty
                          ? const SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: displayLogo.startsWith('http')
                                      ? Image.network(
                                          displayLogo,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              AppStyles.logo(),
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          displayLogo,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container();
                                          },
                                        ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),

                    // "Welcome to" text
                    Center(
                      child: Text(
                        'Welcome to',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Title with proper wrapping
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          settingsProvider.displayTitle,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteColor),
                          textAlign: TextAlign.center,
                          maxLines: 3, // Allow up to 3 lines
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom /
                    800 // Adjust this value as needed
                : 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 405,
                    decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))),
                    child: SignUpForm(
                      passwordController: loginProvider.passWordController,
                      userNameController: loginProvider.userNameController,
                      onPressed: () {
                        loginProvider.login(
                          context: context,
                          passWord: loginProvider.passWordController.text,
                          userName: loginProvider.userNameController.text,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final void Function()? onPressed;

  const SignUpForm({
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(
              'Login to continue',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack),
            ),
            const SizedBox(height: 24),
            textFieldWidget(
                context: context,
                controller: userNameController,
                labelText: 'User name',
                height: 54),
            const SizedBox(height: 12),
            Consumer<LoginController>(
              builder: (context, loginProvider, child) {
                return textFieldWidget(
                  context: context,
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
            const SizedBox(height: 24),
            buttonWidget(
              context: context,
              text: 'Log in',
              backgroundColor: AppColors.appViolet,
              txtColor: AppColors.scaffoldColor,
              height: 48,
              fontSize: 14,
              onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}
