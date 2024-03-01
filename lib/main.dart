import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Websocket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        // useMaterial3: true, // Material 3 is not yet stable
      ),
      home: const MyHomePage(title: 'Flutter Web Socket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textEditingController;
  late WebSocketChannel channel;
  late StreamSubscription<dynamic> streamSubscription;
  String receivedMessage = '';
  late List<String> recivedData;

  @override
  void initState() {
    super.initState();

    recivedData = [];
    _textEditingController = TextEditingController();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.events'),
    );

    streamSubscription = channel.stream.listen(
      (data) {
        setState(() {
          receivedMessage = data.toString();
          recivedData.add(data.toString());
        });
      },
      onDone: () {
        print('WebSocket done');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    _textEditingController.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;

    String message = _textEditingController.text;
    print("Sending message to server: $message");

    channel.sink.add(message);
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Message",
                  hintText: "Enter the message",
                ),
                controller: _textEditingController,
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: recivedData.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: const Text("Dercio Sinione"),
                    subtitle: Text(recivedData[index]),
                    trailing: const Icon(Icons.mail),
                    leading: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.network(
                        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=3280&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        child: const Icon(Icons.send),
      ),
    );
  }
}
