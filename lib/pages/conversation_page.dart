import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  late String _concersationID;
  late String _receiverID;
  late String _receiverImage;
  late String _receiverName;

  ConversationPage(
    this._concersationID,
    this._receiverID,
    this._receiverImage,
    this._receiverName,
  );

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(this.widget._receiverName),

        centerTitle: true,
      ),
    );
  }

  Widget conversationPageUI() {
    return Stack(clipBehavior: Clip.none, children: [_messageListView()]);
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext _context, int _index) {
          return _textMessageBubble(true, 'Hello!');
        },
      ),
    );
  }

  Widget _textMessageBubble(bool _isOwnMessage, String _message) {
    List<Color> _colorScheme =
        _isOwnMessage
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _deviceHeight * 0.10,
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_message),
          Text('A moment ago', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
