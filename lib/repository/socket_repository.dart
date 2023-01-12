import 'package:google_docs/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId) {
    socketClient.emit('join', documentId);
  }

  void typing(Map<String, dynamic> data) {
    socketClient.emit('typing', data);
  }

  void autoSave(Map<String, dynamic> data) {
    socketClient.emit('save', data);
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    socketClient.on('changes', (data) => func(data));
  }
}
