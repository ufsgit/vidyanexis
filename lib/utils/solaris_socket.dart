import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vidyanexis/http/http_urls.dart';

class suryaprabhaSocket {
  static IO.Socket? socket;

  static Future<void> initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    log(token);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userId = preferences.getString('userId') ?? "";
    log(userId);

    if (socket != null && socket!.connected) {
      print('Socket is already initialized and connected');
      return;
    }

    socket = IO.io(
        HttpUrls.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
              'Connection': 'upgrade',
              'Upgrade': 'websocket',
            })
            .enableReconnection()
            .setReconnectionDelay(1)
            .enableForceNew()
            .build());

    socket?.connect();

    socket?.on('error', (error) {
      print('Error: $error');
    });

    socket?.onConnect((_) {
      log('Success: Socket connected successfully');
      socket?.emit("authenticate", {
        "userId": userId,
        "token": token,
        // "appType": appType
      });
    });

    // Add event listeners for debugging
    socket?.on('connect_error', (error) {
      print('Connection Error: $error');
    });

    socket?.on('connect_timeout', (timeout) {
      print('Connection Timeout: $timeout');
    });

    socket?.onConnectError((err) => print('Connect Error: $err'));
    socket?.onError((err) => print('Error: $err'));
    socket?.onDisconnect((_) => print('Disconnect'));
    socket?.on('connecting', (_) => print('Connecting'));
    socket?.on('connect_failed', (_) => print('Connect Failed'));

    // Check connection status after a delay
    await Future.delayed(Duration(seconds: 4), () {
      if (socket?.connected == false) {
        print('Socket failed to connect after timeout');
      }
    });
  }

  static void disconnectSocket() {
    socket?.disconnect();
    print('Socket disconnected');
  }
}
