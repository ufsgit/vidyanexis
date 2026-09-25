import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class Loader {
  static int _loaderCount = 0;
  static BuildContext? _currentLoaderContext;
  static bool _isDismissing = false; // prevents concurrent dismiss

  static Future<void> showLoader(BuildContext context,
      {String? message}) async {
    // Never use a disposed context
    if (!context.mounted) return;

    _loaderCount++;
    debugPrint('[LOADER_STATE] showLoader count = $_loaderCount');

    if (_loaderCount > 1) return;

    // Schedule the dialog on the next frame so we never fight with an ongoing navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || _loaderCount <= 0) return;

      showDialog(
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.1),
        context: context,
        useRootNavigator: true,
        builder: (ctx) {
          _currentLoaderContext = ctx;

          // Race-condition safety: if stop already happened, dismiss after this frame
          if (_loaderCount <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _dismiss());
          }

          return PopScope(
            canPop: false,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.bluebutton),
                        ),
                      ),
                      if (message != null && message.isNotEmpty) ...[
                        const SizedBox(width: 20),
                        Text(
                          message,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  static void stopLoader(BuildContext context) {
    if (_loaderCount <= 0) {
      _loaderCount = 0;
      debugPrint('[LOADER_STATE] stopLoader called when count <= 0');
      return;
    }

    _loaderCount--;
    debugPrint('[LOADER_STATE] stopLoader count = $_loaderCount');

    if (_loaderCount == 0) {
      _dismiss();
    }
  }

  static void forceStopAll(BuildContext context) {
    debugPrint('[LOADER_STATE] forceStopAll count = $_loaderCount → 0');
    _loaderCount = 0;
    _dismiss();
  }

  static void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;

    final ctx = _currentLoaderContext;
    _currentLoaderContext = null; // clear early to avoid double-pop

    if (ctx == null || !ctx.mounted) {
      _isDismissing = false;
      return;
    }

    // Critical: schedule the pop on the next frame so Navigator is never locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (ctx.mounted) {
          final navigator = Navigator.of(ctx, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      } catch (e) {
        debugPrint('Error stopping loader: $e');
      } finally {
        _isDismissing = false;
      }
    });
  }
}
