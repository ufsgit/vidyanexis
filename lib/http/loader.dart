import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class Loader {
  static int _loaderCount = 0;
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Show the loader. Safe to call multiple times (reference counted).
  static Future<void> showLoader(BuildContext context, {String? message}) async {
    _loaderCount++;
    debugPrint('[LOADER_STATE] showLoader count = $_loaderCount');

    if (_isShowing) return;

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Semi-transparent + blurred barrier
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),

              // Loader content
              Center(
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
            ],
          ),
        );
      },
    );

    // Insert into the root Overlay
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  /// Decrease the counter and hide when it reaches zero.
  static void stopLoader(BuildContext context) {
    if (_loaderCount <= 0) {
      _loaderCount = 0;
      debugPrint('[LOADER_STATE] stopLoader called when count <= 0');
      return;
    }

    _loaderCount--;
    debugPrint('[LOADER_STATE] stopLoader count = $_loaderCount');

    if (_loaderCount == 0) {
      _removeOverlay();
    }
  }

  /// Force hide immediately (recommended in `finally` blocks).
  static void forceStopAll(BuildContext context) {
    debugPrint('[LOADER_STATE] forceStopAll count = $_loaderCount -> 0');
    _loaderCount = 0;
    _removeOverlay();
  }

  static void _removeOverlay() {
    try {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    } catch (e) {
      debugPrint("Error removing loader overlay: $e");
    } finally {
      _isShowing = false;
    }
  }
}
