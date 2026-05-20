import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
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
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondaryBlue,
              AppColors.textBlue800,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80), // Increased top spacing
                          // Minimal Logo
                          settingsProvider.isLogoLoading && settingsProvider.logo.isEmpty
                              ? const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: displayLogo.startsWith('http')
                                      ? Image.network(
                                          displayLogo,
                                          height: 40,
                                          fit: BoxFit.contain,
                                          color: Colors.white,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_center, size: 30, color: Colors.white),
                                        )
                                      : Image.asset(
                                          displayLogo,
                                          height: 40,
                                          fit: BoxFit.contain,
                                          color: Colors.white,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_center, size: 30, color: Colors.white),
                                        ),
                                ),
                          
                          const SizedBox(height: 50),
            
                          // Bold Heading
                          Text(
                            'Sign in.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back to ${settingsProvider.displayTitle}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          
                          const SizedBox(height: 50),
            
                          // Minimal Form
                          SignUpForm(
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
                          
                          const Spacer(), // Pushes branding to the bottom
                          
                          // Bottom Branding
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'SOLARIS',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 40), // Space at the very bottom
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
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
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'USERNAME',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          textFieldWidget(
            context: context,
            controller: userNameController,
            labelText: 'user name ',
            height: 56,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'PASSWORD',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
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
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => loginProvider.togglePasswordVisibility(),
                ),
                controller: passwordController,
                labelText: '••••••••',
                height: 56,
                obscureText: !loginProvider.passwordVisible,
              );
            },
          ),
          
          const SizedBox(height: 48),
          
          buttonWidget(
            context: context,
            text: 'Sign in',
            backgroundColor: Colors.white,
            txtColor: AppColors.textBlue800,
            height: 56,
            fontSize: 16,
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}



