import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final messageProvider = StreamProvider.autoDispose<WebSocketChannel>((ref) async* {
  // Open the connection
  final channel = IOWebSocketChannel.connect('wss://echo.websocket.events');
  // final channel = WebSocketChannel.connect(
  //   Uri.parse('wss://echo.websocket.events'),
  // );

  // Close the connection when the stream is destroyed
  ref.onDispose(() => channel.sink.close());

  // Parse the value received and emit a Message instance
  // await for (final value in channel.stream) {
    yield channel;
  // }
});
