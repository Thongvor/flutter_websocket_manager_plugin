import 'package:flutter/material.dart';

import 'package:websocket_manager/websocket_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _urlController =
      TextEditingController(text: 'wss://joitin-staging.herokuapp.com/secured/chat?Authorization=Bearer%20eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyYzIzZDI5Ni04NTZlLTQwOWMtYjNjMi0zZWE3Y2ZlNDQzYmQiLCJhdXRoIjoiUk9MRV9VU0VSIiwiZXhwIjoxNjIzMzQyNDkxfQ.McUP3WJJAzj7OFZDxIBNP4ZsUmUyv3uuzLDs5dW_p8_bhW462Qgx4bKi3ZWl1XgcnO_FzP-eVBBYnKnvlF2URw');
  final TextEditingController _messageController = TextEditingController();
  WSManager socket;
  String _message = '';
  String _closeMessage = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Websocket Manager Example'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            Wrap(
              children: <Widget>[
                RaisedButton(
                  child: Text('CONFIG'),
                  onPressed: () =>
                      socket = WSManager(_urlController.text),
                ),
                RaisedButton(
                  child: Text('CONNECT'),
                  onPressed: () {
                    if (socket != null) {
                      socket.connect();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.close();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN MESSAGE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onOpen((dynamic message) {
                        print('WS Opened');
                        this.socket.send('{"typeOfMessage": "/secured/room/availableRooms"}');
                      });
                      socket.onMessage((dynamic message) {
                        print('New message: $message');
                        setState(() {
                          _message = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN DONE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onClose((dynamic message) {
                        print('Close message: $message');
                        setState(() {
                          _closeMessage = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('ECHO TEST'),
                  onPressed: () => WSManager.echoTest(),
                ),
              ],
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (socket != null) {
                      socket.send(_messageController.text);
                    }
                  },
                ),
              ),
            ),
            Text('Received message:'),
            Text(_message),
            Text('Close message:'),
            Text(_closeMessage),
          ],
        ),
      ),
    );
  }
}
