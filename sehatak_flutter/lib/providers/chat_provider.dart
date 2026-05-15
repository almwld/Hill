import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatProvider extends ChangeNotifier {
  static const String serverUrl = 'https://hi-g26z.onrender.com';
  
  IO.Socket? _socket;
  bool _isConnected = false;
  final List<ChatMessage> _messages = [];

  bool get isConnected => _isConnected;
  List<ChatMessage> get messages => _messages;

  void connect() {
    _socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
    });

    _socket!.on('new_message', (data) {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? '',
        text: data['text'] ?? '',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    });
  }

  void sendMessage(String text) {
    _socket?.emit('send_message', {
      'senderId': 'user_123',
      'senderName': 'أحمد',
      'text': text,
    });
  }

  void disconnect() {
    _socket?.disconnect();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
